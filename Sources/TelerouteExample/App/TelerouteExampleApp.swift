import Foundation
import Teleroute

/// Executable entry point for the package example.
///
/// The executable stays intentionally small: it loads configuration, creates
/// the Telegram transport and routes, and hands execution to `TelerouteBot`.
@main
enum TelerouteExampleApp {
    static func main() async throws {
        let environment = try ExampleEnvironment.load()
        let telegramBot = try await ExampleBootstrap.makeTelegramBot(
            environment: environment
        )
        let router = ExampleBootstrap.makeRouter()
        let bot = ExampleBootstrap.makeTelerouteBot(
            telegramBot: telegramBot,
            router: router
        )

        try await ExampleBootstrap.run(bot: bot, router: router)
    }
}
