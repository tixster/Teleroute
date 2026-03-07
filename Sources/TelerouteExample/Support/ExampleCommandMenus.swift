import Teleroute

/// Command menu definitions used by the example.
///
/// Teleroute can publish commands from registered route metadata, but an explicit
/// list is still useful for two cases demonstrated by the example:
/// - repairing a stale Telegram `chat` scope for one conversation
/// - publishing grouped commands whose effective Telegram name differs from the
///   typed command's raw `path`
enum ExampleCommandMenus {
    /// Private-chat command menu used for chat-scoped menu repair.
    static let privateChat: [(command: String, description: String)] = [
        ("start", "Show the example menu"),
        ("profile", "Show a user profile"),
        ("sync_catalog", "Synchronize catalog items"),
        ("signup", "Start a multi-step signup flow"),
        ("resume_signup", "Restart the signup flow"),
        ("cancel_signup", "Cancel the active signup flow"),
        ("billing_invoice", "Open an invoice"),
        ("diag_ping", "Check diagnostics connectivity"),
        ("refresh_menu", "Reset and republish this chat's menu"),
    ]
}
