import Foundation
import Teleroute

/// Executable entry point for the package example.
///
/// The app itself stays intentionally small: it loads configuration, creates the
/// Telegram bot and router, mounts the documented example routes, and then hands
/// execution over to the long-polling runtime.
@main
enum TelerouteExampleApp {
    static func main() async throws {
        let environment = try ExampleEnvironment.load()
        let bot = try await ExampleBootstrap.makeBot(environment: environment)
        let router = ExampleBootstrap.makeRouter(bot: bot)

        ExampleRouterConfiguration.configure(router: router)
        try await ExampleBootstrap.publishCommandsAndStart(router: router, bot: bot)
    }
}
