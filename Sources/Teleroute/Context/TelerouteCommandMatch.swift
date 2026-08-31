import Foundation

/// Parsed command metadata extracted from a Telegram message.
public struct TelerouteCommandMatch: Sendable {
    /// Command name without the leading slash and without an optional `@bot`.
    public let name: String
    /// Raw command token as sent by Telegram, for example `"/start"` or `"/ping@my_bot"`.
    public let rawValue: String
    /// Mentioned bot username, when the command token explicitly targets a bot.
    public let mentionedBotUsername: String?
    /// Trailing command arguments as a single trimmed string.
    public let argumentsText: String?
    /// Trailing command arguments split by whitespace.
    public let arguments: [String]

    /// Creates command metadata, useful for constructing typed commands in
    /// tests or manual dispatch.
    public init(
        name: String,
        rawValue: String,
        mentionedBotUsername: String? = nil,
        argumentsText: String? = nil,
        arguments: [String] = []
    ) {
        self.name = name
        self.rawValue = rawValue
        self.mentionedBotUsername = mentionedBotUsername
        self.argumentsText = argumentsText
        self.arguments = arguments
    }

    /// Returns the argument at the supplied index, if it exists.
    ///
    /// The `name` is used only to keep the API symmetrical with `TelerouteParameters`
    /// and to produce better errors from `require(_:at:)`.
    public func get(_ name: String, at index: Int = 0) -> String? {
        guard self.arguments.indices.contains(index) else {
            return nil
        }
        return self.arguments[index]
    }

    /// Returns the argument at the supplied index or throws when it is missing.
    ///
    /// Example:
    /// `let userID = try command.require("userID")`
    /// `let reason = try command.require("reason", at: 1)`
    public func require(_ name: String, at index: Int = 0) throws -> String {
        guard let value = self.get(name, at: index) else {
            throw TelerouteError.missingParameter(name)
        }
        return value
    }

    /// Returns the argument decoded into a `LosslessStringConvertible` type.
    public func get<Value: LosslessStringConvertible>(
        _ name: String,
        at index: Int = 0,
        as type: Value.Type
    ) -> Value? {
        self.get(name, at: index).flatMap(Value.init)
    }

    /// Returns the argument decoded into a `LosslessStringConvertible` type
    /// or throws when it is missing or malformed.
    public func require<Value: LosslessStringConvertible>(
        _ name: String,
        at index: Int = 0,
        as type: Value.Type
    ) throws -> Value {
        let raw = try self.require(name, at: index)
        guard let value = Value(raw) else {
            throw TelerouteError.invalidParameter(name: name, value: raw)
        }
        return value
    }

    /// Returns the argument at the supplied index, if it exists.
    public subscript(_ index: Int) -> String? {
        self.arguments.indices.contains(index) ? self.arguments[index] : nil
    }
}
