
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

    init(
        bot: TelegramBotClient,
        flowStorage: any TelerouteFlowStorage,
        queue: TelerouteCommandQueue,
        cancellationPolicy: TelerouteFlowCancellationPolicy
    ) {
        self.bot = bot
        self.flowStorage = flowStorage
        self.queue = queue
        self.cancellationPolicy = cancellationPolicy
    }

    func process(
        _ parsedUpdate: TelerouteParsedUpdate,
        routeGraph: TelerouteRouteGraph,
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
                execute: execute
            )
        }
    }

    private func processSerially(
        _ parsedUpdate: TelerouteParsedUpdate,
        flowKey: TelerouteFlowKey,
        routeGraph: TelerouteRouteGraph,
        execute: @escaping ExecuteRoute
    ) async throws -> String? {
        guard let session = await self.flowStorage.session(for: flowKey) else {
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
                    session: session
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
                    session: session
                )
                if try await execute(route, context, routeName) {
                    return routeName
                }
            }
            if self.cancellationPolicy.cancelsSessionOnUnmatchedCommand {
                await self.flowStorage.removeSession(for: flowKey)
            }
            return nil
        }

        guard parsedUpdate.message != nil else { return nil }
        for route in routes.messages {
            let routeName = "\(route.flowID):\(route.step)"
            let context = self.context(for: parsedUpdate, session: session)
            if try await execute(route, context, routeName) {
                return routeName
            }
        }
        return nil
    }

    private func context(
        for parsedUpdate: TelerouteParsedUpdate,
        parameters: TelerouteParameters = .init(),
        command: TelerouteCommandMatch? = nil,
        session: TelerouteFlowSession
    ) -> TelerouteContext {
        .init(
            bot: self.bot,
            parsedUpdate: parsedUpdate,
            parameters: parameters,
            command: command,
            flowStorage: self.flowStorage,
            flowSession: session
        )
    }
}
