/// Describes a typed callback route.
public protocol TelerouteCallback: Sendable {
    /// Callback path relative to the current route scope.
    static var path: String { get }

    /// Creates a typed callback from decoded route parameters.
    init(parameters: TelerouteParameters) throws

    /// Parameters used to generate callback data for this callback.
    var parameters: [String: String] { get }
}

/// A typed callback that handles its own matched update.
///
/// This is convenient for small, self-contained callbacks. Prefer registering
/// an explicit handler from a ``TelerouteRouteCollection`` when the handler owns injected
/// dependencies or coordinates multiple routes.
public protocol TelerouteHandlingCallback: TelerouteCallback {
    /// Request context type the handler expects; defaults to the core context.
    associatedtype Context: TelerouteRequestContext = TelerouteContext

    /// Handles the update after the callback value has been decoded.
    func handle(context: Context) async throws -> TelerouteResponse
}
