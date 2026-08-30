import Foundation
import Teleroute

/// Executable entry point for the package example.
///
/// The executable stays intentionally small: it loads configuration, creates
/// the routes, and hands execution to `TelerouteBot`.
@main
enum TelerouteExampleApp {
    static func main() async throws {
        let environment = try ExampleEnvironment.load()
        let router = ExampleBootstrap.makeRouter()
        let bot = try ExampleBootstrap.makeTelerouteBot(
            environment: environment,
            router: router
        )

        try await ExampleBootstrap.run(bot: bot, router: router)
    }
}
