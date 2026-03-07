import SwiftTelegramBot
import Foundation

/// Describes a typed callback route.
///
/// Use this to decode route parameters into a domain-specific callback value and to
/// generate callback data from the same type.
public protocol TelerouteCallback: Sendable {
    /// Callback path relative to the current group.
    ///
    /// Example: `"orders/{id}/approve"`.
    static var path: String { get }

    /// Creates a typed callback from decoded route parameters.
    init(parameters: TelerouteParameters) throws

    /// Parameters used to generate callback data for this callback.
    var parameters: [String: String] { get throws }

    /// Handles the callback after it has been decoded from route parameters.
    func handle(update: TGUpdate, context: TelerouteContext) async throws
}

public extension TelerouteCallback {
    func handle(update: TGUpdate, context: TelerouteContext) async throws {}
}
