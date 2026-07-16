import AsyncAlgorithms
import Synchronization

@_exported import Foundation
@_exported import Logging
@_exported import SwiftTelegramBot

/// Router for `swift-telegram-bot`.
///
/// Register routes directly on the router, then call ``attach()`` before starting the bot.
public final class Teleroute: TGDefaultDispatcherPrtcl {
    /// Advanced router dependencies and processing policies.
    public struct Configuration: Sendable {
        public var flowStorage: any TelerouteFlowStorage
        public var replayProtectionStorage: (any TelerouteReplayProtectionStorage)?
        public var replayProtectionTTL: Duration
        public var flowCancellationPolicy: TelerouteFlowCancellationPolicy
        public var metricsSink: any TelerouteMetricsSink
        public var onError: TelerouteErrorHandler?

        public init(
            flowStorage: any TelerouteFlowStorage = TelerouteInMemoryFlowStorage(),
            replayProtectionStorage: (any TelerouteReplayProtectionStorage)? = TelerouteInMemoryReplayProtectionStorage(),
            replayProtectionTTL: Duration = .seconds(2),
            flowCancellationPolicy: TelerouteFlowCancellationPolicy = .cancelOnAnyUnmatchedCommand,
            metricsSink: any TelerouteMetricsSink = TelerouteNoOpMetricsSink(),
            onError: TelerouteErrorHandler? = nil
        ) {
            self.flowStorage = flowStorage
            self.replayProtectionStorage = replayProtectionStorage
            self.replayProtectionTTL = replayProtectionTTL
            self.flowCancellationPolicy = flowCancellationPolicy
            self.metricsSink = metricsSink
            self.onError = onError
        }
    }

    private let dispatcher: TGDefaultDispatcher
    let storage: TelerouteStorage
    let routeScope: TelerouteRoutes
    private let flowStorage: any TelerouteFlowStorage
    private let replayProtectionStorage: (any TelerouteReplayProtectionStorage)?
    private let replayProtectionTTL: Duration
    private let flowCancellationPolicy: TelerouteFlowCancellationPolicy
    private let onError: TelerouteErrorHandler?
    private let metricsSink: any TelerouteMetricsSink
    private let attachmentState = TelerouteAttachmentState()
    private let handlerRegistrationState = TelerouteHandlerRegistrationState()
    private let eventHub = TelerouteEventHub()
    private let processingTasks = TelerouteProcessingTaskRegistry()
    private let replayProtectionCleanupTask: Task<Void, Never>?

    public var bot: TGBot {
        self.dispatcher.bot
    }

    public var log: Logger {
        self.dispatcher.log
    }

    public var id: SendableValue<Int> {
        self.dispatcher.id
    }

    public var handlersGroup: HandlersGroupActor {
        self.dispatcher.handlersGroup
    }

    /// Creates a router with one explicit configuration object for advanced dependencies.
    public init(
        bot: TGBot,
        logger: Logger,
        configuration: Configuration = .init()
    ) {
        let storage = TelerouteStorage()
        self.dispatcher = TGDefaultDispatcher(bot: bot, logger: logger)
        self.storage = storage
        self.routeScope = TelerouteRoutes(storage: storage)
        self.flowStorage = configuration.flowStorage
        self.replayProtectionStorage = configuration.replayProtectionStorage
        self.replayProtectionTTL = configuration.replayProtectionTTL
        self.flowCancellationPolicy = configuration.flowCancellationPolicy
        self.onError = configuration.onError
        self.metricsSink = configuration.metricsSink
        self.replayProtectionCleanupTask = Self.makeReplayProtectionCleanupTask(
            storage: configuration.replayProtectionStorage
        )
    }

    /// Attaches this router to the bot supplied at initialization.
    ///
    /// Repeated or concurrent calls share the same registration. If registration
    /// fails, a later call can retry.
    public func attach() async throws {
        try await self.attachmentState.attach { [self] in
            try await self.bot.add(dispatcher: self)
        }
    }

    deinit {
        self.shutdown()
    }

    /// Stops accepting new updates, cancels in-flight processing, and finishes
    /// all event streams. Calling this method more than once has no effect.
    public func shutdown() {
        self.processingTasks.shutdown()
        self.replayProtectionCleanupTask?.cancel()
        self.eventHub.finish()
    }

    /// Creates an independent lifecycle-event stream for one consumer.
    public func eventStream(
        buffering: TelerouteEventBufferingPolicy = .newest(512)
    ) -> TelerouteEventSequence {
        self.eventHub.sequence(buffering: buffering)
    }

    /// `TGDefaultDispatcher` entry point. Registers internal Telegram handlers once.
    public func handle() async {
        guard self.handlerRegistrationState.claim() else { return }

        await self.add(
            TGBaseHandler(name: "TelerouteDispatcher") { [weak self] update in
                guard let self else { return }
                let startedAt = ContinuousClock().now
                let context = TelerouteContext(bot: self.bot, update: update)
                let routeKind = self.eventRouteKind(for: update)
                do {
                    self.emitEvent(.received, update: update, startedAt: startedAt)
                    await self.metricsSink.recordReceived(routeKind: routeKind, chatId: context.chatId, userId: context.userId)
                    self.log.debug("Received update", metadata: self.updateMetadata(for: update))
                    guard await self.shouldHandle(update) else {
                        self.emitEvent(.skippedDuplicate, update: update, startedAt: startedAt)
                        await self.metricsSink.recordSkippedDuplicate(routeKind: routeKind, chatId: context.chatId, userId: context.userId)
                        self.log.debug("Skipped duplicate update", metadata: self.updateMetadata(for: update))
                        return
                    }
                    if try await self.processFlow(update, startedAt: startedAt) {
                        self.log.debug("Handled update with flow route", metadata: self.updateMetadata(for: update))
                        return
                    }
                    if try await self.processCallback(update, startedAt: startedAt) {
                        self.log.debug("Handled update with callback route", metadata: self.updateMetadata(for: update))
                        return
                    }
                    if try await self.processCommand(update, startedAt: startedAt) {
                        self.log.debug("Handled update with command route", metadata: self.updateMetadata(for: update))
                        return
                    }
                    self.emitEvent(.unmatched, update: update, startedAt: startedAt, duration: startedAt.duration(to: ContinuousClock().now))
                    await self.metricsSink.recordUnmatched(routeKind: routeKind, chatId: context.chatId, userId: context.userId)
                    self.log.debug("No route matched update", metadata: self.updateMetadata(for: update))
                } catch {
                    await self.handleError(error, update: update, startedAt: startedAt)
                }
            }
        )
    }

    public func process(_ updates: [TGUpdate]) async {
        guard self.processingTasks.isShutdown == false else { return }
        for update in updates {
            self.log.trace("processByHandler start:\n\(dump(update))")
            let handlers = await self.handlersGroup.value
            guard handlers.isEmpty == false else { return }

            for handler in handlers {
                guard await handler.check(update: update) else {
                    continue
                }

                let uuid = UUID()
                guard self.processingTasks.reserve(id: uuid) else { return }
                let registry = self.processingTasks
                let task = Task { [weak self] in
                    attachment: while true {
                        switch registry.startDisposition(for: uuid) {
                        case .waiting:
                            await Task.yield()
                        case .cancelled:
                            return
                        case .ready:
                            break attachment
                        }
                    }
                    defer { registry.remove(id: uuid) }
                    guard Task.isCancelled == false else { return }
                    do {
                        try await handler.handle(update: update)
                    } catch {
                        await self?.handleError(error, update: update)
                    }
                }
                self.processingTasks.attach(task, id: uuid)
            }
        }
    }

    var processingTaskCount: Int {
        self.processingTasks.count
    }

    private func updateMetadata(for update: TGUpdate) -> Logger.Metadata {
        let context = TelerouteContext(bot: self.bot, update: update)
        var metadata: Logger.Metadata = [
            "update_id": .stringConvertible(update.updateId),
            "chat_id": .string(context.chatId.map(String.init) ?? "none"),
            "user_id": .string(context.userId.map(String.init) ?? "none"),
        ]

        if let command = TelerouteCommandExtractor.extract(from: update) {
            metadata["route_kind"] = .string("command")
            metadata["command"] = .string(command.name)
        } else if let callbackData = update.callbackQuery?.data {
            metadata["route_kind"] = .string("callback")
            metadata["callback_data"] = .string(callbackData)
        } else if let text = context.message?.text, text.isEmpty == false {
            metadata["route_kind"] = .string("message")
            metadata["message_text"] = .string(text)
        } else {
            metadata["route_kind"] = .string("unknown")
        }

        return metadata
    }

    private func logProcessingError(
        _ error: any Error,
        update: TGUpdate,
        context: TelerouteContext,
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?
    ) async {
        var metadata = self.updateMetadata(for: update)
        metadata.merge([
            "error_type": .string(String(reflecting: type(of: error))),
            "route_kind": .string(Self.routeKindDescription(routeKind)),
        ]) { _, new in new }
        if let routeName {
            metadata["route_name"] = .string(routeName)
        }

        if let command = TelerouteCommandExtractor.extract(from: update),
           let argumentsText = command.argumentsText,
           argumentsText.isEmpty == false {
            metadata["command_arguments"] = .string(argumentsText)
        }

        var flowSession = context.activeFlow
        if flowSession == nil, let flowKey = context.flowKey {
            flowSession = await self.flowStorage.session(for: flowKey)
        }
        if let session = flowSession {
            metadata["flow_id"] = .string(session.id)
            metadata["flow_step"] = .string(session.step)
        }

        self.log.error(Self.errorMessage(for: error), metadata: metadata)
    }

    private static func errorMessage(for error: any Error) -> Logger.Message {
        .init(stringLiteral: self.errorDescription(for: error))
    }

    private static func errorDescription(for error: any Error) -> String {
        if let botError = error as? BotError {
            return botError.localizedDescription
        }

        if let localizedError = error as? any LocalizedError,
           let description = localizedError.errorDescription,
           description.isEmpty == false {
            return description
        }

        return error.localizedDescription == error._domain
            ? String(reflecting: error)
            : error.localizedDescription
    }

    private static func routeKindDescription(_ routeKind: TelerouteEvent.RouteKind) -> String {
        switch routeKind {
        case .command: "command"
        case .callback: "callback"
        case .flow: "flow"
        case .message: "message"
        case .unknown: "unknown"
        }
    }

    private func shouldHandle(_ update: TGUpdate) async -> Bool {
        guard let replayProtectionStorage = self.replayProtectionStorage,
              let key = self.replayProtectionKey(for: update) else {
            return true
        }
        return await replayProtectionStorage.claim(key: key, ttl: self.replayProtectionTTL)
    }

    private func replayProtectionKey(for update: TGUpdate) -> String? {
        let context = TelerouteContext(bot: self.bot, update: update)
        let chatID = context.chatId.map(String.init) ?? "none"
        let userID = context.userId.map(String.init) ?? "none"

        if let callbackData = update.callbackQuery?.data {
            return "callback|\(chatID)|\(userID)|\(callbackData)"
        }

        if let command = TelerouteCommandExtractor.extract(from: update) {
            return "command|\(chatID)|\(userID)|\(command.rawValue)|\(command.argumentsText ?? "")"
        }

        return nil
    }

    @discardableResult
    private func processFlow(_ update: TGUpdate, startedAt: ContinuousClock.Instant) async throws -> Bool {
        let baseContext = TelerouteContext(
            bot: self.bot,
            update: update,
            flowStorage: self.flowStorage,
            flowSession: nil
        )
        guard let flowKey = baseContext.flowKey else {
            return false
        }
        return try await self.storage.flowQueue.enqueue(key: TelerouteFlowQueueKey.key(for: flowKey)) {
            try await self.processFlow(update, flowKey: flowKey, startedAt: startedAt)
        }
    }

    @discardableResult
    private func processFlow(
        _ update: TGUpdate,
        flowKey: TelerouteFlowKey,
        startedAt: ContinuousClock.Instant
    ) async throws -> Bool {
        guard let session = await self.flowStorage.session(for: flowKey) else {
            return false
        }

        if let callbackData = update.callbackQuery?.data {
            for route in self.storage.flowRoutes {
                guard route.flowID == session.id, route.step == session.step else {
                    continue
                }
                guard case let .callback(pattern) = route.matcher,
                      let parameters = pattern.match(callbackData) else {
                    continue
                }
                let context = TelerouteContext(
                    bot: self.bot,
                    update: update,
                    parameters: parameters,
                    flowStorage: self.flowStorage,
                    flowSession: session
                )
                let handled = try await Self.run(
                    middlewares: route.middlewares,
                    context: context,
                    update: update,
                    routeKind: .flow,
                    routeName: "\(route.flowID):\(route.step)",
                    handler: route.handler
                )
                if handled {
                    await self.emitHandled(
                        update: update,
                        routeKind: .flow,
                        routeName: "\(route.flowID):\(route.step)",
                        startedAt: startedAt
                    )
                    return true
                }
            }
            return false
        }

        if let command = TelerouteCommandExtractor.extract(from: update) {
            for route in self.storage.flowRoutes {
                guard route.flowID == session.id, route.step == session.step else {
                    continue
                }
                guard case let .command(name, botUsername) = route.matcher,
                      Self.commandMatches(command, routeName: name, botUsername: botUsername) else {
                    continue
                }
                let context = TelerouteContext(
                    bot: self.bot,
                    update: update,
                    parameters: .init(),
                    command: command,
                    flowStorage: self.flowStorage,
                    flowSession: session
                )
                let handled = try await Self.run(
                    middlewares: route.middlewares,
                    context: context,
                    update: update,
                    routeKind: .flow,
                    routeName: "\(route.flowID):\(route.step):\(name)",
                    handler: route.handler
                )
                if handled {
                    await self.emitHandled(
                        update: update,
                        routeKind: .flow,
                        routeName: "\(route.flowID):\(route.step):\(name)",
                        startedAt: startedAt
                    )
                    return true
                }
            }
            // An unrelated command (e.g. `/help`) arrived while a flow was
            // active. By default this tears the flow down so subsequent messages
            // are no longer captured, but callers can opt out via the policy.
            if self.flowCancellationPolicy.cancelsSessionOnUnmatchedCommand {
                await self.flowStorage.removeSession(for: flowKey)
            }
            return false
        }

        guard TelerouteMessageExtractor.extract(from: update) != nil else {
            return false
        }

        for route in self.storage.flowRoutes {
            guard route.flowID == session.id, route.step == session.step else {
                continue
            }
            guard case .message = route.matcher else {
                continue
            }
            let context = TelerouteContext(
                bot: self.bot,
                update: update,
                parameters: .init(),
                command: nil,
                flowStorage: self.flowStorage,
                flowSession: session
            )
            let handled = try await Self.run(
                middlewares: route.middlewares,
                context: context,
                update: update,
                routeKind: .flow,
                routeName: "\(route.flowID):\(route.step)",
                handler: route.handler
            )
            if handled {
                await self.emitHandled(
                    update: update,
                    routeKind: .flow,
                    routeName: "\(route.flowID):\(route.step)",
                    startedAt: startedAt
                )
                return true
            }
        }

        return false
    }

    @discardableResult
    private func processCommand(_ update: TGUpdate, startedAt: ContinuousClock.Instant) async throws -> Bool {
        guard let command = TelerouteCommandExtractor.extract(from: update) else {
            return false
        }
        for route in self.storage.commandRoutes where Self.commandMatches(
            command,
            routeName: route.name,
            botUsername: route.botUsername
        ) {
            let context = TelerouteContext(
                bot: self.bot,
                update: update,
                parameters: .init(),
                command: command,
                flowStorage: self.flowStorage,
                flowSession: nil
            )
            let handled = try await Self.run(
                middlewares: route.middlewares,
                context: context,
                update: update,
                routeKind: .command,
                routeName: route.name,
                handler: route.handler
            )
            if handled == false {
                continue
            }
            await self.emitHandled(
                update: update,
                routeKind: .command,
                routeName: route.name,
                startedAt: startedAt
            )
            return true
        }
        return false
    }

    private static func commandMatches(
        _ command: TelerouteCommandMatch,
        routeName: String,
        botUsername: String?
    ) -> Bool {
        guard routeName == command.name else { return false }
        guard let botUsername else { return true }
        guard let mentionedBotUsername = command.mentionedBotUsername else { return false }
        return self.normalizedBotUsername(botUsername) == self.normalizedBotUsername(mentionedBotUsername)
    }

    private static func normalizedBotUsername(_ username: String) -> String {
        let username = username.hasPrefix("@")
            ? String(username.dropFirst())
            : username
        return username.lowercased()
    }

    @discardableResult
    private func processCallback(_ update: TGUpdate, startedAt: ContinuousClock.Instant) async throws -> Bool {
        guard let data = update.callbackQuery?.data else {
            return false
        }
        for route in self.storage.callbackRoutes {
            guard let parameters = route.pattern.match(data) else {
                continue
            }
            let context = TelerouteContext(
                bot: self.bot,
                update: update,
                parameters: parameters,
                command: nil,
                flowStorage: self.flowStorage,
                flowSession: nil
            )
            let handled = try await Self.run(
                middlewares: route.middlewares,
                context: context,
                update: update,
                routeKind: .callback,
                routeName: route.pattern.routeDescription,
                handler: route.handler
            )
            if handled == false {
                continue
            }
            await self.emitHandled(
                update: update,
                routeKind: .callback,
                routeName: route.pattern.routeDescription,
                startedAt: startedAt
            )
            return true
        }
        return false
    }

    /// Central error path: emits a typed `.failed` event, logs with rich
    /// metadata, records metrics, and forwards to the user-supplied `onError`
    /// handler when set.
    private func handleError(
        _ error: any Error,
        update: TGUpdate,
        startedAt: ContinuousClock.Instant = ContinuousClock().now
    ) async {
        let routeFailure = error as? TelerouteRouteFailure
        let reportedError = routeFailure?.underlyingError ?? error
        guard (reportedError is CancellationError && Task.isCancelled) == false else {
            return
        }

        let context = routeFailure?.context ?? TelerouteContext(bot: self.bot, update: update)
        let duration = startedAt.duration(to: ContinuousClock().now)
        let routeKind = routeFailure?.routeKind ?? self.eventRouteKind(for: update)
        let routeName = routeFailure?.routeName
        self.eventHub.emit(
            .init(
                kind: .failed,
                routeKind: routeKind,
                routeName: routeName,
                updateId: update.updateId,
                chatId: context.chatId,
                userId: context.userId,
                startedAt: startedAt,
                duration: duration,
                error: reportedError,
                errorDescription: Self.errorDescription(for: reportedError)
            )
        )
        await self.metricsSink.recordFailed(
            routeKind: routeKind,
            routeName: routeName,
            chatId: context.chatId,
            userId: context.userId,
            duration: duration,
            error: reportedError
        )
        await self.logProcessingError(
            reportedError,
            update: update,
            context: context,
            routeKind: routeKind,
            routeName: routeName
        )
        await self.onError?(reportedError, context)
    }

    private func emitEvent(
        _ kind: TelerouteEvent.Kind,
        update: TGUpdate,
        routeKind: TelerouteEvent.RouteKind? = nil,
        routeName: String? = nil,
        startedAt: ContinuousClock.Instant = ContinuousClock().now,
        duration: Duration? = nil
    ) {
        let context = TelerouteContext(bot: self.bot, update: update)
        self.eventHub.emit(
            .init(
                kind: kind,
                routeKind: routeKind ?? self.eventRouteKind(for: update),
                routeName: routeName,
                updateId: update.updateId,
                chatId: context.chatId,
                userId: context.userId,
                startedAt: startedAt,
                duration: duration
            )
        )
    }

    /// Emits a `.handled` event with timing and records metrics for the matched route.
    private func emitHandled(
        update: TGUpdate,
        routeKind: TelerouteEvent.RouteKind,
        routeName: String,
        startedAt: ContinuousClock.Instant
    ) async {
        let context = TelerouteContext(bot: self.bot, update: update)
        let duration = startedAt.duration(to: ContinuousClock().now)
        self.eventHub.emit(
            .init(
                kind: .handled,
                routeKind: routeKind,
                routeName: routeName,
                updateId: update.updateId,
                chatId: context.chatId,
                userId: context.userId,
                startedAt: startedAt,
                duration: duration
            )
        )
        await self.metricsSink.recordHandled(
            routeKind: routeKind,
            routeName: routeName,
            chatId: context.chatId,
            userId: context.userId,
            duration: duration
        )
    }

    private func eventRouteKind(for update: TGUpdate) -> TelerouteEvent.RouteKind {
        if TelerouteCommandExtractor.extract(from: update) != nil {
            return .command
        }
        if update.callbackQuery?.data != nil {
            return .callback
        }
        if TelerouteMessageExtractor.extract(from: update) != nil {
            return .message
        }
        return .unknown
    }

    private static func makeReplayProtectionCleanupTask(
        storage: (any TelerouteReplayProtectionStorage)?,
        interval: Duration = .seconds(60)
    ) -> Task<Void, Never>? {
        guard let storage = storage as? any TelerouteReplayProtectionCleanupStorage else {
            return nil
        }
        return Task {
            let timer = AsyncTimerSequence.repeating(every: interval)
            for await _ in timer {
                await storage.removeExpired()
            }
        }
    }

    private static func run(
        middlewares: [any TelerouteMiddleware],
        context: TelerouteContext,
        update: TGUpdate,
        routeKind: TelerouteEvent.RouteKind,
        routeName: String,
        handler: @escaping TelerouteHandler
    ) async throws -> Bool {
        let runner = TelerouteMiddlewareRunner(
            middlewares: middlewares,
            handler: handler
        )
        do {
            return try await runner.run(context: context)
        } catch {
            throw TelerouteRouteFailure(
                underlyingError: error,
                context: context,
                routeKind: routeKind,
                routeName: routeName
            )
        }
    }
}

private actor TelerouteAttachmentState {
    private enum State {
        case detached
        case attaching(Task<Void, any Error>)
        case attached
    }

    private var state = State.detached

    func attach(
        _ operation: @escaping @Sendable () async throws -> Void
    ) async throws {
        switch self.state {
        case .detached:
            let task = Task {
                try await operation()
            }
            self.state = .attaching(task)
            do {
                try await task.value
                self.state = .attached
            } catch {
                self.state = .detached
                throw error
            }

        case let .attaching(task):
            try await task.value

        case .attached:
            return
        }
    }
}

private final class TelerouteHandlerRegistrationState: Sendable {
    private let hasRegisteredHandlers = Mutex(false)

    func claim() -> Bool {
        self.hasRegisteredHandlers.withLock {
            guard $0 == false else {
                return false
            }
            $0 = true
            return true
        }
    }
}

private final class TelerouteProcessingTaskRegistry: Sendable {
    enum StartDisposition: Sendable {
        case waiting
        case ready
        case cancelled
    }

    private enum Slot: Sendable {
        case reserved
        case running(Task<Void, Never>)
    }

    private struct State: Sendable {
        var slots: [UUID: Slot] = [:]
        var isShutdown = false
    }

    private let state = Mutex(State())

    func reserve(id: UUID) -> Bool {
        self.state.withLock { state in
            guard state.isShutdown == false else { return false }
            state.slots[id] = .reserved
            return true
        }
    }

    func attach(_ task: Task<Void, Never>, id: UUID) {
        let shouldCancel = self.state.withLock { state in
            guard state.isShutdown == false,
                  case .some(.reserved) = state.slots[id] else {
                return true
            }
            state.slots[id] = .running(task)
            return false
        }
        if shouldCancel {
            task.cancel()
        }
    }

    func startDisposition(for id: UUID) -> StartDisposition {
        self.state.withLock { state in
            guard state.isShutdown == false else { return .cancelled }
            switch state.slots[id] {
            case .some(.reserved):
                return .waiting
            case .some(.running):
                return .ready
            case nil:
                return .cancelled
            }
        }
    }

    func remove(id: UUID) {
        self.state.withLock { state in
            state.slots[id] = nil
        }
    }

    func shutdown() {
        let tasks = self.state.withLock { state -> [Task<Void, Never>] in
            guard state.isShutdown == false else { return [] }
            state.isShutdown = true
            let tasks = state.slots.values.compactMap { slot -> Task<Void, Never>? in
                guard case let .running(task) = slot else { return nil }
                return task
            }
            state.slots.removeAll()
            return tasks
        }
        for task in tasks {
            task.cancel()
        }
    }

    var isShutdown: Bool {
        self.state.withLock { $0.isShutdown }
    }

    var count: Int {
        self.state.withLock { $0.slots.count }
    }
}

private struct TelerouteRouteFailure: Error, Sendable {
    let underlyingError: any Error
    let context: TelerouteContext
    let routeKind: TelerouteEvent.RouteKind
    let routeName: String
}
