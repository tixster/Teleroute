public extension TelerouteRoutes {
    /// Registers a typed command that handles itself.
    func command<Command: TelerouteHandlingCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil
    ) {
        self.command(
            commandType,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue
        ) { command, context in
            try await command.handle(context: context)
        }
    }

    /// Registers a typed command handler.
    func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (_ command: Command, _ context: TelerouteContext) async throws -> Void
    ) {
        self.command(
            Command.path,
            botUsername: Command.botUsername,
            description: description ?? Command.commandDescription,
            visibility: visibility ?? Command.visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue ?? Command.queue
        ) { context in
            guard let match = context.command else {
                throw TelerouteError.commandMatchMissing
            }
            try await handler(Command(command: match), context)
        }
    }

    /// Registers a typed callback that handles itself and returns its scope-bound route.
    @discardableResult
    func callback<Callback: TelerouteHandlingCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = []
    ) -> TelerouteCallbackRoute<Callback> {
        self.callback(
            callbackType,
            guards: guards,
            middlewares: middlewares
        ) { callback, context in
            try await callback.handle(context: context)
        }
    }

    /// Registers a typed callback handler and returns its scope-bound route.
    @discardableResult
    func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (_ callback: Callback, _ context: TelerouteContext) async throws -> Void
    ) -> TelerouteCallbackRoute<Callback> {
        self.callback(
            Callback.path,
            guards: guards,
            middlewares: middlewares
        ) { context in
            try await handler(Callback(parameters: context.parameters), context)
        }
        return .init(callbackType, routes: self)
    }
}

public extension Teleroute {
    /// Registers a typed command that handles itself at the router root.
    func command<Command: TelerouteHandlingCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil
    ) {
        self.routeScope.command(
            commandType,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue
        )
    }

    /// Registers a typed command handler at the router root.
    func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (_ command: Command, _ context: TelerouteContext) async throws -> Void
    ) {
        self.routeScope.command(
            commandType,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue,
            use: handler
        )
    }

    /// Registers a typed callback that handles itself and returns its root route.
    @discardableResult
    func callback<Callback: TelerouteHandlingCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = []
    ) -> TelerouteCallbackRoute<Callback> {
        self.routeScope.callback(
            callbackType,
            guards: guards,
            middlewares: middlewares
        )
    }

    /// Registers a typed callback handler and returns its root route.
    @discardableResult
    func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (_ callback: Callback, _ context: TelerouteContext) async throws -> Void
    ) -> TelerouteCallbackRoute<Callback> {
        self.routeScope.callback(
            callbackType,
            guards: guards,
            middlewares: middlewares,
            use: handler
        )
    }
}
