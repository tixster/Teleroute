import SwiftTelegramBot

@_spi(Testing)
public extension TelerouteRuntime {
    /// Creates a nested route scope from the router root.
    @discardableResult
    func group(
        _ path: String,
        middlewares: [any TelerouteMiddleware] = [],
        guards: [any TelerouteGuard] = []
    ) -> TelerouteRoutes {
        self.routeScope.group(
            path,
            middlewares: middlewares,
            guards: guards
        )
    }

    /// Creates and configures a nested route scope from the router root.
    func group(
        _ path: String,
        middlewares: [any TelerouteMiddleware] = [],
        guards: [any TelerouteGuard] = [],
        configure: (TelerouteRoutes) -> Void
    ) {
        self.routeScope.group(
            path,
            middlewares: middlewares,
            guards: guards,
            configure: configure
        )
    }

    /// Registers a command route at the router root.
    func command(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping TelerouteHandler
    ) {
        self.routeScope.command(
            path,
            botUsername: botUsername,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue,
            use: handler
        )
    }

    /// Registers a callback route at the router root.
    func callback(
        _ path: String,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping TelerouteHandler
    ) {
        self.routeScope.callback(
            path,
            guards: guards,
            middlewares: middlewares,
            use: handler
        )
    }

    /// Generates callback data for a typed callback at the router root.
    func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.routeScope.callbackData(for: callback)
    }

    /// Renders one typed button description at the router root.
    func render(_ button: TelerouteButton) throws -> TGInlineKeyboardButton {
        try self.routeScope.render(button)
    }

    /// Renders callback button descriptions in the router root scope.
    func keyboard(
        _ rows: [[TelerouteButton]]
    ) throws -> TGInlineKeyboardMarkup {
        try self.routeScope.keyboard(rows)
    }

    /// Duplicate unguarded route signatures detected in this router.
    var duplicateRouteSignatures: [TelerouteRouteSignature] {
        self.routeScope.duplicateRouteSignatures
    }
}
