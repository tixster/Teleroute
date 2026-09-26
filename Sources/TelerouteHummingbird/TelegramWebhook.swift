import Foundation
import HTTPTypes
import Hummingbird
import ServiceLifecycle
import Teleroute

/// Configuration for a Telegram webhook endpoint served by Hummingbird.
public struct TelegramWebhookConfiguration: Sendable {
    /// Public HTTPS URL Telegram delivers updates to.
    public var url: String
    /// Secret token Telegram echoes in `X-Telegram-Bot-Api-Secret-Token`;
    /// requests without a matching token are rejected with 401.
    public var secretToken: String?
    /// Drops the pending update backlog when the webhook is registered.
    public var dropPendingUpdates: Bool?
    /// Update kinds Telegram should deliver.
    public var allowedUpdates: TelerouteAllowedUpdates
    /// Deletes the webhook during graceful shutdown.
    public var deleteWebhookOnShutdown: Bool

    public init(
        url: String,
        secretToken: String? = nil,
        dropPendingUpdates: Bool? = nil,
        allowedUpdates: TelerouteAllowedUpdates = .automatic,
        deleteWebhookOnShutdown: Bool = false
    ) {
        self.url = url
        self.secretToken = secretToken
        self.dropPendingUpdates = dropPendingUpdates
        self.allowedUpdates = allowedUpdates
        self.deleteWebhookOnShutdown = deleteWebhookOnShutdown
    }
}

public extension TelegramWebhookConfiguration {
    /// Path Telegram posts updates to, derived from ``url``.
    ///
    /// Returns `nil` when the URL carries no path, in which case the
    /// endpoint helpers fall back to their default path.
    var derivedPath: String? {
        guard let path = URLComponents(string: self.url)?.path, path.isEmpty == false, path != "/" else {
            return nil
        }
        return path
    }

    /// Generates a cryptographically random secret token.
    ///
    /// Telegram accepts 1-256 characters from `A-Z`, `a-z`, `0-9`, `_` and
    /// `-`; the generated value uses exactly that alphabet, so it can be
    /// passed straight to `setWebhook`.
    ///
    /// ```swift
    /// let webhook = TelegramWebhookConfiguration(
    ///     url: "https://bot.example.com/telegram",
    ///     secretToken: .randomSecret()
    /// )
    /// ```
    static func randomSecret(length: Int = 32) -> String {
        let alphabet = Array("ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_-")
        let count = min(max(length, 1), 256)
        var generator = SystemRandomNumberGenerator()
        return String((0..<count).map { _ in
            alphabet[Int.random(in: 0..<alphabet.count, using: &generator)]
        })
    }
}

extension HTTPField.Name {
    static let telegramSecretToken = HTTPField.Name("X-Telegram-Bot-Api-Secret-Token")!
}

public extension RouterMethods {
    /// Registers the Telegram webhook endpoint on this router.
    ///
    /// The handler verifies `X-Telegram-Bot-Api-Secret-Token` (when a secret
    /// is configured), decodes the `Update`, and feeds it to the bot's update
    /// pipeline. Run the bot in webhook mode (`TelerouteBotMode.webhook`) so
    /// it does not also poll.
    ///
    /// ```swift
    /// let router = Router()
    /// router.registerTelegramWebhook(bot: bot, path: "/telegram", secretToken: secret)
    /// ```
    @discardableResult
    func registerTelegramWebhook(
        bot: TelerouteBot,
        path: RouterPath = "/telegram-webhook",
        secretToken: String? = nil,
        maxBodySize: Int = 1024 * 1024
    ) -> Self {
        self.post(path) { request, context -> HTTPResponse.Status in
            if let secretToken {
                let provided = request.headers[.telegramSecretToken] ?? ""
                guard constantTimeEquals(provided, secretToken) else {
                    throw HTTPError(.unauthorized)
                }
            }
            let body = try await request.body.collect(upTo: maxBodySize)
            let update: Update
            do {
                update = try JSONDecoder().decode(Update.self, from: body)
            } catch {
                context.logger.debug(
                    "Failed to decode Telegram update",
                    metadata: ["error": .string(String(reflecting: error))]
                )
                throw HTTPError(.badRequest)
            }
            await bot.process([update])
            return .ok
        }
        return self
    }
}

/// Registers the webhook with Telegram on startup and parks until graceful
/// shutdown. Compose it in a `ServiceGroup` next to the Hummingbird
/// application and the bot itself:
///
/// ```swift
/// let group = ServiceGroup(
///     services: [app, bot, TelegramWebhookService(bot: bot, configuration: webhook)],
///     gracefulShutdownSignals: [.sigterm, .sigint],
///     logger: logger
/// )
/// ```
public struct TelegramWebhookService: Service {
    private let bot: TelerouteBot
    private let configuration: TelegramWebhookConfiguration

    public init(bot: TelerouteBot, configuration: TelegramWebhookConfiguration) {
        self.bot = bot
        self.configuration = configuration
    }

    public func run() async throws {
        try await self.bot.client.setWebhook(
            url: self.configuration.url,
            allowedUpdates: self.bot.resolvedAllowedUpdates(self.configuration.allowedUpdates),
            dropPendingUpdates: self.configuration.dropPendingUpdates,
            secretToken: self.configuration.secretToken
        )
        self.bot.logger.info(
            "Telegram webhook registered",
            metadata: ["url": .string(self.configuration.url)]
        )
        _ = try? await gracefulShutdown()
        if self.configuration.deleteWebhookOnShutdown {
            _ = try? await self.bot.client.deleteWebhook()
        }
    }
}

/// Compares two strings in constant time to avoid timing side channels on the
/// webhook secret.
func constantTimeEquals(_ lhs: String, _ rhs: String) -> Bool {
    let lhsBytes = Array(lhs.utf8)
    let rhsBytes = Array(rhs.utf8)
    guard lhsBytes.count == rhsBytes.count else { return false }
    var difference: UInt8 = 0
    for index in lhsBytes.indices {
        difference |= lhsBytes[index] ^ rhsBytes[index]
    }
    return difference == 0
}
