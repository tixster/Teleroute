// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Describes the current status of a webhook.
public struct WebhookInfo: Codable, Hashable, Sendable {
    /// Webhook URL, may be empty if webhook is not set up
    public var url: Swift.String

    /// *True*, if a custom certificate was provided for webhook certificate checks
    public var hasCustomCertificate: Swift.Bool

    /// Number of updates awaiting delivery
    public var pendingUpdateCount: Swift.Int64

    /// *Optional*. Currently used webhook IP address
    public var ipAddress: Swift.String?

    /// *Optional*. Unix time for the most recent error that happened when trying to deliver an
    /// update via webhook
    public var lastErrorDate: Swift.Int64?

    /// *Optional*. Error message in human-readable format for the most recent error that
    /// happened when trying to deliver an update via webhook
    public var lastErrorMessage: Swift.String?

    /// *Optional*. Unix time of the most recent error that happened when trying to synchronize
    /// available updates with Telegram datacenters
    public var lastSynchronizationErrorDate: Swift.Int64?

    /// *Optional*. The maximum allowed number of simultaneous HTTPS connections to the webhook
    /// for update delivery
    public var maxConnections: Swift.Int64?

    /// *Optional*. A list of update types the bot is subscribed to. Defaults to all update
    /// types except *chat_member*, *message_reaction*, and *message_reaction_count*.
    public var allowedUpdates: [Swift.String]?

    public init(
        url: Swift.String,
        hasCustomCertificate: Swift.Bool,
        pendingUpdateCount: Swift.Int64,
        ipAddress: Swift.String? = nil,
        lastErrorDate: Swift.Int64? = nil,
        lastErrorMessage: Swift.String? = nil,
        lastSynchronizationErrorDate: Swift.Int64? = nil,
        maxConnections: Swift.Int64? = nil,
        allowedUpdates: [Swift.String]? = nil
    ) {
        self.url = url
        self.hasCustomCertificate = hasCustomCertificate
        self.pendingUpdateCount = pendingUpdateCount
        self.ipAddress = ipAddress
        self.lastErrorDate = lastErrorDate
        self.lastErrorMessage = lastErrorMessage
        self.lastSynchronizationErrorDate = lastSynchronizationErrorDate
        self.maxConnections = maxConnections
        self.allowedUpdates = allowedUpdates
    }

    public enum CodingKeys: String, CodingKey {
        case url
        case hasCustomCertificate = "has_custom_certificate"
        case pendingUpdateCount = "pending_update_count"
        case ipAddress = "ip_address"
        case lastErrorDate = "last_error_date"
        case lastErrorMessage = "last_error_message"
        case lastSynchronizationErrorDate = "last_synchronization_error_date"
        case maxConnections = "max_connections"
        case allowedUpdates = "allowed_updates"
    }
}
