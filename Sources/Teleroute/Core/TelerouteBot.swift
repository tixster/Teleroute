import Foundation
import Logging
import ServiceLifecycle
import UnixSignals
import Synchronization

/// Errors raised by the routed bot lifecycle.
public enum TelerouteBotError: Error, Equatable, Sendable {
    /// The bot was shut down and cannot be started again.
    case stopped
}

/// How a routed bot receives its updates.
public enum TelerouteBotMode: Sendable, Hashable {
    /// The bot owns a `getUpdates` long-polling loop (the default).
    case polling
    /// Updates arrive from an external webhook server via
    /// ``TelerouteBot/process(_:)``; no polling loop is started.
    case webhook
    /// Updates are supplied manually via ``TelerouteBot/process(_:)``.
    case manual
}

/// Running Telegram bot built from a bot-independent ``Teleroute`` route graph.
public final class TelerouteBot: Sendable {
    public typealias Configuration = TelerouteConfiguration

    let runtime: TelerouteRuntime
    private let configuration: Configuration
    /// How this bot receives its updates.
    public let mode: TelerouteBotMode
    private let lifecycle = TelerouteBotLifecycle()
    private let pollingTask = Mutex<Task<Void, Never>?>(nil)

    /// Telegram Bot API client used by the router.
    public var client: TelegramBotClient {
        self.runtime.bot
    }

    /// Telegram Bot API client used by the router.
    @available(*, deprecated, renamed: "client")
    public var bot: TelegramBotClient {
        self.client
    }

    /// Routed bot logger.
    public var logger: Logger {
        self.runtime.log
    }

    /// Creates a routed bot from a bot token and a configured, bot-independent
    /// route graph. The Telegram client is created internally.
    ///
    /// - Parameters:
    ///   - token: Bot token obtained from @BotFather.
    ///   - router: Route graph to serve.
    ///   - logger: Logger used by the runtime.
    ///   - configuration: Processing policies and long-polling behavior.
    ///   - mode: How the bot receives its updates; defaults to long polling.
    ///   - transport: Optional custom HTTP transport; defaults to
    ///     AsyncHTTPClient with a long-polling-friendly timeout.
    ///   - rateLimit: Outbound request throttle; pass `nil` to disable.
    public convenience init<Context: TelerouteRequestContext>(
        token: String,
        router: Teleroute<Context>,
        logger: Logger = Logger(label: "teleroute"),
        configuration: Configuration = .init(),
        mode: TelerouteBotMode = .polling,
        transport: (any TelegramTransport)? = nil,
        rateLimit: TelegramRateLimit? = .default
    ) throws {
        let client: TelegramBotClient
        if let transport {
            var middlewares: [any TelegramMiddleware] = []
            if let rateLimit {
                middlewares.append(TelegramRateLimitMiddleware(limit: rateLimit))
            }
            client = try TelegramBotClient(
                token: token,
                transport: transport,
                middlewares: middlewares
            )
        } else {
            client = try TelegramBotClient(token: token, rateLimit: rateLimit)
        }
        self.init(
            client: client,
            router: router,
            logger: logger,
            configuration: configuration,
            mode: mode
        )
    }

    /// Creates a routed bot over a pre-configured Telegram client. Prefer
    /// ``init(token:router:logger:configuration:mode:transport:rateLimit:)``
    /// unless the client needs custom middlewares or a fully custom setup.
    public init<Context: TelerouteRequestContext>(
        client: TelegramBotClient,
        router: Teleroute<Context>,
        logger: Logger = Logger(label: "teleroute"),
        configuration: Configuration = .init(),
        mode: TelerouteBotMode = .polling
    ) {
        self.configuration = configuration
        self.mode = mode
        // Mounted through the router, not the runtime, so the route inherits
        // the router's middleware — and mounted at construction rather than at
        // the first render, because `allowed_updates` is derived once at start
        // and only asks for `callback_query` when a callback route exists.
        if configuration.inlineActions.isEnabled, router.storage.claimInlineActionRoute() {
            router.callback(telerouteInlineActionPath) { context -> TelerouteResponse in
                let core = context.coreContext
                guard let store = core.inlineActions else { return .none }
                guard let id = core.parameters["id"],
                      let entry = store.entry(
                          for: id,
                          pressedBy: (chatId: core.chatId, userId: core.userId)
                      )
                else {
                    return store.expired
                }
                let response = try await entry.action(core)
                await Self.completeInlineAction(
                    entry.completion,
                    response: response,
                    context: core,
                    logger: logger
                )
                return response
            }
        }
        self.runtime = TelerouteRuntime(
            bot: client,
            logger: logger,
            configuration: configuration,
            storage: router.storage
        )
    }

    /// Applies a button's `onSuccess` behavior after its handler returned
    /// without throwing.
    ///
    /// Failures here are logged rather than thrown: the handler already did
    /// the user's work, so turning a tidy-up problem into a failed update
    /// would report the wrong outcome and may show the user an error for
    /// something that succeeded.
    private static func completeInlineAction(
        _ completion: TelerouteButtonCompletion,
        response: TelerouteResponse,
        context: TelerouteContext,
        logger: Logger
    ) async {
        guard completion != .keep else { return }
        // An editing response already decides the keyboard; rewriting it here
        // would fight the handler and could resurrect removed buttons.
        guard response.decidesReplyMarkup == false else { return }

        do {
            switch completion {
            case .keep:
                break
            case .removeButton:
                try await context.removePressedButton()
            case .removeKeyboard:
                try await context.editReplyMarkup(nil)
            }
        } catch {
            logger.warning(
                "Could not apply a button's onSuccess behavior",
                metadata: [
                    "completion": .string(String(describing: completion)),
                    "error": .string(String(reflecting: error)),
                ]
            )
        }
    }

    /// Optionally synchronizes registered command menus and, in
    /// ``TelerouteBotMode/polling`` mode, starts the long-polling connection.
    /// Repeated calls are idempotent.
    public func start() async throws {
        try await self.lifecycle.start { [self] in
            if self.configuration.syncPublishedCommandsOnStart {
                try await self.runtime.syncPublishedCommands()
            }
            guard self.mode == .polling else { return }
            let connection = TelegramLongPollingConnection(
                client: self.runtime.bot,
                configuration: self.configuration.polling,
                resolvedAllowedUpdates: self.runtime.resolvedAllowedUpdates(
                    self.configuration.polling.allowedUpdates
                ),
                logger: self.runtime.log
            )
            let task = Task { [runtime] in
                await connection.run { updates in
                    await runtime.process(updates)
                }
            }
            self.pollingTask.withLock { $0 = task }
        }
    }

    /// Runs the bot until its surrounding task is cancelled or the enclosing
    /// `ServiceGroup` initiates a graceful shutdown, then drains in-flight
    /// handlers and shuts down. This is the `Service` entry point.
    public func run() async throws {
        do {
            try await self.start()
            try await cancelWhenGracefulShutdown {
                while true {
                    try Task.checkCancellation()
                    try await Task.sleep(for: .seconds(86_400))
                }
            }
        } catch is CancellationError {
            await self.shutdown()
        } catch {
            await self.shutdown()
            throw error
        }
    }

    /// Runs the bot inside a `ServiceGroup` that converts SIGTERM/SIGINT into
    /// a graceful shutdown.
    public func runService(
        gracefulShutdownSignals: [UnixSignal] = [.sigterm, .sigint]
    ) async throws {
        try await self.runService(
            with: [],
            gracefulShutdownSignals: gracefulShutdownSignals
        )
    }

    /// Runs the bot alongside other services in one `ServiceGroup`, so a
    /// database, an HTTP server, or background workers share the bot's
    /// graceful shutdown:
    ///
    /// ```swift
    /// try await bot.runService(with: [database, worker])
    /// ```
    ///
    /// The bot is started first, so services that depend on it observe a
    /// running runtime.
    public func runService(
        with services: [any Service],
        gracefulShutdownSignals: [UnixSignal] = [.sigterm, .sigint]
    ) async throws {
        let group = ServiceGroup(
            services: [self] + services,
            gracefulShutdownSignals: gracefulShutdownSignals,
            logger: self.logger
        )
        try await group.run()
    }

    /// Stops intake, cancels the long-polling connection, waits up to
    /// ``TelerouteConfiguration/shutdownGracePeriod`` for in-flight handlers
    /// to finish, then cancels stragglers and finishes event streams.
    public func shutdown() async {
        await self.lifecycle.shutdown { [self] wasStarted in
            self.runtime.stopAccepting()
            if wasStarted {
                let task = self.pollingTask.withLock { task in
                    defer { task = nil }
                    return task
                }
                task?.cancel()
                await task?.value
            }
            await self.runtime.drain(within: self.configuration.shutdownGracePeriod)
            self.runtime.shutdown()
        }
    }

    /// Resolves the `allowed_updates` wire strings for this bot's route graph,
    /// for use with `setWebhook` or custom polling setups.
    public func resolvedAllowedUpdates(
        _ mode: TelerouteAllowedUpdates = .automatic
    ) -> [String]? {
        self.runtime.resolvedAllowedUpdates(mode)
    }

    /// Waits until Telegram forwards a channel post into the channel's linked
    /// discussion chat, and returns that forward — reply to its
    /// ``TelerouteDiscussionForward/discussionMessageId`` to comment under
    /// the post:
    ///
    /// ```swift
    /// let post = try await bot.client.sendMessage(chatId: .id(channelId), text: "New chapter")
    /// if let forward = try await bot.discussionMessage(for: post) {
    ///     try await bot.client.sendMessage(
    ///         chatId: .id(forward.discussionChatId),
    ///         text: "Comments start here",
    ///         replyParameters: .init(messageId: forward.discussionMessageId)
    ///     )
    /// }
    /// ```
    ///
    /// The channel's linked chat is looked up with `getChat` (and cached per
    /// ``TelerouteDiscussionForwardPolicy/enabled(retention:capacity:linkedChatCacheTTL:)``);
    /// without one this returns `nil` immediately. A forward that arrived
    /// before this call is still found while it is retained.
    ///
    /// Tracking is on unless ``TelerouteConfiguration/discussionForwards`` is
    /// ``TelerouteDiscussionForwardPolicy/disabled``. The bot must ask for
    /// `message` updates (any command or message route does; a warning is
    /// logged once otherwise) and see the discussion chat's messages
    /// (administrator, or privacy mode disabled).
    ///
    /// - Parameters:
    ///   - post: A message sent to a channel, as returned by a send method.
    ///   - timeout: How long to wait for the forward.
    /// - Throws: ``TelerouteDiscussionForwardError`` — `.trackingDisabled`,
    ///   `.notAChannelPost`, `.timeout`, or `.shutdown`; `CancellationError`
    ///   when the waiting task is cancelled; or the `getChat` failure.
    public func discussionMessage(
        for post: Message,
        timeout: Duration = .seconds(20)
    ) async throws -> TelerouteDiscussionForward? {
        guard let tracker = self.runtime.discussionForwards else {
            throw TelerouteDiscussionForwardError.trackingDisabled
        }
        return try await tracker.discussionMessage(for: post, timeout: timeout, bot: self.runtime.bot)
    }

    /// Sends a channel post and returns it together with its copy in the
    /// channel's linked discussion chat:
    ///
    /// ```swift
    /// let (post, forward) = try await bot.sendWithDiscussionForward { client in
    ///     try await client.sendMessage(chatId: .id(channelId), text: "New chapter")
    /// }
    /// ```
    ///
    /// Any send method returning one `Message` works inside the closure.
    /// `forward` is `nil` when the channel has no linked chat. See
    /// ``discussionMessage(for:timeout:)`` for how the copy is found.
    ///
    /// - Parameters:
    ///   - timeout: How long to wait for the copy after sending.
    ///   - send: Sends the post through the bot's client.
    /// - Throws: ``TelerouteDiscussionForwardError/trackingDisabled`` before
    ///   sending anything when tracking is off; the send's own error; or,
    ///   once the post is out, ``TelerouteDiscussionPostError`` carrying the
    ///   sent post and the reason waiting failed.
    public func sendWithDiscussionForward(
        timeout: Duration = .seconds(20),
        _ send: (TelegramBotClient) async throws -> Message
    ) async throws -> (post: Message, forward: TelerouteDiscussionForward?) {
        try await TelerouteDiscussionForwardTracker.send(
            with: self.runtime.discussionForwards,
            bot: self.runtime.bot,
            timeout: timeout,
            send
        )
    }

    /// Waits until Telegram forwards post `messageId` of channel `channelId`
    /// into the channel's linked discussion chat. See
    /// ``discussionMessage(for:timeout:)``.
    public func discussionMessage(
        channelId: Int64,
        messageId: Int64,
        timeout: Duration = .seconds(20)
    ) async throws -> TelerouteDiscussionForward? {
        guard let tracker = self.runtime.discussionForwards else {
            throw TelerouteDiscussionForwardError.trackingDisabled
        }
        return try await tracker.discussionMessage(
            channelId: channelId,
            messageId: messageId,
            timeout: timeout,
            bot: self.runtime.bot
        )
    }

    /// Creates an independent stream of routed bot lifecycle events.
    public func eventStream(
        buffering: TelerouteEventBufferingPolicy = .newest(512)
    ) -> TelerouteEventSequence {
        self.runtime.eventStream(buffering: buffering)
    }

    /// Processes synthetic or externally supplied Telegram updates without
    /// starting a network connection.
    public func process(_ updates: [Update]) async {
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
        _ commands: [BotCommand],
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
    public func execute(_ update: Update) async -> TelerouteBotTestResult {
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
        _ updates: [Update]
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
    public let update: Update
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

extension TelerouteBot: Service {}
