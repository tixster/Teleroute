import SwiftTelegramBot
import Foundation

/// Describes a typed Telegram command route.
///
/// Use this to decode a raw `TelerouteCommandMatch` into a domain-specific command value.
public protocol TelerouteCommand: Sendable {
    /// Command path relative to the current group.
    ///
    /// Example: `"start"` or `"ban"`.
    static var path: String { get }

    /// Optional bot username restriction for commands using the `@botname` suffix.
    static var botUsername: String? { get }

    /// Optional command description used when publishing Telegram bot commands.
    static var commandDescription: String? { get }

    /// Visibility scopes used when publishing Telegram bot commands.
    static var visibility: [TelerouteCommandVisibility] { get }

    /// Optional queueing strategy for serializing command execution.
    static var queueing: TelerouteCommandQueueing? { get }

    /// Creates a typed command from the parsed command match.
    init(command: TelerouteCommandMatch) throws

    /// Handles the command after it has been decoded from the incoming update.
    func handle(update: TGUpdate, context: TelerouteContext) async throws
}

public extension TelerouteCommand {
    static var botUsername: String? { nil }
    static var commandDescription: String? { nil }
    static var visibility: [TelerouteCommandVisibility] { [.default] }
    static var queueing: TelerouteCommandQueueing? { nil }

    func handle(update: TGUpdate, context: TelerouteContext) async throws {}
}
