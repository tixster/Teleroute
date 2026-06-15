import Foundation
import SwiftTelegramBot

/// Route guards shipped with Teleroute. Attach them to routes or groups via the
/// `routeGuard:` / `routeGuards:` parameters.

/// Passes when the current update originates from a chat of the expected type.
public struct TelerouteChatTypeGuard: TelerouteGuard {
    private let expected: TGChatType

    /// Creates a guard that matches the supplied chat type.
    public init(_ expected: TGChatType) {
        self.expected = expected
    }

    public func matches(_ context: TelerouteContext) async throws -> Bool {
        context.chatType == self.expected
    }
}

/// Passes for private (1:1) chats only.
public struct TeleroutePrivateChatGuard: TelerouteGuard {
    public init() {}

    public func matches(_ context: TelerouteContext) async throws -> Bool {
        context.chatType == .private
    }
}

/// Passes for group and supergroup chats only.
public struct TelerouteGroupChatGuard: TelerouteGuard {
    public init() {}

    public func matches(_ context: TelerouteContext) async throws -> Bool {
        guard let type = context.chatType else { return false }
        return type == .group || type == .supergroup
    }
}

/// Passes when the sender's user id is in the supplied allow-list.
public struct TelerouteUserAllowlistGuard: TelerouteGuard {
    private let allowed: Set<Int64>

    /// Creates a guard that only allows the listed user identifiers.
    public init(_ allowed: Set<Int64>) {
        self.allowed = allowed
    }

    /// Convenience initializer from any sequence of user identifiers.
    public init<S: Sequence>(_ allowed: S) where S.Element == Int64 {
        self.allowed = Set(allowed)
    }

    public func matches(_ context: TelerouteContext) async throws -> Bool {
        guard let userId = context.userId else { return false }
        return self.allowed.contains(userId)
    }
}

/// Passes when the current chat id is in the supplied allow-list.
public struct TelerouteChatAllowlistGuard: TelerouteGuard {
    private let allowed: Set<Int64>

    /// Creates a guard that only allows the listed chat identifiers.
    public init(_ allowed: Set<Int64>) {
        self.allowed = allowed
    }

    /// Convenience initializer from any sequence of chat identifiers.
    public init<S: Sequence>(_ allowed: S) where S.Element == Int64 {
        self.allowed = Set(allowed)
    }

    public func matches(_ context: TelerouteContext) async throws -> Bool {
        guard let chatId = context.chatId else { return false }
        return self.allowed.contains(chatId)
    }
}

/// Passes when the command carries the expected number of arguments.
public struct TelerouteArgumentCountGuard: TelerouteGuard {
    private let expected: Int

    /// Creates a guard that requires exactly `expected` command arguments.
    public init(_ expected: Int) {
        self.expected = expected
    }

    public func matches(_ context: TelerouteContext) async throws -> Bool {
        (context.command?.arguments.count ?? -1) == self.expected
    }
}

/// Passes when the sender is an administrator or owner of the current chat.
///
/// This guard issues a `getChatMember` API call, so it must be attached to a
/// route whose handler is allowed to make network requests. It always rejects
/// updates that do not resolve to a chat id or a sender user id.
public struct TelerouteAdminGuard: TelerouteGuard {
    public init() {}

    public func matches(_ context: TelerouteContext) async throws -> Bool {
        guard let chatId = context.chatId, let userId = context.userId else {
            return false
        }
        let member = try await context.bot.getChatMember(
            params: .init(chatId: .chat(chatId), userId: userId)
        )
        switch member {
        case .chatMemberOwner, .chatMemberAdministrator:
            return true
        default:
            return false
        }
    }
}
