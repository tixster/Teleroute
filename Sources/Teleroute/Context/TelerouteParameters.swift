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
    public func require(_ name: String) throws(TelerouteError) -> String {
        guard let value = self.get(name) else {
            throw TelerouteError.missingParameter(name)
        }
        return value
    }

    /// Returns the parameter decoded into a `LosslessStringConvertible` type,
    /// or `nil` when it is missing or malformed.
    public func get<Value: LosslessStringConvertible>(
        _ name: String,
        as type: Value.Type
    ) -> Value? {
        self.get(name).flatMap(Value.init)
    }

    /// Returns the parameter decoded into a `LosslessStringConvertible` type
    /// or throws when it is missing or malformed.
    public func require<Value: LosslessStringConvertible>(
        _ name: String,
        as type: Value.Type
    ) throws(TelerouteError) -> Value {
        let raw = try self.require(name)
        guard let value = Value(raw) else {
            throw TelerouteError.invalidParameter(name: name, value: raw)
        }
        return value
    }

    /// Returns the value for a parameter name, if it exists.
    public subscript(_ name: String) -> String? {
        self.get(name)
    }
}
