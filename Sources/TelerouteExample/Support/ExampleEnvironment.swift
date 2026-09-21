import Foundation
import Teleroute

/// Runtime configuration for the example executable.
///
/// The example deliberately reads only one value from the environment:
/// `TELEGRAM_BOT_TOKEN`. This keeps local setup simple and makes the example
/// easy to launch directly with `swift run`.
struct ExampleEnvironment {
    /// Telegram bot token used for Bot API requests.
    let botToken: String

    /// Loads configuration from the current process environment.
    ///
    /// `TelerouteEnvironment.token()` does the reading and blank-value
    /// rejection; the example only re-labels the failure so `swift run`
    /// prints the command to fix it.
    static func load() throws -> Self {
        do {
            return .init(botToken: try TelerouteEnvironment.token())
        } catch {
            throw ExampleError.missingBotToken
        }
    }
}
