import Foundation
import SwiftTelegramBot

public extension TelerouteFlowGroup {
    /// Registers a typed callback handler for a specific flow step. The decoded
    /// callback value is passed to the handler.
    func callback<Callback: TelerouteCallback, StepValue>(
        _ callbackType: Callback.Type,
        at step: StepValue,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = [],
        use handler: @escaping @Sendable (_ update: TGUpdate, _ context: TelerouteFlowContext<Flow>, _ callback: Callback) async throws -> Void
    ) where StepValue == Flow.Step {
        self.callback(Callback.path, at: step, routeGuard: routeGuard, middlewares: middlewares) { update, context in
            let typed = try Callback(parameters: context.parameters)
            try await handler(update, context, typed)
        }
    }

    /// Registers a typed callback handler for a specific flow step. The callback
    /// value handles itself via its own ``TelerouteCallback/handle(update:context:)``.
    func callback<Callback: TelerouteCallback, StepValue>(
        _ callbackType: Callback.Type,
        at step: StepValue,
        routeGuard: (any TelerouteGuard)? = nil,
        middlewares: [any TelerouteMiddleware] = []
    ) where StepValue == Flow.Step {
        self.callback(Callback.path, at: step, routeGuard: routeGuard, middlewares: middlewares) { update, context in
            let typed = try Callback(parameters: context.parameters)
            try await typed.handle(update: update, context: context.context)
        }
    }

    /// Generates callback data for a typed callback value, scoped to this flow's prefix.
    func callbackData<Callback: TelerouteCallback>(for callback: Callback) throws -> String {
        try self.callbackData(Callback.path, parameters: callback.parameters)
    }

    /// Creates an inline keyboard button for a typed callback value, scoped to this flow's prefix.
    func callbackButton<Callback: TelerouteCallback>(
        _ text: String,
        callback: Callback,
        iconCustomEmojiId: String? = nil,
        style: String? = nil
    ) throws -> TGInlineKeyboardButton {
        try self.callbackButton(
            text,
            path: Callback.path,
            parameters: callback.parameters,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }
}
