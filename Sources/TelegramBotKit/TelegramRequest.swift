import Foundation
import TelegramBotAPI

/// One Bot API call, built up parameter by parameter before it is encoded.
///
/// The generated wrappers build these: one `set` per documented parameter, with
/// `nil` values dropping out on their own. Keeping the parameters as typed
/// values rather than pre-serialised strings is what lets the encoder choose
/// JSON or multipart per call instead of per method.
public struct TelegramRequest: Sendable {
    /// The Bot API method name, e.g. `sendMessage`. Also the operation id the
    /// client middlewares see.
    public let operation: String
    private(set) var fields: [Field] = []

    struct Field: Sendable {
        var name: String
        var value: Value
    }

    enum Value: Sendable {
        case string(String)
        case integer(Int64)
        case boolean(Bool)
        case double(Double)
        case chatId(ChatId)
        /// An object or an array. Never a JSON fragment: scalars have their own
        /// cases so multipart can send them as plain text.
        case json(any Encodable & Sendable)
        case file(FileInput)
    }

    public init(_ operation: String) {
        self.operation = operation
    }

    /// True when some parameter carries bytes to upload.
    ///
    /// This is the whole rule for choosing multipart. Telegram accepts a JSON
    /// body for every method, so multipart is only worth its overhead when
    /// there is actually a file in the request.
    var needsMultipart: Bool {
        self.fields.contains { field in
            if case let .file(input) = field.value, case .upload = input { return true }
            return false
        }
    }

    private mutating func append(_ name: String, _ value: Value) {
        self.fields.append(Field(name: name, value: value))
    }

    public mutating func set(_ name: String, _ value: String?) {
        if let value { self.append(name, .string(value)) }
    }

    public mutating func set(_ name: String, _ value: Int64?) {
        if let value { self.append(name, .integer(value)) }
    }

    public mutating func set(_ name: String, _ value: Bool?) {
        if let value { self.append(name, .boolean(value)) }
    }

    public mutating func set(_ name: String, _ value: Double?) {
        if let value { self.append(name, .double(value)) }
    }

    public mutating func set(_ name: String, _ value: ChatId?) {
        if let value { self.append(name, .chatId(value)) }
    }

    public mutating func set(_ name: String, _ value: FileInput?) {
        if let value { self.append(name, .file(value)) }
    }

    /// Objects and arrays. Scalars match the concrete overloads above, so this
    /// only ever receives something JSON-serialisable on its own.
    public mutating func set(_ name: String, _ value: (some Encodable & Sendable)?) {
        if let value { self.append(name, .json(value)) }
    }

    /// Adds a parameter whose static type is not known — the escape hatch
    /// ``TelegramBotClient/call(_:_:as:)`` uses. Kept separate from `set` so it
    /// cannot make the generated call sites ambiguous.
    public mutating func setAny(_ name: String, _ value: (any Encodable & Sendable)?) {
        if let value { self.append(name, .json(value)) }
    }
}

/// Erases an `Encodable` so heterogeneous parameters can share one container.
struct AnyEncodable: Encodable {
    let value: any Encodable
    init(_ value: any Encodable) { self.value = value }
    func encode(to encoder: any Encoder) throws { try self.value.encode(to: encoder) }
}

/// A `CodingKey` built from a wire name.
struct TelegramCodingKey: CodingKey {
    var stringValue: String
    var intValue: Int? { nil }
    init(_ stringValue: String) { self.stringValue = stringValue }
    init?(stringValue: String) { self.stringValue = stringValue }
    init?(intValue: Int) { nil }
}
