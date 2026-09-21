import Foundation
import TelegramBotAPI

// MARK: - Rendering keyboards from inside a handler

public extension TelerouteRequestContext {
    /// Renders a keyboard described with the result-builder DSL, validating
    /// typed callbacks against the router that is serving this update:
    ///
    /// ```swift
    /// router.command("orders") { context in
    ///     try await context.reply(
    ///         "Your orders:",
    ///         replyMarkup: .inline(context.keyboard {
    ///             Row { page.button(OrderPage(id: "7", page: 1), "Next") }
    ///         })
    ///     )
    /// }
    /// ```
    ///
    /// Prefer the deferred form — `Reply("…").keyboard { … }` — when the
    /// handler returns a response instead of sending it itself.
    ///
    /// This is also what a flow step gets, since ``TelerouteFlowContext``
    /// is a request context. Inside a flow, a button made from a route handle
    /// (`route.button(_:_:)`) carries its full pattern and renders correctly,
    /// while a button made from a bare callback value (`callback.button(_:)`)
    /// resolves against the router root rather than the flow's prefix — use
    /// ``TelerouteFlowGroup/keyboard(_:)`` for those.
    ///
    /// - Throws: ``TelerouteError/keyboardScopeMissing`` when the context was
    ///   built directly rather than by a running router.
    func keyboard(
        @TelerouteKeyboardBuilder _ content: () -> [[TelerouteButton]]
    ) throws -> InlineKeyboardMarkup {
        try self.keyboard(content())
    }

    /// Renders callback button descriptions into Telegram keyboard rows.
    func keyboard(_ rows: [[TelerouteButton]]) throws -> InlineKeyboardMarkup {
        try self.requireRouteScope().keyboard(rows, in: self.coreContext.renderContext)
    }

    /// Renders one typed button description in the serving router's scope.
    func render(_ button: TelerouteButton) throws -> InlineKeyboardButton {
        try self.requireRouteScope().render(button, in: self.coreContext.renderContext)
    }

    /// Generates callback data for a typed callback value.
    func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.requireRouteScope().callbackData(for: callback)
    }

    private func requireRouteScope() throws -> TelerouteRoutes {
        guard let routeScope = self.coreContext.routeScope else {
            throw TelerouteError.keyboardScopeMissing
        }
        return routeScope
    }
}
