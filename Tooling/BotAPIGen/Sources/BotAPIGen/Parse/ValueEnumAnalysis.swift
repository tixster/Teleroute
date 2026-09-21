import Foundation

/// Lifts `String` fields whose documentation spells out their accepted values
/// into generated enums.
///
/// Telegram documents these in prose — "Type of the chat, can be either
/// “private”, “group”, “supergroup” or “channel”" — which is why the previous
/// pipeline left every one of them a bare `String`. Reading them is safe as
/// long as two things hold, and both are enforced here: the list has to be
/// introduced by a phrase that makes it *this field's* value, and the result is
/// asserted against a committed expectation so a reworded sentence fails
/// generation instead of quietly dropping a case.
///
/// Every generated enum carries an `unknown(String)` case. Telegram adds values
/// between releases, and a decoder that threw on one would turn a new chat type
/// into a dropped update.
enum ValueEnumAnalysis {
    /// Phrases that introduce the field's own accepted values.
    private static let trigger = try! NSRegularExpression(
        pattern: "(?:can be either|can be one of|must be one of|can currently be|can be|must be|it can be|one of)\\s*$",
        options: [.caseInsensitive]
    )
    /// Phrases that introduce *examples* instead. "for example, “h264”, “h265”"
    /// is not an exhaustive list, so those fields stay `String`.
    private static let example = try! NSRegularExpression(
        pattern: "(?:for example|e\\.g\\.|such as)\\s*,?\\s*$",
        options: [.caseInsensitive]
    )
    private static let quoted = try! NSRegularExpression(
        pattern: "[\u{201C}\"]([A-Za-z][A-Za-z0-9_]{0,38})[\u{201D}\"]"
    )

    static func apply(to spec: inout ApiSpec, statistics: inout ParseStatistics) {
        // Candidates in document order: type fields first, so a value set shared
        // with a method parameter is named after the type.
        var candidates: [(owner: String, field: ApiField, isType: Bool)] = []
        for type in spec.types {
            for field in type.fields where field.type == .string {
                candidates.append((type.name, field, true))
            }
        }
        for method in spec.methods {
            for parameter in method.parameters where parameter.field.type == .string {
                candidates.append((method.name, parameter.field, false))
            }
        }

        var byValues: [[String]: ApiValueEnum] = [:]
        var order: [[String]] = []

        // A union's discriminator is the same kind of closed set, just written
        // one variant at a time: `InlineQueryResultArticle.type` always carries
        // "article". Registering them here means those fields get the same
        // treatment — a named type and an initialiser default — instead of
        // every construction site repeating a magic string.
        var kindByVariantField: [String: String] = [:]
        for type in spec.types {
            guard let union = type.union, let discriminator = union.foundDiscriminator else {
                continue
            }
            // A demoted union reuses values across variants — `InlineQueryResult`
            // has both a cached and a non-cached `audio` — so the enum carries
            // the distinct set.
            var values: [String] = []
            for value in discriminator.values.map(\.value) where !values.contains(value) {
                values.append(value)
            }
            let name: String
            if let existing = byValues[values] {
                name = existing.name
                byValues[values]?.users.append("\(type.name).\(discriminator.wireKey)")
            } else {
                name = "\(type.name)Kind"
                byValues[values] = ApiValueEnum(
                    name: name,
                    values: values,
                    doc: "The `\(discriminator.wireKey)` a ``\(type.name)`` variant carries.",
                    users: ["\(type.name).\(discriminator.wireKey)"]
                )
                order.append(values)
            }
            for entry in discriminator.values {
                // The first union to claim a variant names its field; a variant
                // shared between unions (the `InputMedia*` family) keeps the
                // one from the union documented first.
                let key = "\(entry.variant).\(discriminator.wireKey)"
                if kindByVariantField[key] == nil { kindByVariantField[key] = name }
            }
        }

        for candidate in candidates {
            guard let values = self.mine(candidate.field.doc) else { continue }
            if var existing = byValues[values] {
                existing.users.append("\(candidate.owner).\(candidate.field.wireName)")
                byValues[values] = existing
                continue
            }
            byValues[values] = ApiValueEnum(
                name: self.name(owner: candidate.owner, field: candidate.field, isType: candidate.isType),
                values: values,
                doc: candidate.field.doc,
                users: ["\(candidate.owner).\(candidate.field.wireName)"]
            )
            order.append(values)
        }

        // Rewrite every field that uses one of the recovered sets.
        var lifted = 0
        func lift(_ field: inout ApiField, owner: String) {
            guard field.type == .string else { return }
            defer { if case .valueEnum = field.type { lifted += 1 } }
            if let name = kindByVariantField["\(owner).\(field.wireName)"] {
                field.type = .valueEnum(name)
                return
            }
            guard let values = self.mine(field.doc), let enumeration = byValues[values] else {
                return
            }
            field.type = .valueEnum(enumeration.name)
        }

        for index in spec.types.indices {
            guard case var .object(fields) = spec.types[index].shape else { continue }
            let owner = spec.types[index].name
            for fieldIndex in fields.indices { lift(&fields[fieldIndex], owner: owner) }
            spec.types[index].shape = .object(fields)
        }
        for index in spec.methods.indices {
            let owner = spec.methods[index].name
            for parameterIndex in spec.methods[index].parameters.indices {
                lift(&spec.methods[index].parameters[parameterIndex].field, owner: owner)
            }
        }

        spec.valueEnums = order.compactMap { byValues[$0] }
        statistics.valueEnumNames = spec.valueEnums.map(\.name).sorted()
        statistics.valueEnumFieldCount = lifted
        statistics.valueEnumCaseCounts = Dictionary(
            uniqueKeysWithValues: spec.valueEnums.map { ($0.name, $0.values.count) }
        )
    }

    /// The accepted values a description spells out, or `nil` when it does not.
    static func mine(_ doc: String) -> [String]? {
        let range = NSRange(doc.startIndex..., in: doc)
        for match in self.quoted.matches(in: doc, range: range) {
            guard let start = Range(match.range, in: doc) else { continue }
            let head = String(doc[doc.startIndex..<start.lowerBound])
                .trimmingCharacters(in: .whitespaces)
                .trimmingCharacters(in: CharacterSet(charactersIn: ","))
                .trimmingCharacters(in: .whitespaces)
            let tail = String(head.suffix(30))
            let tailRange = NSRange(tail.startIndex..., in: tail)
            if self.example.firstMatch(in: tail, range: tailRange) != nil { return nil }
            guard self.trigger.firstMatch(in: tail, range: tailRange) != nil else { continue }

            // Values may be interleaved with parenthetical explanations, so
            // collect every quoted identifier from here to the end.
            let rest = NSRange(start.lowerBound..<doc.endIndex, in: doc)
            var values: [String] = []
            for value in self.quoted.matches(in: doc, range: rest) {
                guard let captured = Range(value.range(at: 1), in: doc) else { continue }
                let text = String(doc[captured])
                if !values.contains(text) { values.append(text) }
            }
            return values.count >= 2 ? values : nil
        }
        return nil
    }

    /// `Chat.type` → `ChatType`, `InlineQuery.chat_type` → `InlineQueryChatType`.
    private static func name(owner: String, field: ApiField, isType: Bool) -> String {
        let ownerName = isType ? owner : owner.prefix(1).uppercased() + owner.dropFirst()
        let suffix = field.wireName
            .split(separator: "_")
            .map { $0.prefix(1).uppercased() + $0.dropFirst() }
            .joined()
        return ownerName + suffix
    }
}
