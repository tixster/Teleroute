import Foundation
import Testing
import Teleroute
import TelerouteTestSupport

/// `ask` collapses prompt → capture → validate → store → transition, which was
/// four hand-written lines per step.
@Suite struct TelerouteFlowSugarTests {
    private let key = TelerouteFlowKey(chatId: 1, userId: 1)

    @Test func askCapturesStoresAndTransitions() async throws {
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(SugarFlow())

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("sugar", updateId: 4_401)
            _ = await client.sendMessage("Alice", updateId: 4_402)
        }
        await bot.shutdown()

        let session = try #require(await storage.session(for: self.key))
        #expect(session.step == "email")
        #expect(session.values["name"] == "Alice")

        let texts = telegram.effects.compactMap { effect -> String? in
            guard case let .sentMessage(message) = effect else { return nil }
            return message.text
        }
        // start(asking:) sent the first question, ask(next:) the second.
        #expect(texts == ["What's your name?", "And your email?"])
    }

    /// A rejected answer must leave the session exactly where it was, so the
    /// user simply answers again.
    @Test func askRetriesWithoutTransitioningOnInvalidInput() async throws {
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(ValidatingFlow())

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("amount", updateId: 4_411)
            _ = await client.sendMessage("not a number", updateId: 4_412)
            _ = await client.sendMessage("-5", updateId: 4_413)
            _ = await client.sendMessage("42", updateId: 4_414)
        }
        await bot.shutdown()

        let session = try #require(await storage.session(for: self.key))
        #expect(session.step == "done")
        #expect(session.values["amount"] == "42")

        let texts = telegram.effects.compactMap { effect -> String? in
            guard case let .sentMessage(message) = effect else { return nil }
            return message.text
        }
        #expect(texts.contains("Send a number."))          // undecodable
        #expect(texts.contains("Must be positive."))       // validator rejected
    }

    /// With a `CaseIterable` step enum, `then:` is inferred from declaration
    /// order — the linear-flow case.
    @Test func askInfersTheNextStepFromCaseIterable() async throws {
        let storage = TelerouteMockFlowStorage()
        let router = Teleroute()
        router.flow(LinearFlow())

        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(
            router: router,
            configuration: .init(flowStorage: storage, replayProtectionStorage: nil)
        )
        try await bot.test { client in
            _ = await client.sendCommand("linear", updateId: 4_421)
            _ = await client.sendMessage("Alice", updateId: 4_422)
            _ = await client.sendMessage("a@example.com", updateId: 4_423)
        }
        await bot.shutdown()

        let session = try #require(await storage.session(for: self.key))
        #expect(session.step == "confirm")
        #expect(session.values["name"] == "Alice")
        #expect(session.values["email"] == "a@example.com")
    }

    /// Asking on the last case has nowhere to go; that is reported rather than
    /// silently producing a dead-end session.
    @Test func askOnTheFinalStepIsReportedAsUnreachable() {
        let router = Teleroute()
        router.flow(DeadEndFlow())

        #expect(router.unreachableFlowSteps.count == 1)
        #expect(router.unreachableFlowSteps.first?.step == "last")
        #expect(router.unreachableFlowSteps.first?.flowID == DeadEndFlow.id)
    }
}

// MARK: - Flows

private struct SugarFlow: TelerouteFlow {
    enum Step: String, Sendable { case name, email }

    func boot(flow: TelerouteFlowGroup<SugarFlow>) {
        flow.start("sugar", at: .name, asking: "What's your name?")
        flow.ask(.name, store: "name", then: .email, next: "And your email?")
        flow.message(at: .email) { _ in }
    }
}

private struct ValidatingFlow: TelerouteFlow {
    enum Step: String, Sendable { case amount, done }

    func boot(flow: TelerouteFlowGroup<ValidatingFlow>) {
        flow.start("amount", at: .amount, asking: "How much?")
        flow.ask(
            .amount,
            store: "amount",
            as: Double.self,
            then: .done,
            invalid: "Send a number."
        ) { value in
            value > 0 ? .accept : .retry("Must be positive.")
        }
        flow.message(at: .done) { _ in }
    }
}

private struct LinearFlow: TelerouteFlow {
    enum Step: String, CaseIterable, Sendable { case name, email, confirm }

    func boot(flow: TelerouteFlowGroup<LinearFlow>) {
        flow.start("linear", at: .name, asking: "Name?")
        flow.ask(.name, store: "name", next: "Email?")
        flow.ask(.email, store: "email", next: "Confirm?")
        flow.message(at: .confirm) { _ in }
    }
}

private struct DeadEndFlow: TelerouteFlow {
    enum Step: String, CaseIterable, Sendable { case first, last }

    func boot(flow: TelerouteFlowGroup<DeadEndFlow>) {
        flow.start("deadend", at: .first, asking: "Go")
        flow.ask(.first, store: "a")
        flow.ask(.last, store: "b")        // nowhere to advance to
    }
}
