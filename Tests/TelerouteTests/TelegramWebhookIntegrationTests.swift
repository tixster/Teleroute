import Foundation
import Synchronization
import HTTPTypes
import Hummingbird
import HummingbirdTesting
import Logging
import ServiceLifecycle
import Testing
import Teleroute
import TelerouteHummingbird
import TelerouteTestSupport

/// In-process tests for the one-call Hummingbird entry points (no network).
@Suite struct TelegramWebhookIntegrationTests {
    private static let update = #"{"update_id":7001,"message":{"message_id":1,"date":1,"chat":{"id":1,"type":"private"},"from":{"id":1,"is_bot":false,"first_name":"T"},"text":"/start"}}"#

    // MARK: - Path derivation

    @Test func pathIsDerivedFromTheWebhookURL() async throws {
        let (bot, _, _) = try Self.makeBot()
        let webhook = TelegramWebhookConfiguration(
            url: "https://bot.example.com/telegram",
            secretToken: "s3cret"
        )

        let router = Router()
        router.registerTelegramWebhook(bot: bot, webhook: webhook)
        let app = Application(router: router)

        try await app.test(.router) { client in
            try await Self.post(client, path: "/telegram", secret: "s3cret") { response in
                #expect(response.status == .ok)
            }
            // The default path is not registered when the URL supplies one.
            try await Self.post(client, path: "/telegram-webhook", secret: "s3cret") { response in
                #expect(response.status == .notFound)
            }
        }
        await bot.shutdown()
    }

    @Test func explicitPathOverridesTheURLButKeepsTheSecret() async throws {
        let (bot, _, _) = try Self.makeBot()
        let webhook = TelegramWebhookConfiguration(
            url: "https://bot.example.com/telegram",
            secretToken: "s3cret"
        )

        let router = Router()
        router.registerTelegramWebhook(bot: bot, webhook: webhook, path: "/proxied")
        let app = Application(router: router)

        try await app.test(.router) { client in
            try await Self.post(client, path: "/proxied", secret: "s3cret") { response in
                #expect(response.status == .ok)
            }
            try await Self.post(client, path: "/proxied", secret: "wrong") { response in
                #expect(response.status == .unauthorized)
            }
        }
        await bot.shutdown()
    }

    @Test func urlWithoutAPathFallsBackToTheDefaultPath() async throws {
        let (bot, _, _) = try Self.makeBot()
        let webhook = TelegramWebhookConfiguration(url: "https://bot.example.com")
        #expect(webhook.derivedPath == nil)
        #expect(TelegramWebhookConfiguration(url: "https://bot.example.com/").derivedPath == nil)

        let router = Router()
        router.registerTelegramWebhook(bot: bot, webhook: webhook)
        let app = Application(router: router)

        try await app.test(.router) { client in
            try await Self.post(client, path: "/telegram-webhook", secret: nil) { response in
                #expect(response.status == .ok)
            }
        }
        await bot.shutdown()
    }

    // MARK: - Service composition

    @Test func routerAddTelerouteRegistersTheEndpointAndReturnsBothServices() async throws {
        let (bot, _, _) = try Self.makeBot()
        let webhook = TelegramWebhookConfiguration(
            url: "https://bot.example.com/telegram",
            secretToken: "s3cret"
        )

        let router = Router()
        router.get("/health") { _, _ in "ok" }
        let services = router.addTeleroute(bot, webhook: webhook)

        #expect(services.count == 2)
        #expect(services[0] is TelerouteBot)
        #expect(services[1] is TelegramWebhookService)

        let app = Application(router: router, services: services)
        try await app.test(.router) { client in
            try await Self.post(client, path: "/telegram", secret: "s3cret") { response in
                #expect(response.status == .ok)
            }
            try await client.execute(uri: "/health", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
        await bot.shutdown()
    }

    @Test func applicationAddTelerouteAppendsTheSameServices() async throws {
        let (bot, _, _) = try Self.makeBot()
        let webhook = TelegramWebhookConfiguration(url: "https://bot.example.com/telegram")

        let router = Router()
        router.registerTelegramWebhook(bot: bot, webhook: webhook)
        var app = Application(router: router)
        #expect(app.services.isEmpty)

        app.addTeleroute(bot, webhook: webhook)
        #expect(app.services.count == 2)
        #expect(app.services[0] is TelerouteBot)
        #expect(app.services[1] is TelegramWebhookService)

        var botOnly = Application(router: Router())
        botOnly.addTeleroute(bot)
        #expect(botOnly.services.count == 1)
        #expect(botOnly.services[0] is TelerouteBot)

        await bot.shutdown()
    }

    @Test func applicationFactoryServesTheWebhookAndTheAppsOwnRoutes() async throws {
        let (bot, _, _) = try Self.makeBot()
        let webhook = TelegramWebhookConfiguration(
            url: "https://bot.example.com/telegram",
            secretToken: "s3cret"
        )

        let app = Application.teleroute(bot: bot, webhook: webhook) { router in
            router.get("/health") { _, _ in "ok" }
        }
        #expect(app.services.count == 2)

        try await app.test(.router) { client in
            try await Self.post(client, path: "/telegram", secret: "s3cret") { response in
                #expect(response.status == .ok)
            }
            try await Self.post(client, path: "/telegram", secret: "wrong") { response in
                #expect(response.status == .unauthorized)
            }
            try await client.execute(uri: "/health", method: .get) { response in
                #expect(response.status == .ok)
            }
        }
        await bot.shutdown()
    }

    // MARK: - Mode warning

    @Test func wiringAWebhookToAPollingBotIsReported() async throws {
        let warnings = TelerouteTestCallLog()
        let (bot, _, _) = try Self.makeBot(
            mode: .polling,
            logger: Logger(label: "tests.mode") { _ in
                TelerouteTestLogHandler { warnings.record($0) }
            }
        )

        _ = Router().addTeleroute(
            bot,
            webhook: .init(url: "https://bot.example.com/telegram")
        )

        let recorded = await warnings.waitForCount(1)
        #expect(recorded.first?.contains("polling mode") == true)

        // A bot already in webhook mode stays quiet.
        let quiet = TelerouteTestCallLog()
        let (webhookBot, _, _) = try Self.makeBot(
            logger: Logger(label: "tests.mode.quiet") { _ in
                TelerouteTestLogHandler { quiet.record($0) }
            }
        )
        _ = Router().addTeleroute(
            webhookBot,
            webhook: .init(url: "https://bot.example.com/telegram")
        )
        #expect(quiet.values.isEmpty)

        await bot.shutdown()
        await webhookBot.shutdown()
    }

    // MARK: - TelegramWebhookService

    @Test func webhookServiceRegistersAndRemovesTheWebhook() async throws {
        let calls = TelerouteTestCallLog()
        let router = Teleroute()
        router.command("start") { (_: TelerouteContext) -> Void in }

        // A bare transport rather than TelerouteRecordingTransport: the
        // recorder answers `deleteWebhook` itself, so it never reaches a
        // fallback and the shutdown call would go unobserved.
        let telegram = TelerouteTestCallLogTransport(log: calls)
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: .init(label: "tests.webhook.service"),
            configuration: .init(replayProtectionStorage: nil),
            mode: .webhook,
            transport: telegram,
            rateLimit: nil
        )

        let service = TelegramWebhookService(
            bot: bot,
            configuration: .init(
                url: "https://bot.example.com/telegram",
                secretToken: "s3cret",
                dropPendingUpdates: true,
                deleteWebhookOnShutdown: true
            )
        )
        let group = ServiceGroup(
            services: [service],
            gracefulShutdownSignals: [],
            logger: .init(label: "tests.webhook.group")
        )

        try await withThrowingTaskGroup(of: Void.self) { tasks in
            tasks.addTask { try await group.run() }

            let setWebhook = await calls.waitForCount(1)
            let call = try #require(setWebhook.first)
            #expect(call.hasPrefix("setWebhook:"))

            let payload = try Self.payload(of: call)
            #expect(payload["url"] as? String == "https://bot.example.com/telegram")
            #expect(payload["secret_token"] as? String == "s3cret")
            #expect(payload["drop_pending_updates"] as? Bool == true)
            // allowed_updates is derived from the registered routes: the bot
            // only has a command route, so only message-bearing kinds appear.
            let allowed = try #require(payload["allowed_updates"] as? [String])
            #expect(allowed.contains("message"))
            #expect(allowed.contains("callback_query") == false)

            await group.triggerGracefulShutdown()
            try await tasks.waitForAll()
        }

        let all = calls.values
        #expect(all.count == 2)
        #expect(all.last?.hasPrefix("deleteWebhook") == true)
        await bot.shutdown()
    }

    // MARK: - Secrets

    @Test func randomSecretUsesTelegramsAlphabetAndLength() {
        let allowed = Set("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-")

        let secret = TelegramWebhookConfiguration.randomSecret()
        #expect(secret.count == 32)
        #expect(secret.allSatisfy(allowed.contains))
        #expect(secret != TelegramWebhookConfiguration.randomSecret())

        #expect(TelegramWebhookConfiguration.randomSecret(length: 1).count == 1)
        #expect(TelegramWebhookConfiguration.randomSecret(length: 256).count == 256)
        // Out-of-range lengths are clamped rather than crashing.
        #expect(TelegramWebhookConfiguration.randomSecret(length: 0).count == 1)
        #expect(TelegramWebhookConfiguration.randomSecret(length: 999).count == 256)
    }

    // MARK: - Helpers

    private static func makeBot(
        mode: TelerouteBotMode = .webhook,
        logger: Logger = .init(label: "tests.webhook")
    ) throws -> (TelerouteBot, Teleroute<TelerouteContext>, TelerouteStubTransport) {
        let router = Teleroute()
        router.command("start") { (_: TelerouteContext) -> Void in }
        let transport = TelerouteStubTransport()
        let bot = try TelerouteBot(
            token: TelerouteTestSupport.testToken,
            router: router,
            logger: logger,
            configuration: .init(replayProtectionStorage: nil),
            mode: mode,
            transport: transport,
            rateLimit: nil
        )
        return (bot, router, transport)
    }

    /// Decodes the JSON body of a `operationID:{…}` log entry.
    private static func payload(of call: String) throws -> [String: Any] {
        let json = String(call.drop(while: { $0 != ":" }).dropFirst())
        let object = try JSONSerialization.jsonObject(with: Data(json.utf8))
        return try #require(object as? [String: Any])
    }

    private static func post(
        _ client: some TestClientProtocol,
        path: String,
        secret: String?,
        _ verify: @escaping @Sendable (TestResponse) throws -> Void
    ) async throws {
        var headers = HTTPFields()
        if let secret {
            headers[.init("X-Telegram-Bot-Api-Secret-Token")!] = secret
        }
        try await client.execute(
            uri: path,
            method: .post,
            headers: headers,
            body: .init(string: Self.update),
            testCallback: verify
        )
    }
}

/// Minimal log handler that forwards warning-level messages to a recorder.
struct TelerouteTestLogHandler: LogHandler {
    let onWarning: @Sendable (String) -> Void
    var metadata: Logger.Metadata = [:]
    var logLevel: Logger.Level = .trace

    init(onWarning: @escaping @Sendable (String) -> Void) {
        self.onWarning = onWarning
    }

    subscript(metadataKey key: String) -> Logger.Metadata.Value? {
        get { self.metadata[key] }
        set { self.metadata[key] = newValue }
    }

    func log(
        level: Logger.Level,
        message: Logger.Message,
        metadata: Logger.Metadata?,
        source: String,
        file: String,
        function: String,
        line: UInt
    ) {
        guard level >= .warning else { return }
        self.onWarning(message.description)
    }
}

/// Thread-safe call log for synchronous test hooks (transport fallbacks and
/// log handlers), where an actor's `await` is not available.
final class TelerouteTestCallLog: Sendable {
    private let storage = Mutex<[String]>([])

    func record(_ value: String) {
        self.storage.withLock { $0.append(value) }
    }

    var values: [String] {
        self.storage.withLock { $0 }
    }

    /// Polls until at least `count` entries are recorded, mirroring
    /// ``TelerouteTestRecorder/waitForCount(_:retries:)``.
    func waitForCount(_ count: Int, retries: Int = 50) async -> [String] {
        for _ in 0..<retries {
            let current = self.values
            if current.count >= count { return current }
            try? await Task.sleep(for: .milliseconds(10))
        }
        return self.values
    }
}

/// Transport that logs every operation and its body, then answers `ok: true`.
struct TelerouteTestCallLogTransport: TelegramTransport {
    let log: TelerouteTestCallLog

    func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        self.log.record("\(operationID):\(String(decoding: body ?? Data(), as: UTF8.self))")
        return (
            HTTPResponse(status: .ok),
            try JSONSerialization.data(withJSONObject: ["ok": true, "result": true])
        )
    }
}
