import Foundation

/// Route guards shipped with Teleroute. Attach them to route scopes and routes
/// through the `guards:` parameter.
///
/// Every built-in guard accepts an optional `deny:` response. Without one, a
/// failing guard silently skips the route (matching falls through to the next
/// candidate); with one, the route consumes the update and responds — e.g.
/// `TelerouteAdminGuard(deny: .reply("Admins only"))`.

/// Passes when the current update originates from a chat of the expected type.
public struct TelerouteChatTypeGuard: TelerouteGuard {
    private let expected: ChatType
    private let deny: TelerouteResponse?

    /// Creates a guard that matches the supplied chat type.
    public init(_ expected: ChatType, deny: TelerouteResponse? = nil) {
        self.expected = expected
        self.deny = deny
    }

    public func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        context.chatType == self.expected ? .allow : self.deny.map(TelerouteGuardResult.deny) ?? .skip
    }
}

/// Passes for private (1:1) chats only.
public struct TeleroutePrivateChatGuard: TelerouteGuard {
    private let deny: TelerouteResponse?

    public init(deny: TelerouteResponse? = nil) {
        self.deny = deny
    }

    public func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        context.chatType == .private ? .allow : self.deny.map(TelerouteGuardResult.deny) ?? .skip
    }
}

/// Passes for group and supergroup chats only.
public struct TelerouteGroupChatGuard: TelerouteGuard {
    private let deny: TelerouteResponse?

    public init(deny: TelerouteResponse? = nil) {
        self.deny = deny
    }

    public func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        let allowed = context.chatType == .group || context.chatType == .supergroup
        return allowed ? .allow : self.deny.map(TelerouteGuardResult.deny) ?? .skip
    }
}

/// Passes when the sender's user id is in the supplied allow-list.
public struct TelerouteUserAllowlistGuard: TelerouteGuard {
    private let allowed: Set<Int64>
    private let deny: TelerouteResponse?

    /// Creates a guard that only allows the listed user identifiers.
    public init(_ allowed: Set<Int64>, deny: TelerouteResponse? = nil) {
        self.allowed = allowed
        self.deny = deny
    }

    /// Convenience initializer from any sequence of user identifiers.
    public init<S: Sequence>(_ allowed: S, deny: TelerouteResponse? = nil) where S.Element == Int64 {
        self.allowed = Set(allowed)
        self.deny = deny
    }

    public func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        guard let userId = context.userId, self.allowed.contains(userId) else {
            return self.deny.map(TelerouteGuardResult.deny) ?? .skip
        }
        return .allow
    }
}

/// Passes when the current chat id is in the supplied allow-list.
public struct TelerouteChatAllowlistGuard: TelerouteGuard {
    private let allowed: Set<Int64>
    private let deny: TelerouteResponse?

    /// Creates a guard that only allows the listed chat identifiers.
    public init(_ allowed: Set<Int64>, deny: TelerouteResponse? = nil) {
        self.allowed = allowed
        self.deny = deny
    }

    /// Convenience initializer from any sequence of chat identifiers.
    public init<S: Sequence>(_ allowed: S, deny: TelerouteResponse? = nil) where S.Element == Int64 {
        self.allowed = Set(allowed)
        self.deny = deny
    }

    public func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        guard let chatId = context.chatId, self.allowed.contains(chatId) else {
            return self.deny.map(TelerouteGuardResult.deny) ?? .skip
        }
        return .allow
    }
}

/// Passes when the command carries the expected number of arguments.
public struct TelerouteArgumentCountGuard: TelerouteGuard {
    private let expected: Int
    private let deny: TelerouteResponse?

    /// Creates a guard that requires exactly `expected` command arguments.
    public init(_ expected: Int, deny: TelerouteResponse? = nil) {
        self.expected = expected
        self.deny = deny
    }

    public func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        let matches = (context.command?.arguments.count ?? -1) == self.expected
        return matches ? .allow : self.deny.map(TelerouteGuardResult.deny) ?? .skip
    }
}

/// Passes when the sender is an administrator or owner of the current chat.
///
/// This guard issues a `getChatMember` API call, so it must be attached to a
/// route whose handler is allowed to make network requests. It always rejects
/// updates that do not resolve to a chat id or a sender user id.
public struct TelerouteAdminGuard: TelerouteGuard {
    private let deny: TelerouteResponse?

    public init(deny: TelerouteResponse? = nil) {
        self.deny = deny
    }

    public func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        guard let chatId = context.chatId, let userId = context.userId else {
            return self.deny.map(TelerouteGuardResult.deny) ?? .skip
        }
        let member = try await context.bot.getChatMember(
            chatId: .id(chatId),
            userId: userId
        )
        switch member {
        case .creator, .administrator:
            return .allow
        default:
            return self.deny.map(TelerouteGuardResult.deny) ?? .skip
        }
    }
}
