import Foundation
import Logging
import SwiftTelegramBot

/// Errors raised by the routed bot lifecycle.
public enum TelerouteBotError: Error, Equatable, Sendable {
    /// The bot was shut down and cannot be started again.
    case stopped
}

/// Running Telegram bot built from a bot-independent ``Teleroute`` route graph.
public final class TelerouteBot: Sendable {
    public typealias Configuration = TelerouteConfiguration

    private let runtime: TelerouteRuntime
    private let configuration: Configuration
    private let lifecycle = TelerouteBotLifecycle()

    /// Underlying `swift-telegram-bot` transport.
    public var bot: TGBot {
        self.runtime.bot
    }

    /// Routed bot logger.
    public var logger: Logger {
        self.runtime.log
    }

    /// Creates a routed bot from a configured, bot-independent route graph.
    public init<Context: TelerouteRequestContext>(
        bot: TGBot,
        router: Teleroute<Context>,
        logger: Logger,
        configuration: Configuration = .init()
    ) {
        self.configuration = configuration
        self.runtime = TelerouteRuntime(
            bot: bot,
            logger: logger,
            configuration: configuration,
            storage: router.storage
        )
    }

    /// Attaches the route dispatcher without starting the Telegram connection.
    /// Repeated calls are idempotent.
    public func attach() async throws {
        try await self.runtime.attach()
    }

    /// Attaches the router, optionally synchronizes registered command menus,
    /// and starts the Telegram bot connection. Repeated calls are idempotent.
    public func start() async throws {
        try await self.lifecycle.start { [runtime, configuration] in
            try await runtime.attach()
            if configuration.syncPublishedCommandsOnStart {
                try await runtime.syncPublishedCommands()
            }
            _ = try await runtime.bot.start()
        }
    }

    /// Runs the bot until its surrounding task is cancelled, then performs
    /// graceful shutdown.
    public func run() async throws {
        do {
            try await self.start()
            while true {
                try Task.checkCancellation()
                try await Task.sleep(for: .seconds(86_400))
            }
        } catch is CancellationError {
            await self.shutdown()
        } catch {
            await self.shutdown()
            throw error
        }
    }

    /// Stops update processing, finishes event streams, and stops the bot
    /// connection when it had been started.
    public func shutdown() async {
        await self.lifecycle.shutdown { [runtime] wasStarted in
            runtime.shutdown()
            guard wasStarted else { return }
            do {
                _ = try await runtime.bot.stop()
            } catch {
                runtime.log.error(
                    "Failed to stop Telegram bot",
                    metadata: ["error": .string(String(reflecting: error))]
                )
            }
        }
    }

    /// Creates an independent stream of routed bot lifecycle events.
    public func eventStream(
        buffering: TelerouteEventBufferingPolicy = .newest(512)
    ) -> TelerouteEventSequence {
        self.runtime.eventStream(buffering: buffering)
    }

    /// Processes synthetic or externally supplied Telegram updates without
    /// starting a network connection.
    public func process(_ updates: [TGUpdate]) async {
        await self.runtime.process(updates)
    }

    fileprivate func waitUntilIdle() async {
        await self.runtime.waitUntilIdle()
    }

    /// Runs an in-process bot test without starting long polling or a webhook
    /// server.
    public func test(
        _ body: (TelerouteBotTestClient) async throws -> Void
    ) async throws {
        try await self.attach()
        let client = TelerouteBotTestClient(bot: self)
        do {
            try await body(client)
            await self.runtime.waitUntilIdle()
        } catch {
            await self.runtime.waitUntilIdle()
            throw error
        }
    }

    /// Registered Telegram commands grouped by visibility scope.
    public func publishedCommandSets() throws -> [TeleroutePublishedCommandSet] {
        try self.runtime.publishedCommandSets()
    }

    /// Publishes explicit Telegram command values.
    public func publishCommands(
        _ commands: [TGBotCommand],
        visibility: TelerouteCommandVisibility = .default
    ) async throws {
        try await self.runtime.publishCommands(commands, visibility: visibility)
    }

    /// Publishes `(command, description)` pairs.
    public func publishCommands(
        _ commands: [(command: String, description: String)],
        visibility: TelerouteCommandVisibility = .default
    ) async throws {
        try await self.runtime.publishCommands(commands, visibility: visibility)
    }

    /// Publishes typed command specifications.
    public func publishCommands(
        _ commands: [any TelerouteCommand.Type]
    ) async throws {
        try await self.runtime.publishCommands(commands)
    }

    /// Publishes typed commands in one explicit visibility scope.
    public func publishCommands(
        _ commands: [any TelerouteCommand.Type],
        visibility: TelerouteCommandVisibility
    ) async throws {
        try await self.runtime.publishCommands(commands, visibility: visibility)
    }

    /// Synchronizes command descriptions registered on the router.
    public func syncPublishedCommands() async throws {
        try await self.runtime.syncPublishedCommands()
    }
}

/// In-process client passed to ``TelerouteBot/test(_:)``.
public struct TelerouteBotTestClient: Sendable {
    private let bot: TelerouteBot

    init(bot: TelerouteBot) {
        self.bot = bot
    }

    /// Sends one synthetic Telegram update and waits for its terminal routing
    /// event.
    public func execute(_ update: TGUpdate) async -> TelerouteBotTestResult {
        let stream = self.bot.eventStream(buffering: .unbounded)
        var iterator = stream.makeAsyncIterator()

        await self.bot.process([update])
        await self.bot.waitUntilIdle()

        var events: [TelerouteEvent] = []
        while let event = await iterator.next() {
            guard event.updateId == update.updateId else { continue }
            events.append(event)
            if event.kind.isTerminal {
                break
            }
        }
        return .init(update: update, events: events)
    }

    /// Sends updates sequentially and returns one result per update.
    public func execute(
        _ updates: [TGUpdate]
    ) async -> [TelerouteBotTestResult] {
        var results: [TelerouteBotTestResult] = []
        results.reserveCapacity(updates.count)
        for update in updates {
            results.append(await self.execute(update))
        }
        return results
    }
}

/// Routing events captured for one in-process test update.
public struct TelerouteBotTestResult: Sendable {
    /// Synthetic update passed to the bot.
    public let update: TGUpdate
    /// Events emitted for that update, ending with a terminal event.
    public let events: [TelerouteEvent]

    /// Last handled, unmatched, duplicate, or failed event.
    public var terminalEvent: TelerouteEvent? {
        self.events.last(where: { $0.kind.isTerminal })
    }
}

private extension TelerouteEvent.Kind {
    var isTerminal: Bool {
        switch self {
        case .received:
            false
        case .skippedDuplicate, .handled, .unmatched, .failed:
            true
        }
    }
}

private actor TelerouteBotLifecycle {
    private enum State {
        case idle
        case starting(Task<Void, any Error>)
        case started
        case stopping(Task<Void, Never>)
        case stopped
    }

    private var state = State.idle

    func start(
        _ operation: @escaping @Sendable () async throws -> Void
    ) async throws {
        switch self.state {
        case .idle:
            let task = Task {
                try await operation()
            }
            self.state = .starting(task)
            do {
                try await task.value
                self.completeStart(succeeded: true)
            } catch {
                self.completeStart(succeeded: false)
                throw error
            }

        case let .starting(task):
            try await task.value
            self.completeStart(succeeded: true)

        case .started:
            return

        case .stopping, .stopped:
            throw TelerouteBotError.stopped
        }
    }

    func shutdown(
        _ operation: @escaping @Sendable (_ wasStarted: Bool) async -> Void
    ) async {
        switch self.state {
        case .idle:
            self.state = .stopped
            await operation(false)

        case let .starting(task):
            do {
                try await task.value
                self.completeStart(succeeded: true)
            } catch {
                self.completeStart(succeeded: false)
            }
            await self.shutdown(operation)

        case .started:
            let task = Task {
                await operation(true)
            }
            self.state = .stopping(task)
            await task.value
            self.state = .stopped

        case let .stopping(task):
            await task.value
            self.state = .stopped

        case .stopped:
            return
        }
    }

    private func completeStart(succeeded: Bool) {
        guard case .starting = self.state else { return }
        self.state = succeeded ? .started : .idle
    }
}
