import Foundation

/// A typed handle returned when a callback route is registered.
///
/// The handle binds callback values to the exact route scope and router that
/// registered them. Buttons created through it can therefore be composed in
/// any keyboard scope belonging to the same router without repeating paths or
/// manually rendering nested callbacks first.
public struct TelerouteCallbackRoute<Callback: TelerouteCallback>: Sendable {
    let binding: TelerouteCallbackRouteBinding

    init(
        _ callbackType: Callback.Type,
        routes: TelerouteRoutes
    ) {
        self.binding = .init(
            storageIdentity: routes.storage.identity,
            pattern: .init(
                prefix: routes.callbackPrefix,
                path: callbackType.path
            )
        )
    }

    /// Generates callback data using this route's registered scope.
    public func callbackData(for callback: Callback) throws -> String {
        try self.binding.callbackData(for: callback)
    }

    /// Creates a button bound to this registered callback route.
    public func button(
        _ callback: Callback,
        _ text: String,
        iconCustomEmojiId: String? = nil,
        style: KeyboardButtonStyle? = nil
    ) -> TelerouteButton {
        .callback(
            text,
            callback,
            binding: self.binding,
            iconCustomEmojiId: iconCustomEmojiId,
            style: style
        )
    }
}

struct TelerouteCallbackRouteBinding: Sendable {
    let storageIdentity: UUID
    let pattern: TelerouteCallbackPattern

    func callbackData(for callback: any TelerouteCallback) throws -> String {
        try self.pattern.render(parameters: callback.parameters)
    }

    func callbackData(
        for callback: any TelerouteCallback,
        renderedBy routes: TelerouteRoutes
    ) throws -> String {
        guard self.storageIdentity == routes.storage.identity else {
            throw TelerouteError.callbackRouteRouterMismatch(self.pattern.routeDescription)
        }
        return try self.callbackData(for: callback)
    }
}
