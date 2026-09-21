import Foundation
import Teleroute

/// Startup helpers for the example executable.
///
/// This file owns process-level concerns:
/// - constructing loggers
/// - creating the bot-independent route graph and running `TelerouteBot`
enum ExampleBootstrap {
    /// Creates and configures the bot-independent route graph.
    static func makeRouter() -> Teleroute<ExampleRequestContext> {
        let router = Teleroute(context: ExampleRequestContext.self)
        router.middlewares.add(ExampleRequestIDMiddleware())
        router.addRoutes(ExampleRouterConfiguration())
        return router
    }

    /// Creates the routed bot that owns the Telegram client and lifecycle.
    static func makeTelerouteBot(
        environment: ExampleEnvironment,
        router: Teleroute<ExampleRequestContext>
    ) throws -> TelerouteBot {
        try TelerouteBot(
            token: environment.botToken,
            router: router,
            logger: ExampleLoggerFactory.makeRouterLogger(),
            configuration: .init(
                flowStorage: TelerouteInMemoryFlowStorage(),
                replayProtectionStorage: TelerouteInMemoryReplayProtectionStorage(),
                replayProtectionTTL: .seconds(3),
                maximumConcurrentUpdates: 32,
                // The example exposes explicit `/cancel_signup` and `/resume_signup`
                // commands, so unrelated commands do not tear down the flow.
                flowCancellationPolicy: .manual,
                syncPublishedCommandsOnStart: true,
                // Required by the `/confirm` buttons, which carry their
                // handlers rather than dispatching to a callback route.
                inlineActions: .enabled()
            )
        )
    }

    /// Logs the generated command menus and runs long polling until the
    /// process is asked to stop.
    static func run(
        bot: TelerouteBot,
        router: Teleroute<ExampleRequestContext>
    ) async throws {
        for commandSet in try router.publishedCommandSets() {
            bot.logger.info(
                "Prepared \(commandSet.commands.count) published commands for scope \(String(describing: commandSet.visibility.scope))"
            )
        }

        bot.logger.info("Starting TelerouteExample")
        // `runService` turns SIGTERM/SIGINT into a graceful drain; `run()`
        // would rely on the surrounding task being cancelled instead.
        try await bot.runService()
    }
}
