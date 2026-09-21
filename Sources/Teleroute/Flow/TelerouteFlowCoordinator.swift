
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
            await self.endSession(
                session,
                reason: .expired,
                key: flowKey,
                parsedUpdate: parsedUpdate,
                routeGraph: routeGraph,
                defaultParseMode: defaultParseMode,
                responderState: responderState,
                logger: logger
            )
            logger.debug(
                "Flow session expired",
                metadata: [
                    "flow_id": .string(session.id),
                    "flow_step": .string(session.step),
                ]
            )
            return nil
        }
        // A suspended session stays in storage — it simply stops intercepting,
        // so the update routes normally until the flow is resumed. Unlike an
        // expired one it is NOT removed, and its TTL keeps running.
        if session.isSuspended {
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
            return try await self.handleUnmatchedCommand(
                command,
                session: session,
                flowKey: flowKey,
                parsedUpdate: parsedUpdate,
                routeGraph: routeGraph,
                defaultParseMode: defaultParseMode,
                responderState: responderState,
                logger: logger
            )
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

    /// Decides what happens to an active session when a command it does not
    /// handle at this step arrives.
    ///
    /// Without a registered `onInterrupt`, the configured cancellation policy
    /// decides exactly as it did before hooks existed.
    private func handleUnmatchedCommand(
        _ command: TelerouteCommandMatch,
        session: TelerouteFlowSession,
        flowKey: TelerouteFlowKey,
        parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        defaultParseMode: ParseMode?,
        responderState: TelerouteResponderState,
        logger: Logger
    ) async throws -> String? {
        let hooks = routeGraph.flowHooks[session.id]
        let decision: TelerouteFlowInterruption
        if let onInterrupt = hooks?.onInterrupt {
            let context = self.endContext(
                session: session,
                parsedUpdate: parsedUpdate,
                command: command,
                defaultParseMode: defaultParseMode,
                responderState: responderState,
                logger: logger
            )
            decision = await onInterrupt(context, command)
        } else {
            decision = self.cancellationPolicy.cancelsSessionOnUnmatchedCommand ? .cancel : .keep
        }

        switch decision {
        case .keep:
            return nil

        case .cancel:
            await self.flowStorage.removeSession(for: flowKey)
            await self.endSession(
                session,
                reason: .interrupted(command: command.name),
                key: flowKey,
                parsedUpdate: parsedUpdate,
                routeGraph: routeGraph,
                defaultParseMode: defaultParseMode,
                responderState: responderState,
                logger: logger
            )
            return nil

        case .suspend:
            await self.flowStorage.updateSession(for: flowKey) { current in
                current?.suspended(at: Date())
            }
            return nil

        case let .handled(response):
            // The flow answered, so the command stops here: returning a route
            // name marks the update handled and the runtime does not continue
            // to the global command routes.
            let context = self.context(
                for: parsedUpdate,
                command: command,
                session: session,
                defaultParseMode: defaultParseMode,
                responderState: responderState,
                logger: logger
            )
            try await response.execute(in: context)
            return "\(session.id):\(session.step):interrupt"
        }
    }

    /// Removes-and-reports is already done by the caller; this reports the end
    /// to the metrics sink and hands it to the flow's `onEnd` hook.
    private func endSession(
        _ session: TelerouteFlowSession,
        reason: TelerouteFlowEndReason,
        key: TelerouteFlowKey,
        parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
        defaultParseMode: ParseMode?,
        responderState: TelerouteResponderState,
        logger: Logger
    ) async {
        await self.reportFlowEnded(session, outcome: reason.outcome, key: key)
        guard let onEnd = routeGraph.flowHooks[session.id]?.onEnd else { return }
        let context = self.endContext(
            session: session,
            parsedUpdate: parsedUpdate,
            command: parsedUpdate.command,
            defaultParseMode: defaultParseMode,
            responderState: responderState,
            logger: logger
        )
        await onEnd(context, reason)
    }

    private func endContext(
        session: TelerouteFlowSession,
        parsedUpdate: TelerouteParsedUpdate,
        command: TelerouteCommandMatch?,
        defaultParseMode: ParseMode?,
        responderState: TelerouteResponderState,
        logger: Logger
    ) -> TelerouteFlowEndContext {
        .init(
            coreContext: self.context(
                for: parsedUpdate,
                command: command,
                session: session,
                defaultParseMode: defaultParseMode,
                responderState: responderState,
                logger: logger
            ),
            endedSession: session
        )
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
