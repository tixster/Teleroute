
/// Coordinates flow session lookup, per-session ordering, and indexed step matching.
final class TelerouteFlowCoordinator: Sendable {
    typealias ExecuteRoute = @Sendable (
        _ route: TelerouteFlowRoute,
        _ context: TelerouteContext,
        _ routeName: String
    ) async throws -> Bool

    private let bot: TelegramBotClient
    private let flowStorage: any TelerouteFlowStorage
    private let queue: TelerouteCommandQueue
    private let cancellationPolicy: TelerouteFlowCancellationPolicy
    private let routeScope: TelerouteRoutes?
    /// Registry backing buttons that carry an inline handler. Flow steps render
    /// keyboards like any other handler, so they need the same store the
    /// runtime hands to its own contexts.
    private let inlineActions: TelerouteInlineActionStore?
    /// Configured session TTL, handed to each step context so a flow write can
    /// refresh the deadline.
    private let sessionTTL: Duration?
    private let metricsSink: (any TelerouteMetricsSink)?

    init(
        bot: TelegramBotClient,
        flowStorage: any TelerouteFlowStorage,
        queue: TelerouteCommandQueue,
        cancellationPolicy: TelerouteFlowCancellationPolicy,
        routeScope: TelerouteRoutes? = nil,
        inlineActions: TelerouteInlineActionStore? = nil,
        sessionTTL: Duration? = nil,
        metricsSink: (any TelerouteMetricsSink)? = nil
    ) {
        self.bot = bot
        self.flowStorage = flowStorage
        self.queue = queue
        self.cancellationPolicy = cancellationPolicy
        self.routeScope = routeScope
        self.inlineActions = inlineActions
        self.sessionTTL = sessionTTL
        self.metricsSink = metricsSink
    }

    func process(
        _ parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        defaultParseMode: ParseMode? = nil,
        responderState: TelerouteResponderState = .init(),
        logger: Logger,
        execute: @escaping ExecuteRoute
    ) async throws -> String? {
        guard routeGraph.hasMountedFlows, let flowKey = parsedUpdate.flowKey else {
            return nil
        }
        return try await self.queue.enqueue(key: TelerouteFlowQueueKey.key(for: flowKey)) {
            try await self.processSerially(
                parsedUpdate,
                flowKey: flowKey,
                routeGraph: routeGraph,
                defaultParseMode: defaultParseMode,
                responderState: responderState,
                logger: logger,
                execute: execute
            )
        }
    }

    private func processSerially(
        _ parsedUpdate: TelerouteParsedUpdate,
        flowKey: TelerouteFlowKey,
        routeGraph: TelerouteRouteGraph,
        defaultParseMode: ParseMode?,
        responderState: TelerouteResponderState,
        logger: Logger,
        execute: @escaping ExecuteRoute
    ) async throws -> String? {
        guard let session = await self.flowStorage.session(for: flowKey) else {
            return nil
        }
        // Expiry is enforced on read, here, inside the per-session serialized
        // section — so it cannot race a concurrent write, and a backend that
        // cannot expire keys of its own still behaves correctly. An expired
        // session is dropped and the update falls through to normal routing.
        if session.isExpired() {
            await self.flowStorage.removeSession(for: flowKey)
            await self.reportFlowEnded(session, outcome: .expired, key: flowKey)
            logger.debug(
                "Flow session expired",
                metadata: [
                    "flow_id": .string(session.id),
                    "flow_step": .string(session.step),
                ]
            )
            return nil
        }
        let key = TelerouteFlowStepKey(flowID: session.id, step: session.step)
        let routes = routeGraph.flowSteps[key] ?? .init()

        if parsedUpdate.callbackData != nil,
           let components = parsedUpdate.callbackComponents {
            for candidate in routes.callbacks.candidates(for: components) {
                guard let parameters = candidate.pattern.match(components: components) else {
                    continue
                }
                let routeName = "\(candidate.route.flowID):\(candidate.route.step)"
                let context = self.context(
                    for: parsedUpdate,
                    parameters: parameters,
                    command: nil,
                    session: session,
                    defaultParseMode: defaultParseMode,
                    responderState: responderState,
                    logger: logger
                )
                if try await execute(candidate.route, context, routeName) {
                    return routeName
                }
            }
            return nil
        }

        if let command = parsedUpdate.command {
            for route in routes.commandsByName[command.name] ?? [] {
                guard case let .command(name, botUsername) = route.matcher,
                      TelerouteCommandMatcher.matches(
                        command,
                        routeName: name,
                        botUsername: botUsername
                      ) else {
                    continue
                }
                let routeName = "\(route.flowID):\(route.step):\(name)"
                let context = self.context(
                    for: parsedUpdate,
                    command: command,
                    session: session,
                    defaultParseMode: defaultParseMode,
                    responderState: responderState,
                    logger: logger
                )
                if try await execute(route, context, routeName) {
                    return routeName
                }
            }
            if self.cancellationPolicy.cancelsSessionOnUnmatchedCommand {
                await self.flowStorage.removeSession(for: flowKey)
                await self.reportFlowEnded(session, outcome: .cancelled, key: flowKey)
            }
            return nil
        }

        guard parsedUpdate.message != nil else { return nil }
        for route in routes.messages {
            let routeName = "\(route.flowID):\(route.step)"
            let context = self.context(
                for: parsedUpdate,
                session: session,
                defaultParseMode: defaultParseMode,
                responderState: responderState,
                logger: logger
            )
            if try await execute(route, context, routeName) {
                return routeName
            }
        }
        return nil
    }

    private func reportFlowEnded(
        _ session: TelerouteFlowSession,
        outcome: TelerouteFlowOutcome,
        key: TelerouteFlowKey
    ) async {
        guard let metricsSink = self.metricsSink else { return }
        let age = Date().timeIntervalSince(session.createdAt)
        await metricsSink.recordFlowEnded(
            flowID: session.id,
            step: session.step,
            outcome: outcome,
            age: .seconds(max(age, 0)),
            chatId: key.chatId,
            userId: key.userId
        )
    }

    private func context(
        for parsedUpdate: TelerouteParsedUpdate,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil,
        session: TelerouteFlowSession,
        defaultParseMode: ParseMode?,
        responderState: TelerouteResponderState,
        logger: Logger
    ) -> TelerouteContext {
        var stepLogger = parsedUpdate.logger(from: logger)
        stepLogger[metadataKey: "flow_id"] = .string(session.id)
        stepLogger[metadataKey: "flow_step"] = .string(session.step)
        return .init(
            bot: self.bot,
            parsedUpdate: parsedUpdate,
            parameters: parameters,
            command: command,
            defaultParseMode: defaultParseMode,
            logger: stepLogger,
            flowStorage: self.flowStorage,
            flowSession: session,
            flowSessionTTL: self.sessionTTL,
            metricsSink: self.metricsSink,
            responderState: responderState,
            routeScope: self.routeScope,
            inlineActions: self.inlineActions
        )
    }
}
