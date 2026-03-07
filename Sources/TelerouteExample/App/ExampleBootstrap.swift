import Foundation
import Teleroute

/// Startup helpers for the example executable.
///
/// This file owns process-level concerns:
/// - constructing loggers
/// - creating the bot and router
/// - publishing command menus
/// - keeping the process alive after long polling starts
enum ExampleBootstrap {
    /// Creates the Telegram bot used by the example.
    static func makeBot(environment: ExampleEnvironment) async throws -> TGBot {
        try await TGBot(
            connectionType: .longpolling(),
            tgClient: TGClientDefault(),
            botId: environment.botToken,
            log: ExampleLoggerFactory.makeBotLogger()
        )
    }

    /// Creates the router with example-friendly debug instrumentation.
    static func makeRouter(bot: TGBot) -> Teleroute {
        Teleroute(
            bot: bot,
            logger: ExampleLoggerFactory.makeRouterLogger(),
            flowStorage: TelerouteInMemoryFlowStorage(),
            replayProtectionStorage: TelerouteInMemoryReplayProtectionStorage(),
            replayProtectionTTL: .seconds(3)
        )
    }

    /// Publishes command menus, attaches the router to the bot, and starts polling.
    static func publishCommandsAndStart(router: Teleroute, bot: TGBot) async throws {
        for commandSet in try router.publishedCommandSets() {
            router.log.info(
                "Prepared \(commandSet.commands.count) published commands for scope \(String(describing: commandSet.visibility.scope))"
            )
        }

        try await router.publishCommands(
            [("health", "Check bot health")],
            visibility: .allChatAdministrators
        )
        try await router.publishCommands([ProfileCommand.self])
        try await router.syncPublishedCommands()
        try await bot.add(router: router)

        router.log.info("Starting TelerouteExample")
        _ = try await bot.start()

        // `swift-telegram-bot` starts long polling in a detached task and returns immediately.
        // Keep the executable alive so the polling task is not torn down when `main` exits.
        while true {
            try await Task.sleep(for: .seconds(86_400))
        }
    }
}
