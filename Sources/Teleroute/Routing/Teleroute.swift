import Foundation
import Synchronization

/// Middleware for statically typed request contexts.
///
/// Unlike low-level ``TelerouteMiddleware``, this middleware can replace a
/// custom context and return a ``TelerouteResponse``. It is added through a
/// router or group's ``TelerouteRouterGroup/middlewares`` collection.
public protocol TelerouteRouterMiddleware: Sendable {
    associatedtype Context: TelerouteRequestContext

    func handle(
        _ context: Context,
        next: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse
}

private struct AnyTelerouteRouterMiddleware<Context: TelerouteRequestContext>: Sendable {
    let handle: @Sendable (
        _ context: Context,
        _ next: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse

    init<Middleware: TelerouteRouterMiddleware>(_ middleware: Middleware)
    where Middleware.Context == Context {
        self.handle = middleware.handle
    }
}

private final class TelerouteCoreMiddlewareStorage: Sendable {
    private let valuesStorage = Mutex<[any TelerouteMiddleware]>([])

    var values: [any TelerouteMiddleware] {
        self.valuesStorage.withLock { $0 }
    }

    func append(_ middleware: any TelerouteMiddleware) {
        self.valuesStorage.withLock { $0.append(middleware) }
    }
}

private final class TelerouteTypedMiddlewareStorage<Context: TelerouteRequestContext>: Sendable {
    private let valuesStorage = Mutex<[AnyTelerouteRouterMiddleware<Context>]>([])

    var values: [AnyTelerouteRouterMiddleware<Context>] {
        self.valuesStorage.withLock { $0 }
    }

    func append<Middleware: TelerouteRouterMiddleware>(_ middleware: Middleware)
    where Middleware.Context == Context {
        self.valuesStorage.withLock {
            $0.append(.init(middleware))
        }
    }
}

private final class TelerouteGuardStorage: Sendable {
    private let valuesStorage = Mutex<[any TelerouteGuard]>([])

    var values: [any TelerouteGuard] {
        self.valuesStorage.withLock { $0 }
    }

    func append(_ guardValue: any TelerouteGuard) {
        self.valuesStorage.withLock { $0.append(guardValue) }
    }
}

/// Mutable middleware collection attached to one router scope.
///
/// Middleware is snapshotted and compiled when a route or child group is
/// registered. Add middleware before registering the routes that should use it.
public final class TelerouteRouterMiddlewareCollection<Context: TelerouteRequestContext>: Sendable {
    private let coreStorage: TelerouteCoreMiddlewareStorage
    private let typedStorage: TelerouteTypedMiddlewareStorage<Context>

    fileprivate init(
        coreStorage: TelerouteCoreMiddlewareStorage,
        typedStorage: TelerouteTypedMiddlewareStorage<Context>
    ) {
        self.coreStorage = coreStorage
        self.typedStorage = typedStorage
    }

    /// Adds existing low-level middleware that operates on
    /// ``TelerouteContext``.
    public func add(_ middleware: any TelerouteMiddleware) {
        self.coreStorage.append(middleware)
    }

    /// Adds response-returning middleware for this scope's custom context.
    public func add<Middleware: TelerouteRouterMiddleware>(_ middleware: Middleware)
    where Middleware.Context == Context {
        self.typedStorage.append(middleware)
    }
}

/// Mutable guard collection attached to one router scope.
public final class TelerouteRouterGuardCollection: Sendable {
    private let storage: TelerouteGuardStorage

    fileprivate init(storage: TelerouteGuardStorage) {
        self.storage = storage
    }

    /// Adds a guard to routes registered after this call.
    public func add(_ guardValue: any TelerouteGuard) {
        self.storage.append(guardValue)
    }
}

typealias TelerouteContextHandler<Context: TelerouteRequestContext> = @Sendable (
    Context
) async throws -> TelerouteResponse

typealias TelerouteContextExecutor<Context: TelerouteRequestContext> = @Sendable (
    _ coreContext: TelerouteContext,
    _ handler: @escaping TelerouteContextHandler<Context>
) async throws -> TelerouteResponse

private struct TelerouteFlowContextMiddlewareAdapter<Context: TelerouteRequestContext>:
    TelerouteMiddleware,
    TelerouteConsumingMiddleware
{
    let executor: TelerouteContextExecutor<Context>

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        let response = try await self.executor(context) { typedContext in
            try await next(typedContext.coreContext)
            return .none
        }
        try await response.execute(in: context)
    }
}

/// A command/callback namespace with inherited middleware, guards, and a
/// statically typed request context.
public class TelerouteRouterGroup<Context: TelerouteRequestContext>: @unchecked Sendable {
    let routes: TelerouteRoutes
    private let baseContextExecutor: TelerouteContextExecutor<Context>
    private let coreMiddlewareStorage: TelerouteCoreMiddlewareStorage
    private let typedMiddlewareStorage: TelerouteTypedMiddlewareStorage<Context>
    private let guardStorage: TelerouteGuardStorage

    /// Middleware applied to subsequently registered routes and child groups.
    public let middlewares: TelerouteRouterMiddlewareCollection<Context>
    /// Guards applied to subsequently registered routes and child groups.
    public let guards: TelerouteRouterGuardCollection

    init(
        routes: TelerouteRoutes,
        baseContextExecutor: @escaping TelerouteContextExecutor<Context>
    ) {
        let coreMiddlewareStorage = TelerouteCoreMiddlewareStorage()
        let typedMiddlewareStorage = TelerouteTypedMiddlewareStorage<Context>()
        let guardStorage = TelerouteGuardStorage()

        self.routes = routes
        self.baseContextExecutor = baseContextExecutor
        self.coreMiddlewareStorage = coreMiddlewareStorage
        self.typedMiddlewareStorage = typedMiddlewareStorage
        self.guardStorage = guardStorage
        self.middlewares = .init(
            coreStorage: coreMiddlewareStorage,
            typedStorage: typedMiddlewareStorage
        )
        self.guards = .init(storage: guardStorage)
    }

    /// Creates a nested command/callback namespace.
    @discardableResult
    public func group(
        _ path: String,
        middlewares: [any TelerouteMiddleware] = [],
        guards: [any TelerouteGuard] = []
    ) -> TelerouteRouterGroup<Context> {
        .init(
            routes: self.routes.group(
                path,
                middlewares: self.coreMiddlewareStorage.values + middlewares,
                guards: self.guardStorage.values + guards
            ),
            baseContextExecutor: self.makeContextExecutor()
        )
    }

    /// Creates and configures a nested namespace inline.
    public func group(
        _ path: String,
        middlewares: [any TelerouteMiddleware] = [],
        guards: [any TelerouteGuard] = [],
        configure: (TelerouteRouterGroup<Context>) -> Void
    ) {
        configure(
            self.group(
                path,
                middlewares: middlewares,
                guards: guards
            )
        )
    }

    /// Creates a nested namespace whose handlers receive a refined child
    /// context.
    @discardableResult
    public func group<ChildContext: TelerouteChildRequestContext>(
        _ path: String = "",
        context _: ChildContext.Type,
        middlewares: [any TelerouteMiddleware] = [],
        guards: [any TelerouteGuard] = []
    ) -> TelerouteRouterGroup<ChildContext>
    where ChildContext.ParentContext == Context {
        let parentExecutor = self.makeContextExecutor()
        let childRoutes = self.routes.group(
            path,
            middlewares: self.coreMiddlewareStorage.values + middlewares,
            guards: self.guardStorage.values + guards
        )
        return .init(
            routes: childRoutes,
            baseContextExecutor: { coreContext, handler in
                try await parentExecutor(coreContext) { parentContext in
                    let childContext = try await ChildContext(context: parentContext)
                    return try await handler(childContext)
                }
            }
        )
    }

    /// Creates and configures a child-context namespace inline.
    public func group<ChildContext: TelerouteChildRequestContext>(
        _ path: String = "",
        context: ChildContext.Type,
        middlewares: [any TelerouteMiddleware] = [],
        guards: [any TelerouteGuard] = [],
        configure: (TelerouteRouterGroup<ChildContext>) -> Void
    ) where ChildContext.ParentContext == Context {
        configure(
            self.group(
                path,
                context: context,
                middlewares: middlewares,
                guards: guards
            )
        )
    }

    /// Registers a command whose handler performs Telegram operations directly.
    public func onCommand(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (Context) async throws -> Void
    ) {
        self.registerCommand(
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

    /// Registers a command whose handler returns a declarative Telegram action.
    public func command(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) {
        self.registerCommand(
            path,
            botUsername: botUsername,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue,
            handler: handler
        )
    }

    /// Registers a callback whose handler performs Telegram operations directly.
    public func onCallback(
        _ path: String,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (Context) async throws -> Void
    ) {
        self.registerCallback(
            path,
            guards: guards,
            middlewares: middlewares
        ) { context in
            try await handler(context)
            return .none
        }
    }

    /// Registers a callback whose handler returns a declarative Telegram action.
    public func callback(
        _ path: String,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) {
        self.registerCallback(
            path,
            guards: guards,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Registers a typed command with a direct side-effect handler.
    public func onCommand<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (Command, Context) async throws -> Void
    ) {
        self.registerTypedCommand(
            commandType,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue
        ) { command, context in
            try await handler(command, context)
            return .none
        }
    }

    /// Registers a typed command with a response-returning handler.
    public func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (Command, Context) async throws -> TelerouteResponse
    ) {
        self.registerTypedCommand(
            commandType,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue,
            handler: handler
        )
    }

    /// Registers a typed callback with a direct side-effect handler and returns
    /// its scope-bound route handle.
    @discardableResult
    public func onCallback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (Callback, Context) async throws -> Void
    ) -> TelerouteCallbackRoute<Callback> {
        self.registerTypedCallback(
            callbackType,
            guards: guards,
            middlewares: middlewares
        ) { callback, context in
            try await handler(callback, context)
            return .none
        }
    }

    /// Registers a typed callback with a response-returning handler.
    @discardableResult
    public func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (Callback, Context) async throws -> TelerouteResponse
    ) -> TelerouteCallbackRoute<Callback> {
        self.registerTypedCallback(
            callbackType,
            guards: guards,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Mounts a stateful flow in this command/callback namespace.
    public func flow<Flow: TelerouteFlow>(_ flow: Flow) {
        var middlewares = self.coreMiddlewareStorage.values
        let hasCustomContext = ObjectIdentifier(Context.self)
            != ObjectIdentifier(TelerouteContext.self)
        if hasCustomContext || self.typedMiddlewareStorage.values.isEmpty == false {
            middlewares.append(
                TelerouteFlowContextMiddlewareAdapter(
                    executor: self.makeContextExecutor()
                )
            )
        }
        self.routes.group(
            "",
            middlewares: middlewares,
            guards: self.guardStorage.values
        )
        .flow(flow)
    }

    /// Generates callback data in this namespace.
    public func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.routes.callbackData(for: callback)
    }

    /// Renders one typed button description in this namespace.
    public func render(_ button: TelerouteButton) throws -> InlineKeyboardButton {
        try self.routes.render(button)
    }

    /// Renders typed button descriptions into Telegram keyboard rows.
    public func keyboard(_ rows: [[TelerouteButton]]) throws -> InlineKeyboardMarkup {
        try self.routes.keyboard(rows)
    }

    /// Duplicate unguarded routes detected in this router.
    public var duplicateRouteSignatures: [TelerouteRouteSignature] {
        self.routes.duplicateRouteSignatures
    }

    private func registerCommand(
        _ path: String,
        botUsername: String?,
        description: String?,
        visibility: [TelerouteCommandVisibility],
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware],
        queue: TelerouteQueueScope?,
        handler: @escaping TelerouteContextHandler<Context>
    ) {
        let contextExecutor = self.makeContextExecutor()
        self.routes.command(
            path,
            botUsername: botUsername,
            description: description,
            visibility: visibility,
            guards: self.guardStorage.values + guards,
            middlewares: self.coreMiddlewareStorage.values + middlewares,
            queue: queue
        ) { coreContext in
            let response = try await contextExecutor(coreContext, handler)
            try await response.execute(in: coreContext)
        }
    }

    private func registerCallback(
        _ path: String,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware],
        handler: @escaping TelerouteContextHandler<Context>
    ) {
        let contextExecutor = self.makeContextExecutor()
        self.routes.callback(
            path,
            guards: self.guardStorage.values + guards,
            middlewares: self.coreMiddlewareStorage.values + middlewares
        ) { coreContext in
            let response = try await contextExecutor(coreContext, handler)
            try await response.execute(in: coreContext)
        }
    }

    private func registerTypedCommand<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String?,
        visibility: [TelerouteCommandVisibility]?,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware],
        queue: TelerouteQueueScope?,
        handler: @escaping @Sendable (Command, Context) async throws -> TelerouteResponse
    ) {
        let contextExecutor = self.makeContextExecutor()
        self.routes.command(
            commandType,
            description: description,
            visibility: visibility,
            guards: self.guardStorage.values + guards,
            middlewares: self.coreMiddlewareStorage.values + middlewares,
            queue: queue
        ) { command, coreContext in
            let response = try await contextExecutor(coreContext) { context in
                try await handler(command, context)
            }
            try await response.execute(in: coreContext)
        }
    }

    private func registerTypedCallback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware],
        handler: @escaping @Sendable (Callback, Context) async throws -> TelerouteResponse
    ) -> TelerouteCallbackRoute<Callback> {
        let contextExecutor = self.makeContextExecutor()
        return self.routes.callback(
            callbackType,
            guards: self.guardStorage.values + guards,
            middlewares: self.coreMiddlewareStorage.values + middlewares
        ) { callback, coreContext in
            let response = try await contextExecutor(coreContext) { context in
                try await handler(callback, context)
            }
            try await response.execute(in: coreContext)
        }
    }

    private func makeContextExecutor() -> TelerouteContextExecutor<Context> {
        let baseContextExecutor = self.baseContextExecutor
        let middlewares = self.typedMiddlewareStorage.values
        return { coreContext, handler in
            try await baseContextExecutor(coreContext) { context in
                var next = handler
                for middleware in middlewares.reversed() {
                    let downstream = next
                    next = { nextContext in
                        try await middleware.handle(nextContext, downstream)
                    }
                }
                return try await next(context)
            }
        }
    }
}

public extension TelerouteRouterGroup {
    /// Registers a typed command that implements its own handler.
    func command<Command: TelerouteHandlingCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = [],
        queue: TelerouteQueueScope? = nil
    ) {
        self.onCommand(
            commandType,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue
        ) { command, context in
            try await command.handle(context: context.coreContext)
        }
    }

    /// Registers a typed callback that implements its own handler.
    @discardableResult
    func callback<Callback: TelerouteHandlingCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware] = []
    ) -> TelerouteCallbackRoute<Callback> {
        self.onCallback(
            callbackType,
            guards: guards,
            middlewares: middlewares
        ) { callback, context in
            try await callback.handle(context: context.coreContext)
        }
    }
}

/// Bot-independent route graph configured before constructing a
/// ``TelerouteBot``.
public final class Teleroute<Context: TelerouteRequestContext>:
    TelerouteRouterGroup<Context>,
    @unchecked Sendable
{
    /// Creates a router with an explicit asynchronous context factory.
    public init(
        context _: Context.Type,
        contextFactory: @escaping @Sendable (TelerouteContextSource) async throws -> Context
    ) {
        let routes = TelerouteRoutes(storage: TelerouteStorage())
        super.init(
            routes: routes,
            baseContextExecutor: { coreContext, handler in
                let context = try await contextFactory(
                    .init(coreContext: coreContext)
                )
                return try await handler(context)
            }
        )
    }

    /// Creates a router for a context initialized from
    /// ``TelerouteContextSource``.
    public convenience init(context: Context.Type)
    where Context: TelerouteInitializableRequestContext {
        self.init(context: context) { source in
            try await Context(source: source)
        }
    }

    /// Creates a router using ``TelerouteContext`` as its handler context.
    public convenience init() where Context == TelerouteContext {
        self.init(context: TelerouteContext.self) { source in
            source.coreContext
        }
    }

    var storage: TelerouteStorage {
        self.routes.storage
    }
}
