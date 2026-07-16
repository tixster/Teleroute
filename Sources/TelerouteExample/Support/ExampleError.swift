import Foundation

/// Errors surfaced by the example executable before the router starts.
enum ExampleError: LocalizedError {
    case missingBotToken
    case userMissing

    var errorDescription: String? {
        switch self {
        case .missingBotToken:
            return "Set TELEGRAM_BOT_TOKEN before running `swift run TelerouteExample`."
        case .userMissing:
            return "The Telegram update does not contain a user."
        }
    }
}
