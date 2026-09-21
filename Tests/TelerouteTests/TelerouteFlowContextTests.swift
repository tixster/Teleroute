import Foundation
import HTTPTypes
import Synchronization
import Testing
import Teleroute
import TelerouteTestSupport

/// Covers ``TelerouteFlowContext`` as a first-class ``TelerouteRequestContext``:
/// the full helper surface inside a flow step, and the button/keyboard support
/// that used to be unreachable there.
@Suite struct TelerouteFlowContextTests {
    /// Compiles only if the conformance exists, and pins the one member pair
    /// that could have collided: the `update` property from the protocol
    /// extension against the `update(merging:)` method on the flow context.
    @Test func flowContextIsARequestContext() async throws {
        let router = Teleroute()
        router.flow(SurfaceFlow())

        let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            _ = await client.sendCommand("surface", updateId: 8_001)
            _ = await client.sendMessage("Alice", updateId: 8_002)
        }
        await bot.shutdown()

        // The step asserted the property/method split internally; reaching the
        // reply at all proves the step ran to completion.
        let texts = telegram.effects.compactMap { effect -> String? in
            guard case let .sentMessage(message) = effect else { return nil }
            return message.text
        }
        #expect(texts.contains("surface ok"))
    }

    /// Media and reaction helpers live on `TelerouteRequestContext`, so before
    /// the conformance a flow step could only reach them through
    /// `context.context`. This calls them directly.
    @Test func flowStepUsesMediaAndReactionHelpersDirectly() async throws {
        let recordedOperations = Mutex<[String]>([])
        let transport = TelerouteRecordingTransport(fallback: { operationID, _ in
            recordedOperations.withLock { $0.append(operationID) }
            var response = HTTPResponse(status: .ok)
            response.headerFields[.contentType] = "application/json"
            // setMessageReaction answers with `true`; the send* family answers
            // with a Message.
            let body = operationID == "setMessageReaction"
                ? #"{"ok":true,"result":true}"#
                : #"{"ok":true,"result":{"message_id":9,"date":1,"chat":{"id":1,"type":"private"}}}"#
            return (response, Data(body.utf8))
        })

        let router = Teleroute()
        router.flow(MediaFlow())

        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.flow.media"),
            configuration: .init(replayProtectionStorage: nil),
            transport: transport,
            rateLimit: nil
        )
        try await bot.test { client in
            _ = await client.sendCommand("media", updateId: 8_011)
            _ = await client.sendMessage("go", updateId: 8_012)
        }
        await bot.shutdown()

        let operations = recordedOperations.withLock { $0 }
        #expect(operations.contains("sendPhoto"))
        #expect(operations.contains("setMessageReaction"))
    }
}

// MARK: - Flows

private struct SurfaceFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case name
    }

    func boot(flow: TelerouteFlowGroup<SurfaceFlow>) {
        flow.start("surface", at: .name) { _ in }
        flow.message(at: .name) { context in
            // `update` resolves to the protocol extension's property...
            let update: Update = context.update
            #expect(update.updateId == 8_002)

            // ...while `update(merging:)` still resolves to the flow method.
            try await context.update(merging: ["seen": "1"])

            // Accessors that used to be re-declared on the flow context.
            #expect(context.chatId == 1)
            #expect(context.userId == 1)
            #expect(context.message?.text == "Alice")
            _ = context.bot
            _ = context.parameters
            _ = context.callbackQuery
            _ = context.callbackData
            _ = context.command

            // Newly reachable: target resolution from the request context.
            #expect(try context.resolvedChat() == .id(1))

            try await context.reply("surface ok")
        }
    }
}

private struct MediaFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case ready
    }

    func boot(flow: TelerouteFlowGroup<MediaFlow>) {
        flow.start("media", at: .ready) { _ in }
        flow.message(at: .ready) { context in
            try await context.sendPhoto(.fileID("photo-id"), caption: "from a flow")
            try await context.react("👍")
        }
    }
}

// MARK: - Inline actions inside a flow step

/// Buttons carrying an inline handler used to be unreachable from a flow step:
/// the flow coordinator built its contexts without the inline-action store, so
/// rendering one threw ``TelerouteError/inlineActionsDisabled`` — telling the
/// user the feature was off even when they had explicitly enabled it.
@Suite struct TelerouteFlowInlineActionTests {
    @Test func flowStepRendersAndRunsButtonWithInlineHandler() async throws {
        let pressed = TelerouteTestRecorder<String>()
        let router = Teleroute()
        router.flow(InlineActionFlow(pressed: pressed))

        let telegram = TelerouteRecordingTransport()
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.flow.inline"),
            configuration: .init(
                replayProtectionStorage: nil,
                inlineActions: .enabled()
            ),
            transport: telegram,
            rateLimit: nil
        )

        try await bot.test { client in
            _ = await client.sendCommand("inlineflow", updateId: 8_021)
            _ = await client.sendMessage("go", updateId: 8_022)
        }

        // The step rendered a keyboard rather than throwing.
        let callbackData: [String] = telegram.effects.compactMap { effect in
            guard case let .sentMessage(message) = effect,
                  case let .InlineKeyboardMarkup(markup) = message.replyMarkup
            else { return nil }
            return markup.inlineKeyboard.flatMap { $0 }.compactMap(\.callbackData).first
        }
        let data = try #require(callbackData.first)

        try await bot.test { client in
            _ = await client.execute(
                TelerouteTestSupport.makeCallbackUpdate(data: data, updateId: 8_023)
            )
        }
        #expect(await pressed.waitForCount(1) == ["approved"])
        await bot.shutdown()
    }
}

private struct InlineActionFlow: TelerouteFlow {
    let pressed: TelerouteTestRecorder<String>

    enum Step: String, Sendable {
        case ready
    }

    func boot(flow: TelerouteFlowGroup<InlineActionFlow>) {
        let pressed = self.pressed
        flow.start("inlineflow", at: .ready) { _ in }
        flow.message(at: .ready) { context in
            try await context.reply(
                "Approve?",
                replyMarkup: .inline(try context.keyboard {
                    Row {
                        TelerouteButton("Approve") { _ in
                            await pressed.record("approved")
                            return Edit("Approved")
                        }
                    }
                })
            )
        }
    }
}
