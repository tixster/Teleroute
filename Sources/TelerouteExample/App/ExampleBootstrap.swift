import Foundation
import Teleroute

/// Startup helpers for the example executable.
///
/// This file owns process-level concerns:
/// - constructing loggers
/// - creating the bot-independent route graph and running `TelerouteBot`
enum ExampleBootstrap {
    /// Creates the underlying Telegram transport used by the example.
    static func makeTelegramBot(
        environment: ExampleEnvironment
    ) async throws -> TGBot {
        try await TGBot(
            connectionType: .longpolling(),
            tgClient: TGClientDefault(),
            botId: environment.botToken,
            log: ExampleLoggerFactory.makeBotLogger()
        )
    }

    /// Creates and configures the bot-independent route graph.
    static func makeRouter() -> Teleroute<ExampleRequestContext> {
        let router = Teleroute(context: ExampleRequestContext.self)
        router.middlewares.add(ExampleRequestIDMiddleware())
        router.addRoutes(ExampleRouterConfiguration())
        return router
    }

    /// Creates the routed bot that owns the Telegram lifecycle.
    static func makeTelerouteBot(
        telegramBot: TGBot,
        router: Teleroute<ExampleRequestContext>
    ) -> TelerouteBot {
        TelerouteBot(
            bot: telegramBot,
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
                syncPublishedCommandsOnStart: true
            )
        )
    }

    /// Logs the generated command menus and runs long polling until cancelled.
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
        try await bot.run()
    }
}
