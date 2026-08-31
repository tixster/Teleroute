public extension TelerouteFlowGroup {
    /// Registers a typed callback handler for a flow step and returns its route.
    @discardableResult
    func callback<Callback: TelerouteCallback, StepValue>(
        _ callbackType: Callback.Type,
        at step: StepValue,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (
            _ callback: Callback,
            _ context: TelerouteFlowContext<Flow>
        ) async throws -> Void
    ) -> TelerouteCallbackRoute<Callback> where StepValue == Flow.Step {
        self.callback(
            Callback.path,
            at: step,
            guards: guards,
            middlewares: middlewares
        ) { context in
            try await handler(Callback(parameters: context.parameters), context)
        }
        return .init(callbackType, routes: self.routeScope)
    }

    /// Generates callback data for a typed callback value in this flow's scope.
    func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.routeScope.callbackData(for: callback)
    }
}
