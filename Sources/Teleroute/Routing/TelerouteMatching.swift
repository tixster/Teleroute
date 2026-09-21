import Foundation
import OrderedCollections
import Synchronization

final class TelerouteStorage: Sendable {
    private struct State: Sendable {
        var routeGraph = TelerouteRouteGraph()
        var publishedCommands: [TeleroutePublishedCommand] = []
        var registeredCallbackPaths: Set<String> = []
        var routeSignatures: OrderedSet<TelerouteRouteSignature> = []
        var hasInlineActionRoute = false
        var duplicateRouteSignatures: OrderedSet<TelerouteRouteSignature> = []
        var unreachableFlowSteps: OrderedSet<TelerouteFlowStepKey> = []
    }

    private let state = Mutex(State())
    let identity = UUID()
    let commandQueue = TelerouteCommandQueue()
    let flowQueue = TelerouteCommandQueue()

    var routeGraph: TelerouteRouteGraph {
        self.state.withLock { $0.routeGraph }
    }

    var publishedCommands: [TeleroutePublishedCommand] {
        self.state.withLock { $0.publishedCommands }
    }

    var duplicateRouteSignatures: [TelerouteRouteSignature] {
        self.state.withLock { Array($0.duplicateRouteSignatures) }
    }

    var unreachableFlowSteps: [TelerouteFlowStepKey] {
        self.state.withLock { Array($0.unreachableFlowSteps) }
    }

    /// Records a step that asked to advance but has no step after it.
    func recordFlowStepWithoutSuccessor(flowID: String, step: String) {
        self.state.withLock {
            _ = $0.unreachableFlowSteps.append(.init(flowID: flowID, step: step))
        }
    }

    func appendCommandRoute(
        _ route: TelerouteCommandRoute,
        signature: TelerouteRouteSignature?
    ) {
        self.state.withLock {
            Self.register(signature, in: &$0)
            $0.routeGraph.appendCommand(route)
        }
    }

    func appendCallbackRoute(
        _ route: TelerouteCallbackHandlerRoute,
        signature: TelerouteRouteSignature?
    ) {
        self.state.withLock {
            Self.register(signature, in: &$0)
            $0.registeredCallbackPaths.insert(route.pattern.routeDescription)
            $0.routeGraph.appendCallback(route)
        }
    }

    func appendFlowRoute(
        _ route: TelerouteFlowRoute,
        signature: TelerouteRouteSignature?
    ) {
        self.state.withLock {
            Self.register(signature, in: &$0)
            if case let .callback(pattern) = route.matcher {
                $0.registeredCallbackPaths.insert(pattern.routeDescription)
            }
            $0.routeGraph.appendFlow(route)
        }
    }

    func registerFlow(id: String) {
        self.state.withLock {
            $0.routeGraph.hasMountedFlows = true
            // Mounting the same flow twice must not drop hooks the first mount
            // registered, so this only creates the entry when it is missing.
            if $0.routeGraph.flowHooks[id] == nil {
                $0.routeGraph.flowHooks[id] = .init()
            }
        }
    }

    func setFlowHooks(id: String, _ mutate: (inout TelerouteFlowHooks) -> Void) {
        self.state.withLock {
            var hooks = $0.routeGraph.flowHooks[id] ?? .init()
            mutate(&hooks)
            $0.routeGraph.flowHooks[id] = hooks
        }
    }

    func appendMessageRoute(_ route: TelerouteMessageRoute) {
        self.state.withLock {
            $0.routeGraph.appendMessage(route)
        }
    }

    func appendKindRoute(_ route: TelerouteUpdateKindRoute) {
        self.state.withLock {
            $0.routeGraph.appendKind(route)
        }
    }

    func appendUnmatchedRoute(_ route: TelerouteUnmatchedRoute) {
        self.state.withLock {
            $0.routeGraph.appendUnmatched(route)
        }
    }

    /// Claims the right to mount the inline-action route, returning `false`
    /// when it is already mounted — two bots may share one router.
    func claimInlineActionRoute() -> Bool {
        self.state.withLock { state in
            guard state.hasInlineActionRoute == false else { return false }
            state.hasInlineActionRoute = true
            return true
        }
    }

    func containsCallbackRoute(_ path: String) -> Bool {
        self.state.withLock { $0.registeredCallbackPaths.contains(path) }
    }

    /// Finds registered callback routes whose full path ends in `description`.
    ///
    /// A callback value only knows its own type's path (`orders/{id}/delete`);
    /// the route it was registered on may carry a group prefix
    /// (`admin/orders/{id}/delete`). This resolves the second from the first
    /// so a button built from a bare value works from any rendering scope.
    /// The result is sorted so an ambiguity reports the same way every time.
    func resolveCallbackRoutes(matching description: String) -> [String] {
        let suffix = "/" + description
        return self.state.withLock { state in
            state.registeredCallbackPaths
                .filter { $0 == description || $0.hasSuffix(suffix) }
                .sorted()
        }
    }

    func appendPublishedCommand(_ command: TeleroutePublishedCommand) {
        self.state.withLock {
            $0.publishedCommands.append(command)
        }
    }

    private static func register(
        _ signature: TelerouteRouteSignature?,
        in state: inout State
    ) {
        guard let signature else { return }
        let result = state.routeSignatures.append(signature)
        if result.inserted == false {
            state.duplicateRouteSignatures.append(signature)
        }
    }
}

/// Route identity used for duplicate-registration diagnostics.
public struct TelerouteRouteSignature: Hashable, Sendable {
    public enum Kind: Hashable, Sendable {
        case command
        case callback
        case flowMessage
        case flowCommand
        case flowCallback
    }

    /// Route category.
    public let kind: Kind
    /// Normalized command name or callback path.
    public let name: String
    /// Optional bot username restriction for command routes.
    public let botUsername: String?
    /// Flow identifier for flow-local routes.
    public let flowID: String?
    /// Flow step for flow-local routes.
    public let step: String?

    /// Creates a route signature value for comparison in diagnostics or tests.
    public init(
        kind: Kind,
        name: String,
        botUsername: String? = nil,
        flowID: String? = nil,
        step: String? = nil
    ) {
        self.kind = kind
        self.name = name
        self.botUsername = botUsername
        self.flowID = flowID
        self.step = step
    }
}

struct TelerouteCommandRoute: Sendable {
    let name: String
    let botUsername: String?
    let middlewares: [any TelerouteMiddleware<TelerouteContext>]
    let executor: TelerouteRouteExecutor

    init(
        name: String,
        botUsername: String?,
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteHandler
    ) {
        self.name = name
        self.botUsername = botUsername
        self.middlewares = middlewares
        self.executor = .init(middlewares: middlewares, handler: handler)
    }
}

struct TelerouteCallbackHandlerRoute: Sendable {
    let pattern: TelerouteCallbackPattern
    let middlewares: [any TelerouteMiddleware<TelerouteContext>]
    let executor: TelerouteRouteExecutor

    init(
        pattern: TelerouteCallbackPattern,
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteHandler
    ) {
        self.pattern = pattern
        self.middlewares = middlewares
        self.executor = .init(middlewares: middlewares, handler: handler)
    }
}

enum TelerouteFlowRouteMatcher: Sendable {
    case message
    case command(name: String, botUsername: String?)
    case callback(TelerouteCallbackPattern)
}

struct TelerouteFlowRoute: Sendable {
    let flowID: String
    let step: String
    let matcher: TelerouteFlowRouteMatcher
    let middlewares: [any TelerouteMiddleware<TelerouteContext>]
    let executor: TelerouteRouteExecutor

    init(
        flowID: String,
        step: String,
        matcher: TelerouteFlowRouteMatcher,
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteHandler
    ) {
        self.flowID = flowID
        self.step = step
        self.matcher = matcher
        self.middlewares = middlewares
        self.executor = .init(middlewares: middlewares, handler: handler)
    }
}

/// Identifies one step of one flow.
public struct TelerouteFlowStepKey: Hashable, Sendable {
    public let flowID: String
    public let step: String

    public init(flowID: String, step: String) {
        self.flowID = flowID
        self.step = step
    }
}

struct TelerouteCallbackRouteIndex<Route: Sendable>: Sendable {
    struct Entry: Sendable {
        let sequence: Int
        let pattern: TelerouteCallbackPattern
        let route: Route
    }

    private struct Bucket: Sendable {
        var literalFirst: [String: [Entry]] = [:]
        var wildcardFirst: [Entry] = []
    }

    private var buckets: [Int: Bucket] = [:]
    private var nextSequence = 0

    mutating func append(pattern: TelerouteCallbackPattern, route: Route) {
        let entry = Entry(sequence: self.nextSequence, pattern: pattern, route: route)
        self.nextSequence += 1

        var bucket = self.buckets[pattern.segmentCount, default: .init()]
        if let firstLiteral = pattern.firstLiteral {
            bucket.literalFirst[firstLiteral, default: []].append(entry)
        } else {
            bucket.wildcardFirst.append(entry)
        }
        self.buckets[pattern.segmentCount] = bucket
    }

    func candidates(for components: [String]) -> [Entry] {
        guard let bucket = self.buckets[components.count] else { return [] }
        guard let first = components.first else { return bucket.wildcardFirst }

        let literal = bucket.literalFirst[first] ?? []
        let wildcard = bucket.wildcardFirst
        guard literal.isEmpty == false else { return wildcard }
        guard wildcard.isEmpty == false else { return literal }

        var merged: [Entry] = []
        merged.reserveCapacity(literal.count + wildcard.count)
        var literalIndex = literal.startIndex
        var wildcardIndex = wildcard.startIndex

        while literalIndex < literal.endIndex, wildcardIndex < wildcard.endIndex {
            if literal[literalIndex].sequence < wildcard[wildcardIndex].sequence {
                merged.append(literal[literalIndex])
                literal.formIndex(after: &literalIndex)
            } else {
                merged.append(wildcard[wildcardIndex])
                wildcard.formIndex(after: &wildcardIndex)
            }
        }
        merged.append(contentsOf: literal[literalIndex...])
        merged.append(contentsOf: wildcard[wildcardIndex...])
        return merged
    }
}

struct TelerouteFlowStepRoutes: Sendable {
    var messages: [TelerouteFlowRoute] = []
    var commandsByName: [String: [TelerouteFlowRoute]] = [:]
    var callbacks = TelerouteCallbackRouteIndex<TelerouteFlowRoute>()

    mutating func append(_ route: TelerouteFlowRoute) {
        switch route.matcher {
        case .message:
            self.messages.append(route)
        case let .command(name, _):
            self.commandsByName[name, default: []].append(route)
        case let .callback(pattern):
            self.callbacks.append(pattern: pattern, route: route)
        }
    }
}

struct TelerouteMessageRoute: Sendable {
    let name: String
    let sources: Set<TelerouteMessageSource>
    let filter: TelerouteMessageFilter
    let executor: TelerouteRouteExecutor

    init(
        name: String,
        sources: Set<TelerouteMessageSource>,
        filter: TelerouteMessageFilter,
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteHandler
    ) {
        self.name = name
        self.sources = sources
        self.filter = filter
        self.executor = .init(middlewares: middlewares, handler: handler)
    }
}

struct TelerouteUpdateKindRoute: Sendable {
    let name: String
    let kinds: Set<UpdateKind>
    let executor: TelerouteRouteExecutor

    init(
        name: String,
        kinds: Set<UpdateKind>,
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteHandler
    ) {
        self.name = name
        self.kinds = kinds
        self.executor = .init(middlewares: middlewares, handler: handler)
    }
}

struct TelerouteUnmatchedRoute: Sendable {
    let executor: TelerouteRouteExecutor

    init(
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        handler: @escaping TelerouteHandler
    ) {
        self.executor = .init(middlewares: middlewares, handler: handler)
    }
}

struct TelerouteRouteGraph: Sendable {
    var commandsByName: [String: [TelerouteCommandRoute]] = [:]
    var callbacks = TelerouteCallbackRouteIndex<TelerouteCallbackHandlerRoute>()
    var flowSteps: [TelerouteFlowStepKey: TelerouteFlowStepRoutes] = [:]
    /// Lifecycle closures registered by a flow's `boot`, keyed by flow id.
    var flowHooks: [String: TelerouteFlowHooks] = [:]
    var hasMountedFlows = false
    var messageRoutes: [TelerouteMessageRoute] = []
    var kindRoutes: [TelerouteUpdateKindRoute] = []
    var unmatchedRoutes: [TelerouteUnmatchedRoute] = []
    /// Update kinds explicitly routable via `on(_:)`/typed sugar.
    var registeredKinds: Set<UpdateKind> = []
    /// Message sources reachable through message routes.
    var registeredMessageSources: Set<TelerouteMessageSource> = []
    var hasCommandRoutes = false
    var hasCallbackRoutes = false

    mutating func appendCommand(_ route: TelerouteCommandRoute) {
        self.commandsByName[route.name, default: []].append(route)
        self.hasCommandRoutes = true
    }

    mutating func appendCallback(_ route: TelerouteCallbackHandlerRoute) {
        self.callbacks.append(pattern: route.pattern, route: route)
        self.hasCallbackRoutes = true
    }

    mutating func appendFlow(_ route: TelerouteFlowRoute) {
        self.hasMountedFlows = true
        let key = TelerouteFlowStepKey(flowID: route.flowID, step: route.step)
        var routes = self.flowSteps[key, default: .init()]
        routes.append(route)
        self.flowSteps[key] = routes
    }

    mutating func appendMessage(_ route: TelerouteMessageRoute) {
        self.messageRoutes.append(route)
        self.registeredMessageSources.formUnion(route.sources)
    }

    mutating func appendKind(_ route: TelerouteUpdateKindRoute) {
        self.kindRoutes.append(route)
        self.registeredKinds.formUnion(route.kinds)
    }

    mutating func appendUnmatched(_ route: TelerouteUnmatchedRoute) {
        self.unmatchedRoutes.append(route)
    }
}

enum TeleroutePath: Sendable {
    static func components(from path: String) -> [String] {
        path
            .split(separator: "/")
            .map(String.init)
            .filter { !$0.isEmpty }
    }

    static func commandName(prefix: [String], path: String) -> String {
        (prefix + self.components(from: path)).joined(separator: "_")
    }
}

struct TelerouteCallbackPattern: Sendable {
    enum Segment: Sendable {
        case literal(String)
        case parameter(String)
    }

    let segments: [Segment]

    var segmentCount: Int {
        self.segments.count
    }

    var firstLiteral: String? {
        guard case let .some(.literal(value)) = self.segments.first else { return nil }
        return value
    }

    var routeDescription: String {
        self.segments.map { segment in
            switch segment {
            case let .literal(value):
                value
            case let .parameter(name):
                "{\(name)}"
            }
        }
        .joined(separator: "/")
    }

    init(prefix: [String], path: String) {
        self.segments = (prefix + TeleroutePath.components(from: path)).map { component in
            if component.hasPrefix("{"), component.hasSuffix("}"), component.count > 2 {
                return .parameter(String(component.dropFirst().dropLast()))
            }
            return .literal(component)
        }
    }

    func match(_ value: String) -> TelerouteParameters? {
        self.match(components: TeleroutePath.components(from: value))
    }

    func match(components: [String]) -> TelerouteParameters? {
        guard components.count == self.segments.count else {
            return nil
        }

        var parameters: [String: String] = [:]

        for (segment, component) in zip(self.segments, components) {
            switch segment {
            case let .literal(expected):
                guard expected == component else {
                    return nil
                }
            case let .parameter(name):
                parameters[name] = component.removingPercentEncoding ?? component
            }
        }

        return .init(parameters)
    }

    /// Telegram accepts `callback_data` of 1-64 bytes; longer values are
    /// rejected by the API with a 400 at send time, so they are caught here
    /// instead, where the failure names the route that produced them.
    static let maximumCallbackDataBytes = 64

    func render(parameters: [String: String]) throws -> String {
        let data = try self.segments.map { segment in
            switch segment {
            case let .literal(value):
                return value
            case let .parameter(name):
                guard let value = parameters[name] else {
                    throw TelerouteError.missingParameter(name)
                }
                return TeleroutePercentEncoding.encodePathSegment(value)
            }
        }
        .joined(separator: "/")

        let bytes = data.utf8.count
        guard bytes <= Self.maximumCallbackDataBytes else {
            throw TelerouteError.callbackDataTooLong(data, bytes: bytes)
        }
        return data
    }
}

enum TeleroutePercentEncoding: Sendable {
    static func encodePathSegment(_ value: String) -> String {
        var allowed = CharacterSet.urlPathAllowed
        allowed.remove(charactersIn: "/")
        return value.addingPercentEncoding(withAllowedCharacters: allowed) ?? value
    }
}

enum TelerouteCommandExtractor: Sendable {
    static func extract(from update: Update) -> TelerouteCommandMatch? {
        guard let text = self.commandText(from: update)?.trimmingCharacters(in: .whitespacesAndNewlines),
              text.hasPrefix("/") else {
            return nil
        }

        let parts = text.split(maxSplits: 1, whereSeparator: \.isWhitespace)
        guard let commandToken = parts.first else {
            return nil
        }

        let rawValue = String(commandToken)
        let nameAndUsername = rawValue.dropFirst().split(separator: "@", maxSplits: 1).map(String.init)
        guard let name = nameAndUsername.first, !name.isEmpty else {
            return nil
        }

        let argumentsText = parts.count > 1 ? String(parts[1]).trimmingCharacters(in: .whitespacesAndNewlines) : nil

        return TelerouteCommandMatch(
            name: name,
            rawValue: rawValue,
            mentionedBotUsername: nameAndUsername.count > 1 ? nameAndUsername[1] : nil,
            argumentsText: argumentsText?.isEmpty == true ? nil : argumentsText,
            arguments: argumentsText?
                .split(whereSeparator: \.isWhitespace)
                .map(String.init) ?? []
        )
    }

    private static func commandText(from update: Update) -> String? {
        if let text = update.message?.text { return text }
        if let text = update.editedMessage?.text { return text }
        if let text = update.channelPost?.text { return text }
        if let text = update.editedChannelPost?.text { return text }
        if let text = update.businessMessage?.text { return text }
        if let text = update.editedBusinessMessage?.text { return text }
        return nil
    }
}

enum TelerouteCommandMatcher: Sendable {
    static func matches(
        _ command: TelerouteCommandMatch,
        routeName: String,
        botUsername: String?
    ) -> Bool {
        guard routeName == command.name else { return false }
        guard let botUsername else { return true }
        guard let mentionedBotUsername = command.mentionedBotUsername else { return false }
        return self.normalizedBotUsername(botUsername) == self.normalizedBotUsername(mentionedBotUsername)
    }

    private static func normalizedBotUsername(_ username: String) -> String {
        let username = username.hasPrefix("@")
            ? String(username.dropFirst())
            : username
        return username.lowercased()
    }
}

enum TelerouteMessageExtractor: Sendable {
    static func extract(from update: Update) -> Message? {
        if let message = update.message { return message }
        if let message = update.editedMessage { return message }
        if let message = update.channelPost { return message }
        if let message = update.editedChannelPost { return message }
        if let message = update.businessMessage { return message }
        if let message = update.editedBusinessMessage { return message }
        return nil
    }
}
