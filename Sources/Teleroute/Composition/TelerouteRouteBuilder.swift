import Foundation
import SwiftTelegramBot

/// A declarative route-registration DSL.
///
/// Instead of imperative `router.command(...)` / `router.callback(...)` calls,
/// describe the route tree in one closure:
///
/// ```swift
/// router.routes {
///     Command("start", description: "Begin") { _, ctx in
///         try await ctx.reply(text: "Hi")
///     }
///     Group("admin", middlewares: [AccessLogMiddleware()]) {
///         Command("ban") { _, ctx in ... }
///         Callback("reset/{userId}") { _, ctx in ... }
///     }
///     Command(ProfileCommand.self)
/// }
/// ```
///
/// Group middleware and guards declared on a ``Group`` apply to every nested
/// route, mirroring ``TelerouteGroup/group(_:middlewares:routeGuards:configure:)``.
@resultBuilder
public enum TelerouteRouteBuilder {
    public static func buildBlock(_ components: [TelerouteRouteComponent]...) -> [TelerouteRouteComponent] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ component: TelerouteRouteComponent) -> [TelerouteRouteComponent] {
        [component]
    }

    public static func buildOptional(_ component: [TelerouteRouteComponent]?) -> [TelerouteRouteComponent] {
        component ?? []
    }

    public static func buildEither(first: [TelerouteRouteComponent]) -> [TelerouteRouteComponent] {
        first
    }

    public static func buildEither(second: [TelerouteRouteComponent]) -> [TelerouteRouteComponent] {
        second
    }

    public static func buildArray(_ components: [[TelerouteRouteComponent]]) -> [TelerouteRouteComponent] {
        components.flatMap { $0 }
    }
}

/// A buildable piece of the route tree.
public enum TelerouteRouteComponent: @unchecked Sendable {
    case command(TelerouteCommandSpec)
    case callback(TelerouteCallbackSpec)
    case group(TelerouteGroupSpec)
    case flow(any TelerouteFlow & Sendable)
    case collection(any TelerouteCollection)
}

/// Declarative command route specification used by ``TelerouteRouteBuilder``.
public struct TelerouteCommandSpec: Sendable {
    let path: String
    let botUsername: String?
    let description: String?
    let visibility: [TelerouteCommandVisibility]
    let routeGuard: (any TelerouteGuard)?
    let middlewares: [any TelerouteMiddleware]
    let queueing: TelerouteCommandQueueing?
    let handler: TelerouteHandler

    /// Creates a command route specification.
    public init(
        _ path: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        queueing: TelerouteCommandQueueing? = nil,
        use handler: @escaping TelerouteHandler
    ) {
        self.path = path
        self.botUsername = botUsername
        self.description = description
        self.visibility = visibility
        self.routeGuard = routeGuard
        self.middlewares = middlewares
        self.queueing = queueing
        self.handler = handler
    }

    /// Convenience for typed commands whose handler lives on the value itself.
    public init<Command: TelerouteCommand>(
        _ commandType: Command.Type
    ) {
        self.path = Command.path
        self.botUsername = Command.botUsername
        self.description = Command.commandDescription
        self.visibility = Command.visibility
        self.routeGuard = nil
        self.middlewares = []
        self.queueing = Command.queueing
        self.handler = { update, context in
            let command = try Command(
                command: context.command
                    ?? TelerouteCommandMatch(
                        name: Command.path,
                        rawValue: "/\(Command.path)",
                        mentionedBotUsername: nil,
                        argumentsText: nil,
                        arguments: []
                    )
            )
            try await command.handle(update: update, context: context)
        }
    }
}

/// Declarative callback route specification used by ``TelerouteRouteBuilder``.
public struct TelerouteCallbackSpec: Sendable {
    let path: String
    let routeGuard: (any TelerouteGuard)?
    let middlewares: [any TelerouteMiddleware]
    let handler: TelerouteHandler

    /// Creates a callback route specification.
    public init(
        _ path: String,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping TelerouteHandler
    ) {
        self.path = path
        self.routeGuard = routeGuard
        self.middlewares = middlewares
        self.handler = handler
    }
}

/// Declarative nested group used by ``TelerouteRouteBuilder``.
public struct TelerouteGroupSpec: Sendable {
    let path: String
    let middlewares: [any TelerouteMiddleware]
    let routeGuards: [any TelerouteGuard]
    let components: [TelerouteRouteComponent]

    /// Creates a nested group. Its middleware and guards apply to every child.
    public init(
        _ path: String,
        middlewares: [any TelerouteMiddleware] = [],
        routeGuards: [any TelerouteGuard] = [],
        @TelerouteRouteBuilder _ content: () -> [TelerouteRouteComponent]
    ) {
        self.path = path
        self.middlewares = middlewares
        self.routeGuards = routeGuards
        self.components = content()
    }
}

/// Lightweight wrappers letting the builder accept command/callback specs directly.
public extension TelerouteRouteBuilder {
    static func buildExpression(_ spec: TelerouteCommandSpec) -> [TelerouteRouteComponent] {
        [.command(spec)]
    }

    static func buildExpression(_ spec: TelerouteCallbackSpec) -> [TelerouteRouteComponent] {
        [.callback(spec)]
    }

    static func buildExpression(_ spec: TelerouteGroupSpec) -> [TelerouteRouteComponent] {
        [.group(spec)]
    }
}

/// Convenience aliases for use inside ``TelerouteRouteBuilder`` closures.
/// Preferred over the long-form `TelerouteCommandSpec` / `TelerouteCallbackSpec`
/// / `TelerouteGroupSpec` names within `router.routes { ... }`.
public typealias TelerouteRouteCommand = TelerouteCommandSpec
public typealias TelerouteRouteCallback = TelerouteCallbackSpec
public typealias TelerouteRouteGroup = TelerouteGroupSpec

public extension Teleroute {
    /// Registers routes declared with the ``TelerouteRouteBuilder`` DSL.
    func routes(@TelerouteRouteBuilder _ content: () -> [TelerouteRouteComponent]) {
        Self.apply(content(), to: self.rootGroup)
    }

    /// Registers routes declared with the DSL against the supplied group.
    static func apply(_ components: [TelerouteRouteComponent], to group: TelerouteGroup) {
        for component in components {
            switch component {
            case let .command(spec):
                group.command(
                    spec.path,
                    botUsername: spec.botUsername,
                    description: spec.description,
                    visibility: spec.visibility,
                    routeGuard: spec.routeGuard,
                    middlewares: spec.middlewares,
                    queueing: spec.queueing,
                    use: spec.handler
                )
            case let .callback(spec):
                group.callback(
                    spec.path,
                    routeGuard: spec.routeGuard,
                    middlewares: spec.middlewares,
                    use: spec.handler
                )
            case let .group(spec):
                group.group(
                    spec.path,
                    middlewares: spec.middlewares,
                    routeGuards: spec.routeGuards
                ) { nested in
                    Self.apply(spec.components, to: nested)
                }
            case let .flow(flow):
                group.add(flow: flow)
            case let .collection(collection):
                group.add(collection: collection)
            }
        }
    }
}
