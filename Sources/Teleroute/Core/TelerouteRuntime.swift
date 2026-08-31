import AsyncAlgorithms
import Synchronization

@_exported import Foundation
@_exported import Logging
@_exported import TelegramBotKit

/// Internal dispatcher runtime. Public applications are built with
/// ``Teleroute`` and ``TelerouteBot``.
@_spi(Testing)
public final class TelerouteRuntime: Sendable {
    public typealias Configuration = TelerouteConfiguration

    public let bot: TelegramBotClient
    public let log: Logger
    let storage: TelerouteStorage
    let routeScope: TelerouteRoutes
    private let flowStorage: any TelerouteFlowStorage
    private let replayProtectionStorage: (any TelerouteReplayProtectionStorage)?
    private let replayProtectionTTL: Duration
    private let flowCoordinator: TelerouteFlowCoordinator
    private let onError: TelerouteErrorHandler?
    private let errorRenderer: TelerouteErrorRenderer?
    private let defaultParseMode: ParseMode?
    private let autoAnswerCallbackQueries: Bool
    private let metricsSink: any TelerouteMetricsSink
    private let eventHub = TelerouteEventHub()
    private let updateExecutor: TelerouteUpdateExecutor
    private let replayProtectionCleanupTask: Task<Void, Never>?

    /// Creates a router with one explicit configuration object for advanced dependencies.
    public convenience init(
        bot: TelegramBotClient,
        logger: Logger,
        configuration: Configuration = .init()
    ) {
        self.init(
            bot: bot,
            logger: logger,
            configuration: configuration,
            storage: TelerouteStorage()
        )
    }

    init(
        bot: TelegramBotClient,
        logger: Logger,
        configuration: Configuration,
        storage: TelerouteStorage
    ) {
        self.bot = bot
        self.log = logger
        self.storage = storage
        self.routeScope = TelerouteRoutes(storage: storage)
        self.flowStorage = configuration.flowStorage
        self.replayProtectionStorage = configuration.replayProtectionStorage
        self.replayProtectionTTL = configuration.replayProtectionTTL
        self.flowCoordinator = .init(
            bot: bot,
            flowStorage: configuration.flowStorage,
            queue: storage.flowQueue,
            cancellationPolicy: configuration.flowCancellationPolicy
        )
        self.onError = configuration.onError
        self.errorRenderer = configuration.errorRenderer
        self.defaultParseMode = configuration.defaultParseMode
        self.autoAnswerCallbackQueries = configuration.autoAnswerCallbackQueries
        self.metricsSink = configuration.metricsSink
        self.updateExecutor = .init(
            maximumConcurrentTasks: configuration.maximumConcurrentUpdates
        )
        self.replayProtectionCleanupTask = Self.makeReplayProtectionCleanupTask(
            storage: configuration.replayProtectionStorage
        )
    }

    deinit {
        self.shutdown()
    }

    /// Stops accepting new updates while in-flight handlers keep running.
    public func stopAccepting() {
        self.updateExecutor.stopAccepting()
    }

    /// Waits for in-flight handlers to finish, up to the supplied grace period.
    public func drain(within grace: Duration) async {
        await withTaskGroup(of: Void.self) { group in
            group.addTask { await self.updateExecutor.waitUntilIdle() }
            group.addTask { try? await Task.sleep(for: grace) }
            await group.next()
            group.cancelAll()
        }
    }

    /// Stops accepting new updates, cancels in-flight processing, and finishes
    /// all event streams. Calling this method more than once has no effect.
    public func shutdown() {
        self.updateExecutor.shutdown()
        self.replayProtectionCleanupTask?.cancel()
        self.eventHub.finish()
    }

    /// Resolves the `allowed_updates` wire strings for polling or webhooks.
    /// Returns `nil` to keep Telegram's previous/default setting.
    public func resolvedAllowedUpdates(
        _ mode: TelerouteAllowedUpdates
    ) -> [String]? {
        switch mode {
        case .all:
            return UpdateKind.allCases.map(\.rawValue)
        case let .explicit(kinds):
            return kinds.map(\.rawValue).sorted()
        case .automatic:
            let graph = self.storage.routeGraph
            guard graph.unmatchedRoutes.isEmpty else {
                return UpdateKind.allCases.map(\.rawValue)
            }
            var kinds = graph.registeredKinds
            kinds.formUnion(graph.registeredMessageSources.map(\.updateKind))
            if graph.hasCommandRoutes || graph.hasMountedFlows {
                kinds.formUnion(TelerouteMessageSource.allCases.map(\.updateKind))
            }
            if graph.hasCallbackRoutes || graph.hasMountedFlows {
                kinds.insert(.callbackQuery)
            }
            guard kinds.isEmpty == false else { return nil }
            return kinds.map(\.rawValue).sorted()
        }
    }

    /// Creates an independent lifecycle-event stream for one consumer.
    public func eventStream(
        buffering: TelerouteEventBufferingPolicy = .newest(512)
    ) -> TelerouteEventSequence {
        self.eventHub.sequence(buffering: buffering)
    }

    /// Routes updates through the bounded executor. Each update runs the full
    /// pipeline: events, metrics, replay protection, flow/callback/command
    /// matching, and the central error path.
    public func process(_ updates: [Update]) async {
        guard self.updateExecutor.isShutdown == false else { return }

        for update in updates {
            let accepted = await self.updateExecutor.submit { [weak self] in
                await self?.handleUpdate(update)
            }
            guard accepted else { return }
        }
    }

    private func handleUpdate(_ update: Update) async {
        let startedAt = ContinuousClock().now
        let parsedUpdate = TelerouteParsedUpdate(update)
        let routeKind = parsedUpdate.routeKind
        let responderState = TelerouteResponderState()
        var handled = false
        do {
            self.emitEvent(.received, parsedUpdate: parsedUpdate, startedAt: startedAt)
            await self.metricsSink.recordReceived(
                routeKind: routeKind,
                chatId: parsedUpdate.chatId,
                userId: parsedUpdate.userId
            )
            self.log.debug("Received update", metadata: self.updateMetadata(for: parsedUpdate))
            guard await self.shouldHandle(parsedUpdate) else {
                self.emitEvent(.skippedDuplicate, parsedUpdate: parsedUpdate, startedAt: startedAt)
                await self.metricsSink.recordSkippedDuplicate(
                    routeKind: routeKind,
                    chatId: parsedUpdate.chatId,
                    userId: parsedUpdate.userId
                )
                self.log.debug("Skipped duplicate update", metadata: self.updateMetadata(for: parsedUpdate))
                return
            }
            let routeGraph = self.storage.routeGraph
            if try await self.processFlow(
                parsedUpdate, routeGraph: routeGraph, startedAt: startedAt, responderState: responderState
            ) {
                handled = true
                self.log.debug("Handled update with flow route", metadata: self.updateMetadata(for: parsedUpdate))
            } else if try await self.processCallback(
                parsedUpdate, routeGraph: routeGraph, startedAt: startedAt, responderState: responderState
            ) {
                handled = true
                self.log.debug("Handled update with callback route", metadata: self.updateMetadata(for: parsedUpdate))
            } else if try await self.processCommand(
                parsedUpdate, routeGraph: routeGraph, startedAt: startedAt, responderState: responderState
            ) {
                handled = true
                self.log.debug("Handled update with command route", metadata: self.updateMetadata(for: parsedUpdate))
            } else if try await self.processMessageRoutes(
                parsedUpdate, routeGraph: routeGraph, startedAt: startedAt, responderState: responderState
            ) {
                handled = true
                self.log.debug("Handled update with message route", metadata: self.updateMetadata(for: parsedUpdate))
            } else if try await self.processKindRoutes(
                parsedUpdate, routeGraph: routeGraph, startedAt: startedAt, responderState: responderState
            ) {
                handled = true
                self.log.debug("Handled update with update-kind route", metadata: self.updateMetadata(for: parsedUpdate))
            } else if try await self.processUnmatchedRoutes(
                parsedUpdate, routeGraph: routeGraph, startedAt: startedAt, responderState: responderState
            ) {
                handled = true
                self.log.debug("Handled update with unmatched hook", metadata: self.updateMetadata(for: parsedUpdate))
            } else {
                self.emitEvent(
                    .unmatched,
                    parsedUpdate: parsedUpdate,
                    startedAt: startedAt,
                    duration: startedAt.duration(to: ContinuousClock().now)
                )
                await self.metricsSink.recordUnmatched(
                    routeKind: routeKind,
                    chatId: parsedUpdate.chatId,
                    userId: parsedUpdate.userId
                )
                self.log.debug("No route matched update", metadata: self.updateMetadata(for: parsedUpdate))
            }
        } catch {
            handled = true
            await self.handleError(
                error, parsedUpdate: parsedUpdate, startedAt: startedAt, responderState: responderState
            )
        }
        if handled {
            await self.autoAnswerCallbackIfNeeded(parsedUpdate, responderState: responderState)
        }
    }

    /// Answers a handled callback query with an empty ack so the button never
    /// keeps spinning, unless the handler already answered (or opted out).
    private func autoAnswerCallbackIfNeeded(
        _ parsedUpdate: TelerouteParsedUpdate,
        responderState: TelerouteResponderState
    ) async {
        guard self.autoAnswerCallbackQueries,
              let callbackQuery = parsedUpdate.callbackQuery,
              responderState.answeredCallback == false else {
            return
        }
        do {
            try await self.bot.answerCallbackQuery(callbackQueryId: callbackQuery.id)
        } catch {
            self.log.debug(
                "Failed to auto-answer callback query",
                metadata: ["error": .string(String(reflecting: error))]
            )
        }
    }

    var processingTaskCount: Int {
        self.updateExecutor.count
    }

    func waitUntilIdle() async {
        await self.updateExecutor.waitUntilIdle()
    }

    private func updateMetadata(for parsedUpdate: TelerouteParsedUpdate) -> Logger.Metadata {
        var metadata: Logger.Metadata = [
            "update_id": .stringConvertible(parsedUpdate.update.updateId),
            "chat_id": .string(parsedUpdate.chatId.map(String.init) ?? "none"),
            "user_id": .string(parsedUpdate.userId.map(String.init) ?? "none"),
        ]

        if let command = parsedUpdate.command {
            metadata["route_kind"] = .string("command")
            metadata["command"] = .string(command.name)
        } else if let callbackData = parsedUpdate.callbackData {
            metadata["route_kind"] = .string("callback")
            metadata["callback_data"] = .string(callbackData)
        } else if let text = parsedUpdate.message?.text, text.isEmpty == false {
            metadata["route_kind"] = .string("message")
            metadata["message_text"] = .string(text)
        } else {
            metadata["route_kind"] = .string("unknown")
        }

        return metadata
    }

    private func logProcessingError(
        _ error: any Error,
        parsedUpdate: TelerouteParsedUpdate,
        context: TelerouteContext,
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?
    ) async {
        var metadata = self.updateMetadata(for: parsedUpdate)
        metadata.merge([
            "error_type": .string(String(reflecting: type(of: error))),
            "route_kind": .string(Self.routeKindDescription(routeKind)),
        ]) { _, new in new }
        if let routeName {
            metadata["route_name"] = .string(routeName)
        }

        if let command = parsedUpdate.command,
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
        if let apiError = error as? TelegramAPIError {
            return apiError.description
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
        case let .update(kind): kind.rawValue
        case .unknown: "unknown"
        }
    }

    private func shouldHandle(_ parsedUpdate: TelerouteParsedUpdate) async -> Bool {
        guard let replayProtectionStorage = self.replayProtectionStorage,
              let key = self.replayProtectionKey(for: parsedUpdate) else {
            return true
        }
        return await replayProtectionStorage.claim(key: key, ttl: self.replayProtectionTTL)
    }

    private func replayProtectionKey(for parsedUpdate: TelerouteParsedUpdate) -> String? {
        let chatID = parsedUpdate.chatId.map(String.init) ?? "none"
        let userID = parsedUpdate.userId.map(String.init) ?? "none"

        if let callbackData = parsedUpdate.callbackData {
            return "callback|\(chatID)|\(userID)|\(callbackData)"
        }

        if let command = parsedUpdate.command {
            return "command|\(chatID)|\(userID)|\(command.rawValue)|\(command.argumentsText ?? "")"
        }

        return nil
    }

    @discardableResult
    private func processFlow(
        _ parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        startedAt: ContinuousClock.Instant,
        responderState: TelerouteResponderState
    ) async throws -> Bool {
        let routeName = try await self.flowCoordinator.process(
            parsedUpdate,
            routeGraph: routeGraph,
            defaultParseMode: self.defaultParseMode,
            responderState: responderState
        ) { route, context, routeName in
            try await Self.run(
                executor: route.executor,
                context: context,
                routeKind: .flow,
                routeName: routeName
            )
        }
        guard let routeName else { return false }
        await self.emitHandled(
            parsedUpdate: parsedUpdate,
            routeKind: .flow,
            routeName: routeName,
            startedAt: startedAt
        )
        return true
    }

    @discardableResult
    private func processCommand(
        _ parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        startedAt: ContinuousClock.Instant,
        responderState: TelerouteResponderState
    ) async throws -> Bool {
        guard let command = parsedUpdate.command else {
            return false
        }
        for route in routeGraph.commandsByName[command.name] ?? [] where TelerouteCommandMatcher.matches(
            command,
            routeName: route.name,
            botUsername: route.botUsername
        ) {
            let context = TelerouteContext(
                bot: self.bot,
                parsedUpdate: parsedUpdate,
                parameters: .init(),
                command: command,
                defaultParseMode: self.defaultParseMode,
                flowStorage: self.flowStorage,
                flowSession: nil,
                responderState: responderState
            )
            let handled = try await Self.run(
                executor: route.executor,
                context: context,
                routeKind: .command,
                routeName: route.name
            )
            if handled == false {
                continue
            }
            await self.emitHandled(
                parsedUpdate: parsedUpdate,
                routeKind: .command,
                routeName: route.name,
                startedAt: startedAt
            )
            return true
        }
        return false
    }

    @discardableResult
    private func processCallback(
        _ parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        startedAt: ContinuousClock.Instant,
        responderState: TelerouteResponderState
    ) async throws -> Bool {
        guard parsedUpdate.callbackData != nil,
              let components = parsedUpdate.callbackComponents else {
            return false
        }
        for candidate in routeGraph.callbacks.candidates(for: components) {
            let route = candidate.route
            guard let parameters = candidate.pattern.match(components: components) else {
                continue
            }
            let context = TelerouteContext(
                bot: self.bot,
                parsedUpdate: parsedUpdate,
                parameters: parameters,
                command: nil,
                defaultParseMode: self.defaultParseMode,
                flowStorage: self.flowStorage,
                flowSession: nil,
                responderState: responderState
            )
            let handled = try await Self.run(
                executor: route.executor,
                context: context,
                routeKind: .callback,
                routeName: route.pattern.routeDescription
            )
            if handled == false {
                continue
            }
            await self.emitHandled(
                parsedUpdate: parsedUpdate,
                routeKind: .callback,
                routeName: route.pattern.routeDescription,
                startedAt: startedAt
            )
            return true
        }
        return false
    }

    @discardableResult
    private func processMessageRoutes(
        _ parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        startedAt: ContinuousClock.Instant,
        responderState: TelerouteResponderState
    ) async throws -> Bool {
        guard let message = parsedUpdate.message,
              let source = parsedUpdate.messageSource,
              routeGraph.messageRoutes.isEmpty == false else {
            return false
        }
        for route in routeGraph.messageRoutes {
            guard route.sources.contains(source),
                  route.filter.matches(message) else {
                continue
            }
            let context = TelerouteContext(
                bot: self.bot,
                parsedUpdate: parsedUpdate,
                parameters: .init(),
                command: nil,
                defaultParseMode: self.defaultParseMode,
                flowStorage: self.flowStorage,
                flowSession: nil,
                responderState: responderState
            )
            let handled = try await Self.run(
                executor: route.executor,
                context: context,
                routeKind: .message,
                routeName: route.name
            )
            if handled == false {
                continue
            }
            await self.emitHandled(
                parsedUpdate: parsedUpdate,
                routeKind: .message,
                routeName: route.name,
                startedAt: startedAt
            )
            return true
        }
        return false
    }

    @discardableResult
    private func processKindRoutes(
        _ parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        startedAt: ContinuousClock.Instant,
        responderState: TelerouteResponderState
    ) async throws -> Bool {
        guard let kind = parsedUpdate.kind,
              routeGraph.kindRoutes.isEmpty == false else {
            return false
        }
        for route in routeGraph.kindRoutes where route.kinds.contains(kind) {
            let context = TelerouteContext(
                bot: self.bot,
                parsedUpdate: parsedUpdate,
                parameters: .init(),
                command: parsedUpdate.command,
                defaultParseMode: self.defaultParseMode,
                flowStorage: self.flowStorage,
                flowSession: nil,
                responderState: responderState
            )
            let handled = try await Self.run(
                executor: route.executor,
                context: context,
                routeKind: .update(kind),
                routeName: route.name
            )
            if handled == false {
                continue
            }
            await self.emitHandled(
                parsedUpdate: parsedUpdate,
                routeKind: .update(kind),
                routeName: route.name,
                startedAt: startedAt
            )
            return true
        }
        return false
    }

    @discardableResult
    private func processUnmatchedRoutes(
        _ parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        startedAt: ContinuousClock.Instant,
        responderState: TelerouteResponderState
    ) async throws -> Bool {
        guard routeGraph.unmatchedRoutes.isEmpty == false else {
            return false
        }
        for route in routeGraph.unmatchedRoutes {
            let context = TelerouteContext(
                bot: self.bot,
                parsedUpdate: parsedUpdate,
                parameters: .init(),
                command: parsedUpdate.command,
                defaultParseMode: self.defaultParseMode,
                flowStorage: self.flowStorage,
                flowSession: nil,
                responderState: responderState
            )
            let handled = try await Self.run(
                executor: route.executor,
                context: context,
                routeKind: parsedUpdate.routeKind,
                routeName: "unmatched"
            )
            if handled {
                await self.emitHandled(
                    parsedUpdate: parsedUpdate,
                    routeKind: parsedUpdate.routeKind,
                    routeName: "unmatched",
                    startedAt: startedAt
                )
                return true
            }
        }
        return false
    }

    /// Central error path: emits a typed `.failed` event, logs with rich
    /// metadata, records metrics, and forwards to the user-supplied `onError`
    /// handler when set.
    private func handleError(
        _ error: any Error,
        parsedUpdate: TelerouteParsedUpdate,
        startedAt: ContinuousClock.Instant = ContinuousClock().now,
        responderState: TelerouteResponderState = .init()
    ) async {
        let routeFailure = error as? TelerouteRouteFailure
        let reportedError = routeFailure?.underlyingError ?? error
        guard (reportedError is CancellationError && Task.isCancelled) == false else {
            return
        }

        let context = routeFailure?.context ?? TelerouteContext(
            bot: self.bot,
            parsedUpdate: parsedUpdate,
            defaultParseMode: self.defaultParseMode,
            flowStorage: self.flowStorage,
            flowSession: nil,
            responderState: responderState
        )

        // An abort is a controlled outcome: render its response and report
        // the route as handled instead of failed.
        if let abort = reportedError as? TelerouteAbort {
            do {
                try await abort.response.execute(in: context)
            } catch {
                self.log.error(
                    "Failed to render abort response",
                    metadata: ["error": .string(String(reflecting: error))]
                )
            }
            await self.emitHandled(
                parsedUpdate: parsedUpdate,
                routeKind: routeFailure?.routeKind ?? parsedUpdate.routeKind,
                routeName: routeFailure?.routeName ?? "abort",
                startedAt: startedAt
            )
            return
        }

        if let render = self.errorRenderer,
           let response = await render(reportedError, context) {
            do {
                try await response.execute(in: context)
            } catch {
                self.log.error(
                    "Failed to render error response",
                    metadata: ["error": .string(String(reflecting: error))]
                )
            }
        }
        let duration = startedAt.duration(to: ContinuousClock().now)
        let routeKind = routeFailure?.routeKind ?? parsedUpdate.routeKind
        let routeName = routeFailure?.routeName
        self.eventHub.emit(
            .init(
                kind: .failed,
                routeKind: routeKind,
                routeName: routeName,
                updateId: parsedUpdate.update.updateId,
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
            parsedUpdate: parsedUpdate,
            context: context,
            routeKind: routeKind,
            routeName: routeName
        )
        await self.onError?(reportedError, context)
    }

    private func emitEvent(
        _ kind: TelerouteEvent.Kind,
        parsedUpdate: TelerouteParsedUpdate,
        routeKind: TelerouteEvent.RouteKind? = nil,
        routeName: String? = nil,
        startedAt: ContinuousClock.Instant = ContinuousClock().now,
        duration: Duration? = nil
    ) {
        self.eventHub.emit(
            .init(
                kind: kind,
                routeKind: routeKind ?? parsedUpdate.routeKind,
                routeName: routeName,
                updateId: parsedUpdate.update.updateId,
                chatId: parsedUpdate.chatId,
                userId: parsedUpdate.userId,
                startedAt: startedAt,
                duration: duration
            )
        )
    }

    /// Emits a `.handled` event with timing and records metrics for the matched route.
    private func emitHandled(
        parsedUpdate: TelerouteParsedUpdate,
        routeKind: TelerouteEvent.RouteKind,
        routeName: String,
        startedAt: ContinuousClock.Instant
    ) async {
        let duration = startedAt.duration(to: ContinuousClock().now)
        self.eventHub.emit(
            .init(
                kind: .handled,
                routeKind: routeKind,
                routeName: routeName,
                updateId: parsedUpdate.update.updateId,
                chatId: parsedUpdate.chatId,
                userId: parsedUpdate.userId,
                startedAt: startedAt,
                duration: duration
            )
        )
        await self.metricsSink.recordHandled(
            routeKind: routeKind,
            routeName: routeName,
            chatId: parsedUpdate.chatId,
            userId: parsedUpdate.userId,
            duration: duration
        )
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
        executor: TelerouteRouteExecutor,
        context: TelerouteContext,
        routeKind: TelerouteEvent.RouteKind,
        routeName: String
    ) async throws -> Bool {
        do {
            return try await executor.run(context: context)
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

private struct TelerouteRouteFailure: Error, Sendable {
    let underlyingError: any Error
    let context: TelerouteContext
    let routeKind: TelerouteEvent.RouteKind
    let routeName: String
}
