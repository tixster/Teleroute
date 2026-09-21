/// The Bot API as parsed from the documentation, before any Swift is emitted.
///
/// Everything here is in document order. Nothing is keyed by a `Dictionary`
/// during emission, because generation has to be byte-for-byte reproducible.
struct ApiSpec {
    var botApiVersion: String
    var botApiDate: String
    var sourceSHA256: String
    var types: [ApiType]
    var methods: [ApiMethod]
    /// Unions that must be declared `indirect` because they take part in a
    /// value-type cycle. Filled in by `RecursionAnalysis`.
    var indirectUnions: Set<String> = []
    /// Estimated in-memory size per type, used to decide which fields must be
    /// stored behind a box. Filled in by `StorageAnalysis`.
    var estimatedSizes: [String: Int] = [:]
    /// Enums recovered from field descriptions that spell out their own
    /// accepted values. Filled in by `ValueEnumAnalysis`.
    var valueEnums: [ApiValueEnum] = []

    var typesByName: [String: ApiType] {
        Dictionary(uniqueKeysWithValues: self.types.map { ($0.name, $0) })
    }
}

struct ApiType {
    var name: String
    /// The `<h3>` the type was documented under, e.g. `Available types`.
    var section: String
    var doc: String
    var shape: Shape

    enum Shape {
        case object([ApiField])
        case union(ApiUnion)
        /// A documented type with no fields, e.g. `ForumTopicClosed`.
        case empty
    }

    var fields: [ApiField] {
        if case let .object(fields) = self.shape { return fields }
        return []
    }

    var union: ApiUnion? {
        if case let .union(union) = self.shape { return union }
        return nil
    }
}

struct ApiUnion {
    /// Variant type names, in the order the `<ul>` lists them.
    var variants: [String]
    /// Non-struct alternatives mined from the prose. `RichText` is the only
    /// union that has any; see `KnownDeviations`.
    var extraAlternatives: [FieldType] = []
    /// The wire key and per-variant literal that let the union decode without
    /// trying every variant. `nil` when the documentation gives no usable
    /// discriminator, or when the literals are not pairwise distinct.
    var discriminator: Discriminator?
    /// Set when a discriminator was found but rejected for duplicate values,
    /// so the invariants can distinguish "absent" from "demoted".
    var demotedForDuplicateValues: Bool = false
    /// The discriminator as found, kept even when decoding cannot use it.
    var foundDiscriminator: Discriminator?

    struct Discriminator {
        var wireKey: String
        /// `(variant type name, wire literal)`, parallel to `variants`.
        var values: [(variant: String, value: String)]
    }
}

struct ApiField {
    var wireName: String
    var swiftName: String
    var type: FieldType
    var isOptional: Bool
    var doc: String
    /// The literal this field always carries, when it is a discriminator.
    var constantValue: String?
    /// Set by the recursion pass: the field participates in a value-type cycle
    /// and must be stored behind an indirect box.
    var needsBoxing: Bool = false
}

struct ApiMethod {
    /// Also the operation id the middlewares see, e.g. `sendMessage`.
    var name: String
    var section: String
    var doc: String
    var parameters: [ApiParameter]
    var returnType: ReturnType
    /// The generated file this method lands in, e.g. `Messaging`.
    var group: String
}

struct ApiParameter {
    var field: ApiField
    var sugar: Sugar

    enum Sugar {
        case none
        /// `InputFile` / `InputFile or String` → Teleroute's `FileInput`.
        case fileInput
        /// `parse_mode` → Teleroute's `ParseMode`.
        case parseMode
        /// `sendChatAction.action` → Teleroute's `ChatAction`.
        case chatAction
    }
}

/// A `String` field whose documentation enumerates the values it accepts.
///
/// Telegram writes these out in prose — "Type of the chat, can be either
/// “private”, “group”, “supergroup” or “channel”" — so they can be recovered
/// and turned into a real type instead of leaving the field a bare `String`.
struct ApiValueEnum {
    var name: String
    /// Wire values, in the order the documentation lists them.
    var values: [String]
    var doc: String
    /// `Owner.field` of every field that uses this set, for the doc comment.
    var users: [String]
}

indirect enum FieldType: Hashable {
    case string
    case integer
    case boolean
    case float
    /// Telegram's `True`: present-and-true, absent otherwise.
    case trueLiteral
    case named(String)
    case array(FieldType)
    /// `Integer or String`.
    case chatId
    /// `InputFile` or `InputFile or String`.
    case fileOrString
    /// A `String` whose accepted values the documentation spells out, lifted
    /// into a generated enum of that name.
    case valueEnum(String)
}

enum ReturnType: Hashable {
    case value(FieldType)
    /// "the edited Message is returned, otherwise True is returned" — rendered
    /// as an optional `Message`, as the previous pipeline did.
    case messageOrBool
}

extension FieldType {
    /// The Swift spelling used in generated declarations.
    ///
    /// Primitives are `Swift.`-qualified and Telegram types are bare, so the
    /// generated files can import nothing at all — which is what makes flat
    /// top-level names safe from Foundation collisions.
    var swiftTypeName: String {
        switch self {
        case .string: "Swift.String"
        case .integer: "Swift.Int64"
        case .boolean, .trueLiteral: "Swift.Bool"
        case .float: "Swift.Double"
        case .named(let name): name
        case .array(let element): "[\(element.swiftTypeName)]"
        case .chatId: "ChatId"
        case .fileOrString: "FileInput"
        case .valueEnum(let name): name
        }
    }

    /// The type names this field refers to directly, not through an array.
    /// Arrays are heap buffers, so they already break value-type cycles.
    var directReferences: [String] {
        if case let .named(name) = self { return [name] }
        return []
    }

    var allReferences: [String] {
        switch self {
        case .named(let name): [name]
        case .array(let element): element.allReferences
        default: []
        }
    }
}

extension ReturnType {
    var swiftTypeName: String {
        switch self {
        case .value(let type): type.swiftTypeName
        case .messageOrBool: "Message?"
        }
    }
}
