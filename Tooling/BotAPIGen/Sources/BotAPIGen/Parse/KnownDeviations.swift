/// The handful of places where the documentation's prose carries information
/// its tables do not.
///
/// Every entry here is asserted by `Invariants`, so a future Bot API that grows
/// a second deviation fails generation instead of quietly producing a worse API.
enum KnownDeviations {
    /// Inline unions the documentation never gives a name to.
    ///
    /// The pipeline this replaced hoisted the first of these and left the
    /// second inline, where it became an anonymous nested payload enum. Naming
    /// both gives call sites one shared type instead of a fresh enum per site.
    static let synthesizedUnions: [(name: String, variants: Set<String>)] = [
        (
            "MediaGroupInputMedia",
            [
                "InputMediaAudio", "InputMediaDocument", "InputMediaLivePhoto",
                "InputMediaPhoto", "InputMediaVideo",
            ]
        ),
        (
            "RichMessageInputMedia",
            [
                "InputMediaAnimation", "InputMediaAudio", "InputMediaDocument",
                "InputMediaPhoto", "InputMediaVideo", "InputMediaVoiceNote",
            ]
        ),
    ]

    /// `ReplyMarkup` is a real four-variant union used at 18 sites, but the
    /// documentation only ever spells it out inline. Name it so call sites get
    /// one shared type instead of a fresh anonymous enum each time.
    static let replyMarkup = (
        name: "ReplyMarkup",
        variants: Set([
            "InlineKeyboardMarkup", "ReplyKeyboardMarkup", "ReplyKeyboardRemove", "ForceReply",
        ])
    )

    /// The only union whose `<ul>` under-reports its alternatives. `RichText`'s
    /// prose reads "it can be either a String for plain text, an Array of
    /// RichText, or any of the following types".
    static let unionWithExtraAlternatives = "RichText"

    /// Property names that collide with Swift keywords, and what they become.
    ///
    /// `type` is deliberately absent: it is not a Swift keyword, and the
    /// previous pipeline's `_type` spelling was noise on the most-used field in
    /// the whole API.
    static let keywordRenames: [String: String] = [
        "default": "_default", "protocol": "_protocol",
        "operator": "_operator", "case": "_case", "for": "_for", "in": "_in",
        "is": "_is", "as": "_as", "self": "_self", "func": "_func",
        "return": "_return", "where": "_where", "init": "_init",
        "continue": "_continue", "extension": "_extension", "internal": "_internal",
        "public": "_public", "private": "_private", "static": "_static",
        "class": "_class", "struct": "_struct", "enum": "_enum", "var": "_var",
        "let": "_let", "true": "_true", "false": "_false", "nil": "_nil",
        "repeat": "_repeat", "switch": "_switch", "while": "_while",
        "guard": "_guard", "defer": "_defer", "throw": "_throw", "try": "_try",
        "catch": "_catch", "do": "_do", "if": "_if", "else": "_else",
        "import": "_import", "subscript": "_subscript", "operator_": "_operator_",
    ]

    /// Names that would shadow something in the Swift standard library. None of
    /// the 400 documented types hits this today; the assertion exists so a new
    /// one cannot slip in unnoticed.
    static let reservedTypeNames: Set<String> = [
        "Error", "Result", "Array", "String", "Int", "Int64", "Bool", "Double",
        "Float", "Optional", "Set", "Dictionary", "Task", "Never", "Type", "Any",
        "Self", "Character", "Range", "Sequence", "Collection", "Codable",
        "Encodable", "Decodable", "Hashable", "Equatable", "Sendable",
    ]

    /// `<h3>` sections that document API surface. Everything else on the page
    /// (`Recent changes`, `Authorizing your bot`, …) is prose.
    static let apiSections: [String] = [
        "Getting updates", "Available types", "Available methods",
        "Updating messages", "Stickers", "Rich messages", "Inline mode",
        "Payments", "Telegram Passport", "Games",
    ]
}
