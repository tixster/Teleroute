import Foundation
import OrderedCollections
import Synchronization

final class TelerouteStorage: Sendable {
    private struct State: Sendable {
        var commandRoutes: [TelerouteCommandRoute] = []
        var callbackRoutes: [TelerouteCallbackRoute] = []
        var flowRoutes: [TelerouteFlowRoute] = []
        var publishedCommands: [TeleroutePublishedCommand] = []
        var routeSignatures: OrderedSet<TelerouteRouteSignature> = []
        var duplicateRouteSignatures: OrderedSet<TelerouteRouteSignature> = []
    }

    private let state = Mutex(State())
    let commandQueue = TelerouteCommandQueue()
    let flowQueue = TelerouteCommandQueue()

    var commandRoutes: [TelerouteCommandRoute] {
        self.state.withLock { $0.commandRoutes }
    }

    var callbackRoutes: [TelerouteCallbackRoute] {
        self.state.withLock { $0.callbackRoutes }
    }

    var flowRoutes: [TelerouteFlowRoute] {
        self.state.withLock { $0.flowRoutes }
    }

    var publishedCommands: [TeleroutePublishedCommand] {
        self.state.withLock { $0.publishedCommands }
    }

    var duplicateRouteSignatures: [TelerouteRouteSignature] {
        self.state.withLock { Array($0.duplicateRouteSignatures) }
    }

    func appendCommandRoute(
        _ route: TelerouteCommandRoute,
        signature: TelerouteRouteSignature?
    ) {
        self.state.withLock {
            Self.register(signature, in: &$0)
            $0.commandRoutes.append(route)
        }
    }

    func appendCallbackRoute(
        _ route: TelerouteCallbackRoute,
        signature: TelerouteRouteSignature?
    ) {
        self.state.withLock {
            Self.register(signature, in: &$0)
            $0.callbackRoutes.append(route)
        }
    }

    func appendFlowRoute(
        _ route: TelerouteFlowRoute,
        signature: TelerouteRouteSignature?
    ) {
        self.state.withLock {
            Self.register(signature, in: &$0)
            $0.flowRoutes.append(route)
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
    let middlewares: [any TelerouteMiddleware]
    let handler: TelerouteHandler
}

struct TelerouteCallbackRoute: Sendable {
    let pattern: TelerouteCallbackPattern
    let middlewares: [any TelerouteMiddleware]
    let handler: TelerouteHandler
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
    let middlewares: [any TelerouteMiddleware]
    let handler: TelerouteHandler
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
        let components = TeleroutePath.components(from: value)
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

    func render(parameters: [String: String]) throws -> String {
        try self.segments.map { segment in
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
    static func extract(from update: TGUpdate) -> TelerouteCommandMatch? {
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

    private static func commandText(from update: TGUpdate) -> String? {
        if let text = update.message?.text { return text }
        if let text = update.editedMessage?.text { return text }
        if let text = update.channelPost?.text { return text }
        if let text = update.editedChannelPost?.text { return text }
        if let text = update.businessMessage?.text { return text }
        if let text = update.editedBusinessMessage?.text { return text }
        return nil
    }
}

enum TelerouteMessageExtractor: Sendable {
    static func extract(from update: TGUpdate) -> TGMessage? {
        if let message = update.message { return message }
        if let message = update.editedMessage { return message }
        if let message = update.channelPost { return message }
        if let message = update.editedChannelPost { return message }
        if let message = update.businessMessage { return message }
        if let message = update.editedBusinessMessage { return message }
        return nil
    }
}
