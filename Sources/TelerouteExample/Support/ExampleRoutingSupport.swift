import Teleroute

/// Route guard restricting handlers to a specific Telegram chat type.
///
/// The example uses this for routes that should behave only in private chats,
/// such as `/start`, `/profile`, and user-facing callbacks.
struct ChatTypeGuard: TelerouteGuard {
    let expected: TGChatType

    init(_ expected: TGChatType) {
        self.expected = expected
    }

    func matches(_ context: TelerouteContext) async throws -> Bool {
        context.message?.chat.type == self.expected
    }
}

/// Middleware that logs handler entry and exit around a matched route.
///
/// This is intentionally simple: it demonstrates how middleware composes around
/// commands and callbacks without altering the request context.
struct AccessLogMiddleware: TelerouteMiddleware {
    let label: String

    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        let logger = ExampleLoggerFactory.makeMiddlewareLogger(label: self.label)
        logger.info(
            "before route, chat=\(context.chatId.map(String.init) ?? "none"), user=\(context.userId.map(String.init) ?? "none")"
        )
        try await next(context)
        logger.info("after route")
    }
}
