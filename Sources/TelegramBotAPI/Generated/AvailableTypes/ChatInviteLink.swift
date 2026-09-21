// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents an invite link for a chat.
public struct ChatInviteLink: Codable, Hashable, Sendable {
    /// The invite link. If the link was created by another chat administrator, then the second
    /// part of the link will be replaced with “…”.
    public var inviteLink: Swift.String

    private var creatorBox: _IndirectBox<User>
    /// Creator of the link
    public var creator: User {
        get { self.creatorBox.value }
        set { self.creatorBox = _IndirectBox(newValue) }
    }

    /// *True*, if users joining the chat via the link need to be approved by chat
    /// administrators
    public var createsJoinRequest: Swift.Bool

    /// *True*, if the link is primary
    public var isPrimary: Swift.Bool

    /// *True*, if the link is revoked
    public var isRevoked: Swift.Bool

    /// *Optional*. Invite link name
    public var name: Swift.String?

    /// *Optional*. Point in time (Unix timestamp) when the link will expire or has been expired
    public var expireDate: Swift.Int64?

    /// *Optional*. The maximum number of users that can be members of the chat simultaneously
    /// after joining the chat via this invite link; 1-99999
    public var memberLimit: Swift.Int64?

    /// *Optional*. Number of pending join requests created using this link
    public var pendingJoinRequestCount: Swift.Int64?

    /// *Optional*. The number of seconds the subscription will be active for before the next
    /// payment
    public var subscriptionPeriod: Swift.Int64?

    /// *Optional*. The amount of Telegram Stars a user must pay initially and after each
    /// subsequent subscription period to be a member of the chat using the link
    public var subscriptionPrice: Swift.Int64?

    public init(
        inviteLink: Swift.String,
        creator: User,
        createsJoinRequest: Swift.Bool,
        isPrimary: Swift.Bool,
        isRevoked: Swift.Bool,
        name: Swift.String? = nil,
        expireDate: Swift.Int64? = nil,
        memberLimit: Swift.Int64? = nil,
        pendingJoinRequestCount: Swift.Int64? = nil,
        subscriptionPeriod: Swift.Int64? = nil,
        subscriptionPrice: Swift.Int64? = nil
    ) {
        self.inviteLink = inviteLink
        self.creatorBox = _IndirectBox(creator)
        self.createsJoinRequest = createsJoinRequest
        self.isPrimary = isPrimary
        self.isRevoked = isRevoked
        self.name = name
        self.expireDate = expireDate
        self.memberLimit = memberLimit
        self.pendingJoinRequestCount = pendingJoinRequestCount
        self.subscriptionPeriod = subscriptionPeriod
        self.subscriptionPrice = subscriptionPrice
    }

    public enum CodingKeys: String, CodingKey {
        case inviteLink = "invite_link"
        case creatorBox = "creator"
        case createsJoinRequest = "creates_join_request"
        case isPrimary = "is_primary"
        case isRevoked = "is_revoked"
        case name
        case expireDate = "expire_date"
        case memberLimit = "member_limit"
        case pendingJoinRequestCount = "pending_join_request_count"
        case subscriptionPeriod = "subscription_period"
        case subscriptionPrice = "subscription_price"
    }
}
