import Foundation

/// Route parameters extracted from callback patterns such as `"orders/{id}"`.
public struct TelerouteParameters: Sendable {
    private let storage: [String: String]

    /// Creates a parameter container from a dictionary.
    public init(_ storage: [String: String] = [:]) {
        self.storage = storage
    }

    /// Returns `true` when the route did not extract any parameters.
    public var isEmpty: Bool {
        self.storage.isEmpty
    }

    /// Returns the value for a parameter name, if it exists.
    public func get(_ name: String) -> String? {
        self.storage[name]
    }

    /// Returns the value for a parameter name or throws when it is missing.
    public func require(_ name: String) throws -> String {
        guard let value = self.get(name) else {
            throw TelerouteError.missingParameter(name)
        }
        return value
    }

    /// Returns the value for a parameter name, if it exists.
    public subscript(_ name: String) -> String? {
        self.get(name)
    }
}
