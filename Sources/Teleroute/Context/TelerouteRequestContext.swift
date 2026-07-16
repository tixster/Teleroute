import Foundation
import SwiftTelegramBot

/// Framework-owned input used to construct a custom request context.
public struct TelerouteContextSource: Sendable {
    /// The complete Telegram route context created for the matched update.
    public let coreContext: TelerouteContext

    public init(coreContext: TelerouteContext) {
        self.coreContext = coreContext
    }
}

/// A statically typed context delivered to handlers registered on a
/// ``Teleroute``.
///
/// Store lightweight request-scoped values here and keep shared services as
/// references. The framework context remains available through ``coreContext``.
public protocol TelerouteRequestContext: Sendable {
    /// Framework context containing the update, route parameters, bot, and
    /// Telegram convenience methods.
    var coreContext: TelerouteContext { get }
}

/// A request context that can be constructed directly from a matched update.
public protocol TelerouteInitializableRequestContext: TelerouteRequestContext {
    init(source: TelerouteContextSource) async throws
}

/// A context produced from a parent context for a nested route group.
///
/// Child contexts are useful for progressively refining guarantees, for
/// example turning an optional authenticated user into a required admin user.
public protocol TelerouteChildRequestContext<ParentContext>: TelerouteRequestContext {
    associatedtype ParentContext: TelerouteRequestContext

    init(context: ParentContext) async throws
}

public extension TelerouteRequestContext {
    /// Raw Telegram update currently being processed.
    var update: TGUpdate { self.coreContext.update }
    /// Bot associated with the running application.
    var bot: TGBot { self.coreContext.bot }
    /// Parameters extracted from a callback route.
    var parameters: TelerouteParameters { self.coreContext.parameters }
    /// Parsed command metadata, when this is a command route.
    var command: TelerouteCommandMatch? { self.coreContext.command }
    /// Current callback query, if any.
    var callbackQuery: TGCallbackQuery? { self.coreContext.callbackQuery }
    /// Raw callback data, if any.
    var callbackData: String? { self.coreContext.callbackData }
    /// Best-effort Telegram message resolved from the update.
    var message: TGMessage? { self.coreContext.message }
    /// Resolved chat identifier.
    var chatId: Int64? { self.coreContext.chatId }
    /// Resolved chat type.
    var chatType: TGChatType? { self.coreContext.chatType }
    /// Resolved Telegram user identifier.
    var userId: Int64? { self.coreContext.userId }
    /// Active flow session, if one exists.
    var activeFlow: TelerouteFlowSession? { self.coreContext.activeFlow }
    /// Flow key derived from the current update.
    var flowKey: TelerouteFlowKey? { self.coreContext.flowKey }

    /// Replies using the framework context.
    func reply(
        _ text: String,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws {
        try await self.coreContext.reply(
            text,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Sends a text message using the framework context.
    func send(
        _ text: String,
        to chatId: Int64? = nil,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws {
        try await self.coreContext.send(
            text,
            to: chatId,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Edits the message associated with this update.
    func edit(
        _ text: String,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGInlineKeyboardMarkup? = nil
    ) async throws {
        try await self.coreContext.edit(
            text,
            parseMode: parseMode,
            replyMarkup: replyMarkup
        )
    }

    /// Answers the callback query associated with this update.
    func answerCallbackQuery(
        _ text: String? = nil,
        showAlert: Bool? = nil,
        url: String? = nil,
        cacheTime: Int? = nil
    ) async throws {
        try await self.coreContext.answerCallbackQuery(
            text,
            showAlert: showAlert,
            url: url,
            cacheTime: cacheTime
        )
    }

    /// Starts or replaces a flow session.
    func start<Flow: TelerouteFlow>(
        _ flow: Flow.Type,
        at step: Flow.Step,
        values: [String: String] = [:]
    ) async throws {
        try await self.coreContext.start(flow, at: step, values: values)
    }

    /// Cancels the active flow session.
    func cancelFlow() async throws {
        try await self.coreContext.cancelFlow()
    }
}

extension TelerouteContext: TelerouteInitializableRequestContext {
    public var coreContext: TelerouteContext {
        self
    }

    public init(source: TelerouteContextSource) {
        self = source.coreContext
    }
}
