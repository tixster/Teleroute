import Foundation
import Testing
import Teleroute
import TelerouteTestSupport

/// Typed state replaces `values.require("name")` with a field, while riding
/// inside the existing values dictionary so the storage wire format is
/// untouched.
@Suite struct TelerouteFlowTypedStateTests {
    private let key = TelerouteFlowKey(chatId: 1, userId: 1)

    @Test func typedStateRoundTripsThroughTheSession() async throws {
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(TypedFlow())

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("typed", updateId: 4_501)
            _ = await client.sendMessage("Alice", updateId: 4_502)
            _ = await client.sendMessage("confirm", updateId: 4_503)
        }
        await bot.shutdown()

        let texts = telegram.effects.compactMap { effect -> String? in
            guard case let .sentMessage(message) = effect else { return nil }
            return message.text
        }
        #expect(texts.contains("Alice, attempts: 1"))
    }

    /// The reserved key must not leak into the values a flow author sees.
    @Test func stateKeyIsHiddenFromValueAccessors() throws {
        let values = try TelerouteFlowValues(["name": "Alice"])
            .settingState(TypedFlow.FlowState(name: "Alice", attempts: 2))

        #expect(values.count == 1)
        #expect(values.keys.contains(TelerouteFlowValues.stateKey) == false)
        #expect(values.dictionary == ["name": "Alice"])
        // Backends need the full picture, or typed state is silently dropped.
        #expect(values.rawDictionary.keys.contains(TelerouteFlowValues.stateKey))

        let decoded = try #require(try values.state(TypedFlow.FlowState.self))
        #expect(decoded.attempts == 2)
    }

    /// A session persisted by a shared store must carry typed state across the
    /// round trip, which is the whole point of hiding it inside values.
    @Test func typedStateSurvivesSessionCoding() throws {
        let values = try TelerouteFlowValues()
            .settingState(TypedFlow.FlowState(name: "Bob", attempts: 3))
        let session = TelerouteFlowSession(id: "F", step: "s", values: values)

        let decoded = try TelerouteFlowSessionCoding.decode(
            TelerouteFlowSessionCoding.encode(session)
        )
        let state = try #require(try decoded.values.state(TypedFlow.FlowState.self))
        #expect(state.name == "Bob")
        #expect(state.attempts == 3)
    }

    /// A session written before typed state existed simply has none.
    @Test func sessionWithoutTypedStateReportsNil() throws {
        let session = TelerouteFlowSession(id: "F", step: "s", values: ["name": "Old"])
        #expect(try session.values.state(TypedFlow.FlowState.self) == nil)
        #expect(session.values.isEmpty == false)
    }
}

private struct TypedFlow: TelerouteFlow {
    enum Step: String, Sendable { case name, confirm }

    struct FlowState: Codable, Sendable, TelerouteDefaultInitializable {
        var name = ""
        var attempts = 0

        init() {}
        init(name: String, attempts: Int) {
            self.name = name
            self.attempts = attempts
        }
    }

    func boot(flow: TelerouteFlowGroup<TypedFlow>) {
        flow.start("typed", at: .name, asking: "Name?")
        flow.message(at: .name) { context in
            try await context.transition(
                to: .confirm,
                state: .init(name: context.message?.text ?? "", attempts: 1)
            )
        }
        flow.message(at: .confirm) { context in
            let state = try context.requireState()
            try await context.reply("\(state.name), attempts: \(state.attempts)")
        }
    }
}
