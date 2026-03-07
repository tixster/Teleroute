import Foundation

/// Runtime configuration for the example executable.
///
/// The example deliberately reads only one value from the environment:
/// `TELEGRAM_BOT_TOKEN`. This keeps local setup simple and makes the example
/// easy to launch directly with `swift run`.
struct ExampleEnvironment {
    /// Telegram bot token used for Bot API requests.
    let botToken: String

    /// Loads configuration from the current process environment.
    static func load(
        from environment: [String: String] = ProcessInfo.processInfo.environment
    ) throws -> Self {
        guard let botToken = environment["TELEGRAM_BOT_TOKEN"], botToken.isEmpty == false else {
            throw ExampleError.missingBotToken
        }
        return .init(botToken: botToken)
    }
}
