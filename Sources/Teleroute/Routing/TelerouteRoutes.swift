import Foundation

/// A scoped route-registration and callback-generation context.
///
/// Root routes are registered directly on `Teleroute`. Calling
/// ``Teleroute/group(_:middlewares:guards:)`` or
/// ``group(_:middlewares:guards:)`` creates a `TelerouteRoutes` value with
/// inherited prefixes, middleware, and guards. Modules also receive this type
/// so they can mount into either the router root or a nested scope.
@_spi(Testing)
public final class TelerouteRoutes: Sendable {
    let storage: TelerouteStorage
    let commandPrefix: [String]
    let callbackPrefix: [String]
    let inheritedMiddlewares: [any TelerouteMiddleware<TelerouteContext>]
    let inheritedGuards: [any TelerouteGuard]

    init(
        storage: TelerouteStorage,
        commandPrefix: [String] = [],
        callbackPrefix: [String] = [],
        inheritedMiddlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        inheritedGuards: [any TelerouteGuard] = []
    ) {
        self.storage = storage
        self.commandPrefix = commandPrefix
        self.callbackPrefix = callbackPrefix
        self.inheritedMiddlewares = inheritedMiddlewares
        self.inheritedGuards = inheritedGuards
    }

    /// Creates a nested route scope.
    @discardableResult
    public func group(
        _ path: String,
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        guards: [any TelerouteGuard] = []
    ) -> TelerouteRoutes {
        let components = TeleroutePath.components(from: path)
        return .init(
            storage: self.storage,
            commandPrefix: self.commandPrefix + components,
            callbackPrefix: self.callbackPrefix + components,
            inheritedMiddlewares: self.inheritedMiddlewares + middlewares,
            inheritedGuards: self.inheritedGuards + guards
        )
    }

    /// Creates and configures a nested route scope inline.
    public func group(
        _ path: String,
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        guards: [any TelerouteGuard] = [],
        configure: (TelerouteRoutes) -> Void
    ) {
        configure(
            self.group(
                path,
                middlewares: middlewares,
                guards: guards
            )
        )
    }

    /// Registers a command route.
    public func command(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping TelerouteHandler
    ) {
        let name = TeleroutePath.commandName(prefix: self.commandPrefix, path: path)
        let hasGuard = self.inheritedGuards.isEmpty == false || guards.isEmpty == false
        var resolvedMiddlewares = TelerouteMiddlewareComposer.resolve(
            inheritedMiddlewares: self.inheritedMiddlewares,
            inheritedGuards: self.inheritedGuards,
            guards: guards,
            middlewares: middlewares
        )
        if let queue {
            let queueMiddleware = TelerouteCommandQueueMiddleware(
                queue: self.storage.commandQueue,
                routeName: name,
                scope: queue
            )
            resolvedMiddlewares.insert(queueMiddleware, at: hasGuard ? 1 : 0)
        }
        if let description {
            for visibility in visibility {
                self.storage.appendPublishedCommand(
                    .init(name: name, description: description, visibility: visibility)
                )
            }
        }
        self.storage.appendCommandRoute(
            .init(
                name: name,
                botUsername: botUsername,
                middlewares: resolvedMiddlewares,
                handler: handler
            ),
            signature: hasGuard
                ? nil
                : .init(kind: .command, name: name, botUsername: botUsername)
        )
    }


    /// Registers a command route with a side-effect-only handler.
    public func command(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) {
        self.command(
            path,
            botUsername: botUsername,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue
        ) { context in
            try await handler(context)
            return .none
        }
    }

    /// Registers a callback route with a side-effect-only handler.
    public func callback(
        _ path: String,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) {
        self.callback(
            path,
            guards: guards,
            middlewares: middlewares
        ) { context in
            try await handler(context)
            return .none
        }
    }

    /// Registers a callback route using a path-style pattern.
    public func callback(
        _ path: String,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping TelerouteHandler
    ) {
        let hasGuard = self.inheritedGuards.isEmpty == false || guards.isEmpty == false
        let resolvedMiddlewares = TelerouteMiddlewareComposer.resolve(
            inheritedMiddlewares: self.inheritedMiddlewares,
            inheritedGuards: self.inheritedGuards,
            guards: guards,
            middlewares: middlewares
        )
        let pattern = TelerouteCallbackPattern(prefix: self.callbackPrefix, path: path)
        self.storage.appendCallbackRoute(
            .init(
                pattern: pattern,
                middlewares: resolvedMiddlewares,
                handler: handler
            ),
            signature: hasGuard
                ? nil
                : .init(kind: .callback, name: pattern.routeDescription)
        )
    }

    /// Generates callback data for a typed callback value.
    public func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.callbackPattern(for: callback).render(parameters: callback.parameters)
    }

    /// Renders one typed button description in this route scope.
    public func render(_ button: TelerouteButton) throws -> InlineKeyboardButton {
        try button.render(in: self)
    }

    /// Renders callback button descriptions into Telegram keyboard rows.
    public func keyboard(
        _ rows: [[TelerouteButton]]
    ) throws -> InlineKeyboardMarkup {
        try .init(
            inlineKeyboard: rows.map { row in
                try row.map { try $0.render(in: self) }
            }
        )
    }

    /// Duplicate unguarded route signatures detected in this router.
    public var duplicateRouteSignatures: [TelerouteRouteSignature] {
        self.storage.duplicateRouteSignatures
    }

    func callbackPattern(for callback: any TelerouteCallback) -> TelerouteCallbackPattern {
        .init(
            prefix: self.callbackPrefix,
            path: type(of: callback).path
        )
    }

    func registeredCallbackData(for callback: any TelerouteCallback) throws -> String {
        let pattern = self.callbackPattern(for: callback)
        guard self.storage.containsCallbackRoute(pattern.routeDescription) else {
            throw TelerouteError.callbackRouteNotRegistered(pattern.routeDescription)
        }
        return try pattern.render(parameters: callback.parameters)
    }
}
