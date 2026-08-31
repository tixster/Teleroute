import Foundation
import Synchronization

private final class TelerouteCoreMiddlewareStorage: Sendable {
    private let valuesStorage = Mutex<[any TelerouteMiddleware<TelerouteContext>]>([])

    var values: [any TelerouteMiddleware<TelerouteContext>] {
        self.valuesStorage.withLock { $0 }
    }

    func append(_ middleware: any TelerouteMiddleware<TelerouteContext>) {
        self.valuesStorage.withLock { $0.append(middleware) }
    }
}

private final class TelerouteTypedMiddlewareStorage<Context: TelerouteRequestContext>: Sendable {
    private let valuesStorage = Mutex<[any TelerouteMiddleware<Context>]>([])

    var values: [any TelerouteMiddleware<Context>] {
        self.valuesStorage.withLock { $0 }
    }

    func append(_ middleware: any TelerouteMiddleware<Context>) {
        self.valuesStorage.withLock { $0.append(middleware) }
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
/// registered: **add middleware before registering the routes that should use
/// it** — later additions do not apply retroactively.
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

    /// Adds middleware for this scope's context.
    public func add<Middleware: TelerouteMiddleware>(_ middleware: Middleware)
    where Middleware.Context == Context {
        self.typedStorage.append(middleware)
    }

    /// Adds low-level middleware operating on ``TelerouteContext``. It runs
    /// in the route's core chain (also wrapping flows mounted in this scope).
    public func add(core middleware: any TelerouteMiddleware<TelerouteContext>) {
        self.coreStorage.append(middleware)
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
    TelerouteMiddleware
{
    let executor: TelerouteContextExecutor<Context>

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        try await self.executor(context) { typedContext in
            try await next(typedContext.coreContext)
        }
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
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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

    // MARK: - Commands

    /// Registers a command. The handler returns any
    /// ``TelerouteResponseGenerator`` — a `String` reply, a chainable action
    /// such as ``Reply``, a full ``TelerouteResponse``, or `.unhandled` to
    /// fall through to the next candidate route.
    public func command<Response: TelerouteResponseGenerator>(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (Context) async throws -> Response
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
            try await handler(context).makeResponse()
        }
    }

    /// Registers a command whose handler returns a ``TelerouteResponse``.
    /// (Disambiguating overload so `.reply(...)`-style member syntax infers.)
    public func command(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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

    /// Registers a command with a side-effect-only handler.
    public func command(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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

    /// Registers a typed command.
    public func command<Command: TelerouteCommand, Response: TelerouteResponseGenerator>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        queue: TelerouteQueueScope? = nil,
        use handler: @escaping @Sendable (Command, Context) async throws -> Response
    ) {
        self.registerTypedCommand(
            commandType,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue
        ) { command, context in
            try await handler(command, context).makeResponse()
        }
    }

    /// Registers a typed command whose handler returns a ``TelerouteResponse``.
    public func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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

    /// Registers a typed command with a side-effect-only handler.
    public func command<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility]? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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

    // MARK: - Callbacks

    /// Registers a callback route using a path-style pattern.
    public func callback<Response: TelerouteResponseGenerator>(
        _ path: String,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Response
    ) {
        self.registerCallback(
            path,
            guards: guards,
            middlewares: middlewares
        ) { context in
            try await handler(context).makeResponse()
        }
    }

    /// Registers a callback route whose handler returns a ``TelerouteResponse``.
    public func callback(
        _ path: String,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) {
        self.registerCallback(
            path,
            guards: guards,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Registers a callback route with a side-effect-only handler.
    public func callback(
        _ path: String,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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

    /// Registers a typed callback and returns its scope-bound route handle.
    @discardableResult
    public func callback<Callback: TelerouteCallback, Response: TelerouteResponseGenerator>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Callback, Context) async throws -> Response
    ) -> TelerouteCallbackRoute<Callback> {
        self.registerTypedCallback(
            callbackType,
            guards: guards,
            middlewares: middlewares
        ) { callback, context in
            try await handler(callback, context).makeResponse()
        }
    }

    /// Registers a typed callback whose handler returns a ``TelerouteResponse``.
    @discardableResult
    public func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Callback, Context) async throws -> TelerouteResponse
    ) -> TelerouteCallbackRoute<Callback> {
        self.registerTypedCallback(
            callbackType,
            guards: guards,
            middlewares: middlewares,
            handler: handler
        )
    }

    /// Registers a typed callback with a side-effect-only handler.
    @discardableResult
    public func callback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
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
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
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
            try await contextExecutor(coreContext, handler)
        }
    }

    private func registerCallback(
        _ path: String,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteContextHandler<Context>
    ) {
        let contextExecutor = self.makeContextExecutor()
        self.routes.callback(
            path,
            guards: self.guardStorage.values + guards,
            middlewares: self.coreMiddlewareStorage.values + middlewares
        ) { coreContext in
            try await contextExecutor(coreContext, handler)
        }
    }

    private func registerTypedCommand<Command: TelerouteCommand>(
        _ commandType: Command.Type,
        description: String?,
        visibility: [TelerouteCommandVisibility]?,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
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
            try await contextExecutor(coreContext) { context in
                try await handler(command, context)
            }
        }
    }

    private func registerTypedCallback<Callback: TelerouteCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping @Sendable (Callback, Context) async throws -> TelerouteResponse
    ) -> TelerouteCallbackRoute<Callback> {
        let contextExecutor = self.makeContextExecutor()
        return self.routes.callback(
            callbackType,
            guards: self.guardStorage.values + guards,
            middlewares: self.coreMiddlewareStorage.values + middlewares
        ) { callback, coreContext in
            try await contextExecutor(coreContext) { context in
                try await handler(callback, context)
            }
        }
    }

    func registerMessage(
        filter: TelerouteMessageFilter,
        sources: Set<TelerouteMessageSource>,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteContextHandler<Context>
    ) {
        let contextExecutor = self.makeContextExecutor()
        self.routes.message(
            from: sources,
            filter: filter,
            guards: self.guardStorage.values + guards,
            middlewares: self.coreMiddlewareStorage.values + middlewares
        ) { coreContext in
            try await contextExecutor(coreContext, handler)
        }
    }

    func registerKinds(
        _ kinds: Set<UpdateKind>,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteContextHandler<Context>
    ) {
        let contextExecutor = self.makeContextExecutor()
        self.routes.on(
            kinds,
            guards: self.guardStorage.values + guards,
            middlewares: self.coreMiddlewareStorage.values + middlewares
        ) { coreContext in
            try await contextExecutor(coreContext, handler)
        }
    }

    func registerUnmatched(
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteContextHandler<Context>
    ) {
        let contextExecutor = self.makeContextExecutor()
        self.routes.unmatched(
            middlewares: self.coreMiddlewareStorage.values + middlewares
        ) { coreContext in
            try await contextExecutor(coreContext, handler)
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
                        try await middleware.handle(nextContext, next: downstream)
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
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        queue: TelerouteQueueScope? = nil
    ) where Command.Context == Context {
        self.registerTypedCommand(
            commandType,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue
        ) { command, context in
            try await command.handle(context: context).makeResponse()
        }
    }

    /// Registers a typed callback that implements its own handler.
    @discardableResult
    func callback<Callback: TelerouteHandlingCallback>(
        _ callbackType: Callback.Type,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = []
    ) -> TelerouteCallbackRoute<Callback> where Callback.Context == Context {
        self.registerTypedCallback(
            callbackType,
            guards: guards,
            middlewares: middlewares
        ) { callback, context in
            try await callback.handle(context: context).makeResponse()
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
