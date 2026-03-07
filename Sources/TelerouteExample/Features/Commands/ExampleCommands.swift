import Teleroute

/// Typed command that decodes a username-like argument and replies with a stub profile.
///
/// This demonstrates the simplest typed-command shape:
/// - static route metadata
/// - argument decoding from `TelerouteCommandMatch`
/// - command-owned handling logic
struct ProfileCommand: TelerouteCommand {
    static let path = "profile"
    static let commandDescription: String? = "Show a user profile"
    static let visibility: [TelerouteCommandVisibility] = [.allPrivateChats]

    let username: String

    init(command: TelerouteCommandMatch) throws {
        self.username = try command.require("username")
    }

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        try await context.reply(text: "Profile for \(self.username)")
    }
}

/// Typed command that opts into per-chat-per-user queueing.
///
/// This demonstrates how commands that touch mutable state or long-running jobs
/// can declare a default queueing strategy directly on the spec.
struct SyncCatalogCommand: TelerouteCommand {
    static let path = "sync_catalog"
    static let commandDescription: String? = "Synchronize catalog items"
    static let visibility: [TelerouteCommandVisibility] = [.allPrivateChats]
    static let queueing: TelerouteCommandQueueing? = .chatUser

    init(command: TelerouteCommandMatch) throws {}

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        try await context.reply(text: "Catalog sync queued for this chat/user.")
    }
}

/// Typed command mounted inside the `admin` route group.
///
/// Its `path` remains `"ban"`, but when mounted into `router.group("admin")`
/// the effective Telegram command becomes `/admin_ban`.
struct AdminBanCommand: TelerouteCommand {
    static let path = "ban"
    static let commandDescription: String? = "Ban a user"
    static let visibility: [TelerouteCommandVisibility] = [.allChatAdministrators]

    let userID: String
    let reason: String?

    init(command: TelerouteCommandMatch) throws {
        self.userID = try command.require("userID")
        self.reason = command.get("reason", at: 1)
    }
}
