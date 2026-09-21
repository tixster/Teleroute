import Foundation
import Hummingbird
import Logging
import ServiceLifecycle
import Teleroute

/// Default path used when a webhook URL carries no path of its own.
let defaultTelegramWebhookPath: RouterPath = "/telegram-webhook"

/// Builds the services a webhook-delivered bot needs, in start order, and
/// warns when the bot would also poll.
///
/// Every public entry point funnels through here so the three of them cannot
/// drift apart.
func telerouteWebhookServices(
    bot: TelerouteBot,
    webhook: TelegramWebhookConfiguration?
) -> [any Service] {
    guard let webhook else { return [bot] }
    if bot.mode == .polling {
        bot.logger.warning(
            """
            A Telegram webhook is configured, but the bot runs in polling mode. \
            Telegram rejects getUpdates while a webhook is set — create the bot \
            with TelerouteBot(mode: .webhook).
            """,
            metadata: ["url": .string(webhook.url)]
        )
    }
    return [bot, TelegramWebhookService(bot: bot, configuration: webhook)]
}

public extension RouterMethods {
    /// Registers the Telegram webhook endpoint from a single configuration.
    ///
    /// The path is taken from `webhook.url` and the secret from
    /// `webhook.secretToken`, so the two values a hand-wired setup has to keep
    /// in sync — the registered path and the path inside the public URL —
    /// cannot drift apart:
    ///
    /// ```swift
    /// let webhook = TelegramWebhookConfiguration(
    ///     url: "https://bot.example.com/telegram",
    ///     secretToken: .randomSecret()
    /// )
    /// router.registerTelegramWebhook(bot: bot, webhook: webhook)
    /// ```
    ///
    /// - Parameters:
    ///   - bot: Bot whose pipeline receives the decoded updates.
    ///   - webhook: Supplies the endpoint path and the shared secret.
    ///   - path: Overrides the path derived from the URL, for deployments
    ///     where a reverse proxy rewrites it.
    ///   - maxBodySize: Largest accepted request body, in bytes.
    @discardableResult
    func registerTelegramWebhook(
        bot: TelerouteBot,
        webhook: TelegramWebhookConfiguration,
        path: RouterPath? = nil,
        maxBodySize: Int = 1024 * 1024
    ) -> Self {
        self.registerTelegramWebhook(
            bot: bot,
            path: path ?? webhook.derivedPath.map { RouterPath($0) } ?? defaultTelegramWebhookPath,
            secretToken: webhook.secretToken,
            maxBodySize: maxBodySize
        )
    }
}

public extension Router {
    /// Registers the webhook endpoint and returns the services the application
    /// must run: the bot itself and the webhook registration.
    ///
    /// Because `Application(router:)` builds its responder during
    /// initialization, the endpoint has to be registered before the
    /// application exists — so this does both halves in one expression:
    ///
    /// ```swift
    /// let hbRouter = Router()
    /// hbRouter.get("/health") { _, _ in "ok" }
    ///
    /// let app = Application(
    ///     router: hbRouter,
    ///     configuration: .init(address: .hostname("0.0.0.0", port: 8080)),
    ///     services: hbRouter.addTeleroute(bot, webhook: webhook)
    /// )
    /// try await app.runService()
    /// ```
    ///
    /// - Parameters:
    ///   - bot: Bot whose pipeline receives the decoded updates.
    ///   - webhook: Supplies the endpoint path and the shared secret, and
    ///     configures the `setWebhook` call made on startup.
    ///   - path: Overrides the path derived from the URL.
    ///   - maxBodySize: Largest accepted request body, in bytes.
    /// - Returns: The bot and its webhook registration, in start order.
    @discardableResult
    func addTeleroute(
        _ bot: TelerouteBot,
        webhook: TelegramWebhookConfiguration,
        path: RouterPath? = nil,
        maxBodySize: Int = 1024 * 1024
    ) -> [any Service] {
        self.registerTelegramWebhook(
            bot: bot,
            webhook: webhook,
            path: path,
            maxBodySize: maxBodySize
        )
        return telerouteWebhookServices(bot: bot, webhook: webhook)
    }
}

public extension Application {
    /// Adds the bot — and, when a webhook is configured, its registration with
    /// Telegram — to the application's services.
    ///
    /// The endpoint itself must already be registered on the router, since a
    /// built application can no longer gain routes. Use
    /// ``Hummingbird/Router/addTeleroute(_:webhook:path:maxBodySize:)`` to do
    /// both in one call, or ``teleroute(bot:webhook:configuration:logger:maxBodySize:routes:)``
    /// to have the whole application built for you.
    ///
    /// Passing `nil` for `webhook` adds only the bot, for deployments where
    /// `setWebhook` is run by a deploy script rather than the process.
    mutating func addTeleroute(
        _ bot: TelerouteBot,
        webhook: TelegramWebhookConfiguration? = nil
    ) {
        self.addServices(telerouteWebhookServices(bot: bot, webhook: webhook))
    }
}

public extension Application where Responder == RouterResponder<BasicRequestContext> {
    /// Builds a Hummingbird application that serves the bot's webhook.
    ///
    /// It creates the router, registers the endpoint at the path taken from
    /// `webhook.url`, and attaches both the bot and its webhook registration
    /// as services — so the whole deployment is two statements:
    ///
    /// ```swift
    /// let app = Application.teleroute(
    ///     bot: bot,
    ///     webhook: webhook,
    ///     configuration: .init(address: .hostname("0.0.0.0", port: 8080))
    /// ) { router in
    ///     router.get("/health") { _, _ in "ok" }
    /// }
    /// try await app.runService()
    /// ```
    ///
    /// The result is an ordinary `Application`, so `addServices(_:)`,
    /// `beforeServerStarts(perform:)` and `test(_:)` all remain available.
    ///
    /// - Parameters:
    ///   - bot: Bot whose pipeline receives the decoded updates.
    ///   - webhook: Supplies the endpoint path and the shared secret, and
    ///     configures the `setWebhook` call made on startup.
    ///   - configuration: Hummingbird application configuration, such as the
    ///     bind address.
    ///   - logger: Logger for the application; defaults to Hummingbird's own.
    ///   - maxBodySize: Largest accepted request body, in bytes.
    ///   - routes: Registers the application's own routes alongside the
    ///     webhook endpoint.
    static func teleroute(
        bot: TelerouteBot,
        webhook: TelegramWebhookConfiguration,
        configuration: ApplicationConfiguration = .init(),
        logger: Logger? = nil,
        maxBodySize: Int = 1024 * 1024,
        routes: (Router<BasicRequestContext>) -> Void = { _ in }
    ) -> Self {
        let router = Router()
        routes(router)
        let services = router.addTeleroute(
            bot,
            webhook: webhook,
            maxBodySize: maxBodySize
        )
        return Application(
            router: router,
            configuration: configuration,
            services: services,
            logger: logger
        )
    }
}
