import Foundation
import Hummingbird
import HummingbirdTesting
import Testing
import Teleroute
import TelerouteHummingbird
import TelerouteTestSupport

/// In-process tests for the Hummingbird webhook integration (no network).
@Suite struct TelegramWebhookTests {
    @Test func webhookRejectsWrongSecretAndRoutesValidUpdates() async throws {
        let recorder = TelerouteTestRecorder<String>()
        let telerouteRouter = Teleroute()
        telerouteRouter.command("start") { context in
            await recorder.record("start:\(context.update.updateId)")
        }

        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: telerouteRouter,
            logger: .init(label: "tests.webhook"),
            configuration: .init(replayProtectionStorage: nil),
            mode: .webhook,
            transport: TelerouteStubTransport(),
            rateLimit: nil
        )

        let router = Router()
        router.registerTelegramWebhook(bot: bot, path: "/hook", secretToken: "s3cret")
        let app = Application(router: router)

        try await app.test(.router) { client in
            let update = #"{"update_id":7001,"message":{"message_id":1,"date":1,"chat":{"id":1,"type":"private"},"from":{"id":1,"is_bot":false,"first_name":"T"},"text":"/start"}}"#

            // Missing secret → 401.
            try await client.execute(
                uri: "/hook",
                method: .post,
                body: .init(string: update)
            ) { response in
                #expect(response.status == .unauthorized)
            }

            // Wrong secret → 401.
            try await client.execute(
                uri: "/hook",
                method: .post,
                headers: [.init("X-Telegram-Bot-Api-Secret-Token")!: "wrong"],
                body: .init(string: update)
            ) { response in
                #expect(response.status == .unauthorized)
            }

            // Valid secret → 200 and the update reaches the route.
            try await client.execute(
                uri: "/hook",
                method: .post,
                headers: [.init("X-Telegram-Bot-Api-Secret-Token")!: "s3cret"],
                body: .init(string: update)
            ) { response in
                #expect(response.status == .ok)
            }

            // Malformed body → 400.
            try await client.execute(
                uri: "/hook",
                method: .post,
                headers: [.init("X-Telegram-Bot-Api-Secret-Token")!: "s3cret"],
                body: .init(string: "not json")
            ) { response in
                #expect(response.status == .badRequest)
            }
        }

        #expect(await recorder.waitForCount(1) == ["start:7001"])
        await bot.shutdown()
    }
}
