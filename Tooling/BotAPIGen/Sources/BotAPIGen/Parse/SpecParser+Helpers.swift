import Foundation

extension SpecParser {
    // MARK: - Version

    /// The Bot API version and release date, from the first `Recent changes`
    /// entry. Used to stamp the generated header and to cross-check the
    /// snapshot metadata.
    static func botApiVersion(in document: SlicedDocument) throws -> (version: String, date: String) {
        guard let entry = document.entries.first(where: { $0.section == "Recent changes" }) else {
            throw GeneratorError("documentation snapshot has no 'Recent changes' section")
        }
        let plain = try HTMLScanner.plainText(entry.content)
        let pattern = try NSRegularExpression(pattern: "Bot API (\\d+\\.\\d+)")
        guard let match = pattern.firstMatch(in: plain, range: NSRange(plain.startIndex..., in: plain)),
              let captured = Range(match.range(at: 1), in: plain)
        else {
            throw GeneratorError("no 'Bot API X.Y' version found in the latest 'Recent changes' entry")
        }
        return (String(plain[captured]), entry.title)
    }

    // MARK: - Tables

    static func expectHeaders(_ table: RawTable, _ expected: [String], entry: RawEntry) throws {
        guard table.headers == expected else {
            throw GeneratorError(
                "'\(entry.title)' has table headers \(table.headers), expected \(expected)"
            )
        }
    }

    /// Telegram marks an optional field by opening its description with
    /// `<em>Optional</em>.`. Cross-checked against the previous pipeline's spec
    /// with zero mismatches, so no heuristic is needed.
    static func isOptionalField(_ descriptionHTML: String) -> Bool {
        descriptionHTML.trimmingCharacters(in: .whitespaces).hasPrefix("<em>Optional</em>.")
    }

    // MARK: - Fields

    static func makeField(
        wireName: String,
        typeString: String,
        descriptionHTML: String,
        isOptional: Bool,
        owner: String,
        grammar: inout TypeGrammar,
        inlineText: InlineText,
        statistics: inout ParseStatistics
    ) throws -> ApiField {
        let type = try grammar.parse(typeString, context: "\(owner).\(wireName)")
        switch type {
        case .chatId: statistics.chatIdOccurrences += 1
        case .named(KnownDeviations.replyMarkup.name): statistics.replyMarkupOccurrences += 1
        default: break
        }
        let doc = try inlineText.markdown(descriptionHTML)
        return ApiField(
            wireName: wireName,
            swiftName: try self.swiftName(for: wireName, owner: owner),
            type: type,
            isOptional: isOptional,
            doc: doc,
            constantValue: DiscriminatorFinder.literal(in: doc)
        )
    }

    /// `message_id` → `messageId`, `street_line1` → `streetLine1`, and Swift
    /// keywords through the rename table rather than a silent backtick.
    static func swiftName(for wireName: String, owner: String) throws -> String {
        let segments = wireName.split(separator: "_", omittingEmptySubsequences: true)
        guard let first = segments.first else {
            throw GeneratorError("empty field name in '\(owner)'")
        }
        let camel = segments.dropFirst().reduce(String(first)) { partial, segment in
            partial + segment.prefix(1).uppercased() + segment.dropFirst()
        }
        guard Self.swiftKeywords.contains(camel) else { return camel }
        guard let renamed = KnownDeviations.keywordRenames[camel] else {
            throw GeneratorError(
                "field '\(owner).\(wireName)' maps to the Swift keyword '\(camel)' and has no "
                    + "entry in KnownDeviations.keywordRenames"
            )
        }
        return renamed
    }

    static let swiftKeywords: Set<String> = [
        "associatedtype", "class", "deinit", "enum", "extension", "fileprivate",
        "func", "import", "init", "inout", "internal", "let", "open", "operator",
        "private", "precedencegroup", "protocol", "public", "rethrows", "static",
        "struct", "subscript", "typealias", "var", "break", "case", "continue",
        "default", "defer", "do", "else", "fallthrough", "for", "guard", "if",
        "in", "repeat", "return", "throw", "switch", "where", "while", "as",
        "catch", "is", "nil", "self", "super", "throws", "true", "false", "try",
        "Any", "Self",
    ]

    // MARK: - Unions

    /// `RichText` is the one union whose `<ul>` under-reports: its prose adds a
    /// plain `String` and a nested array. Anything else that grows extras is
    /// caught by `Invariants` rather than absorbed silently.
    static func extraAlternatives(
        unionName: String,
        paragraphs: [String],
        grammar: inout TypeGrammar
    ) throws -> [FieldType] {
        guard let lead = paragraphs.first else { return [] }
        let plain = try HTMLScanner.plainText(lead)
        guard let marker = plain.range(of: "any of the following types") else { return [] }
        let prefix = String(plain[plain.startIndex..<marker.lowerBound])
        guard prefix.contains("can be either") else { return [] }

        var extras: [FieldType] = []
        if prefix.contains("a String") { extras.append(.string) }
        let pattern = try NSRegularExpression(pattern: "an Array of ([A-Z][A-Za-z0-9]*)")
        if let match = pattern.firstMatch(in: prefix, range: NSRange(prefix.startIndex..., in: prefix)),
           let captured = Range(match.range(at: 1), in: prefix) {
            extras.append(.array(.named(String(prefix[captured]))))
        }
        return extras
    }

    /// The unions Telegram only ever spells out inline. Giving them names is
    /// what turns 18 anonymous four-way `reply_markup` enums into one shared
    /// `ReplyMarkup`.
    static func synthesizedUnionTypes(typesByName: [String: ApiType]) -> [ApiType] {
        var results: [ApiType] = []
        let entries: [(name: String, variants: [String], doc: String)] = [
            (
                KnownDeviations.replyMarkup.name,
                ["InlineKeyboardMarkup", "ReplyKeyboardMarkup", "ReplyKeyboardRemove", "ForceReply"],
                "Additional interface options for a message: an inline keyboard, a custom reply "
                    + "keyboard, instructions to remove a reply keyboard, or to force a reply from the user."
            ),
            (
                "MediaGroupInputMedia",
                [
                    "InputMediaAudio", "InputMediaDocument", "InputMediaLivePhoto",
                    "InputMediaPhoto", "InputMediaVideo",
                ],
                "An item of a media group sent with `sendMediaGroup`."
            ),
            (
                "RichMessageInputMedia",
                [
                    "InputMediaAnimation", "InputMediaAudio", "InputMediaDocument",
                    "InputMediaPhoto", "InputMediaVideo", "InputMediaVoiceNote",
                ],
                "The media carried by an ``InputRichMessageMedia`` block."
            ),
        ]
        for entry in entries {
            let outcome = DiscriminatorFinder.find(variants: entry.variants, types: typesByName)
            results.append(
                ApiType(
                    name: entry.name,
                    section: "Shared",
                    doc: entry.doc,
                    shape: .union(
                        ApiUnion(
                            variants: entry.variants,
                            extraAlternatives: [],
                            discriminator: outcome.discriminator,
                            demotedForDuplicateValues: outcome.demotedForDuplicateValues,
                            foundDiscriminator: outcome.found
                        )
                    )
                )
            )
        }
        return results
    }

    // MARK: - Methods

    /// Teleroute's own vocabulary types, substituted for the documentation's
    /// untyped strings and file placeholders. Carried over unchanged from the
    /// pipeline this replaced, so existing call sites keep compiling.
    static func sugar(
        method: String,
        field: ApiField,
        statistics: inout ParseStatistics
    ) -> ApiParameter.Sugar {
        if case .fileOrString = field.type {
            statistics.fileInputParameterCount += 1
            return .fileInput
        }
        if method == "sendChatAction", field.wireName == "action", case .string = field.type {
            statistics.chatActionParameterCount += 1
            return .chatAction
        }
        if field.wireName == "parse_mode", case .string = field.type {
            return .parseMode
        }
        return .none
    }

    /// Which generated file a method lands in. Ported verbatim from the
    /// pipeline this replaced, so the seven files keep their membership and the
    /// migration diff stays readable. The keyword lists are arbitrary but
    /// stable; changing one moves methods between files for no gain.
    static func group(for operationID: String) -> String {
        let lowered = operationID.lowercased()
        if ["getUpdates", "setWebhook", "deleteWebhook", "getWebhookInfo", "getMe", "logOut", "close"]
            .contains(operationID) {
            return "Updates"
        }
        if lowered.contains("sticker") { return "Stickers" }
        if ["inline", "webapp", "guestquery"].contains(where: lowered.contains) { return "Inline" }
        if [
            "invoice", "shipping", "precheckout", "star", "gift", "payment",
            "paidmedia", "subscription",
        ].contains(where: lowered.contains) { return "Payments" }
        if lowered.contains("chat") || lowered.contains("forum") { return "Chats" }
        if [
            "send", "edit", "delete", "forward", "copy", "stop", "message",
            "poll", "story", "reaction", "dice", "media",
        ].contains(where: lowered.contains) { return "Messaging" }
        return "Misc"
    }
}
