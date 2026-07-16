/// Describes a typed Telegram command route.
public protocol TelerouteCommand: Sendable {
    /// Command path relative to the current route scope.
    static var path: String { get }

    /// Optional bot username restriction for commands using the `@botname` suffix.
    static var botUsername: String? { get }

    /// Optional description used when publishing Telegram bot commands.
    static var commandDescription: String? { get }

    /// Visibility scopes used when publishing Telegram bot commands.
    static var visibility: [TelerouteCommandVisibility] { get }

    /// Optional default scope for serializing command execution.
    static var queue: TelerouteQueueScope? { get }

    /// Creates a typed command from the parsed command match.
    init(command: TelerouteCommandMatch) throws
}

/// A typed command that handles its own matched update.
///
/// This is convenient for small, self-contained commands. Prefer registering an
/// explicit handler from a ``TelerouteRouteCollection`` when the handler owns injected
/// dependencies or coordinates multiple routes.
public protocol TelerouteHandlingCommand: TelerouteCommand {
    /// Handles the update after the command value has been decoded.
    func handle(context: TelerouteContext) async throws
}

public extension TelerouteCommand {
    static var botUsername: String? { nil }
    static var commandDescription: String? { nil }
    static var visibility: [TelerouteCommandVisibility] { [.default] }
    static var queue: TelerouteQueueScope? { nil }
}
