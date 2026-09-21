import Foundation

/// The assertions that turn documentation drift into a loud failure.
///
/// The pipeline this replaced asserted a minimum match count for every rewrite
/// it performed, so a reshaped source broke the build instead of quietly
/// producing a worse API. That is the philosophy carried over here, with
/// today's measured values as the reference point.
///
/// Ranges are used where Telegram legitimately grows (types, methods, rows).
/// Everything about *resolution* — a type string that does not parse, a method
/// whose return type cannot be read, a union whose variants match nothing — is
/// exact, because a near-miss there is a silently wrong Swift signature.
enum Invariants {
    struct Expectation {
        var indirectUnions: [String]
        var cycleBoxedFields: [String]
        var synthesizedUnionNames: [String]
        var unionsWithoutDiscriminator: [String]
        var unionsDemotedForDuplicateValues: [String]
        /// Value enums that must keep existing. New ones appearing is benign —
        /// one *vanishing* means a reworded sentence silently turned a typed
        /// field back into a bare `String`, which is a public API regression.
        /// Name → the number of cases it had when this expectation was
        /// written. An enum that *grows* is Telegram adding a value; one that
        /// *shrinks* means a reworded sentence dropped a case on the floor,
        /// and `unknown(String)` would hide that at runtime.
        var requiredValueEnums: [String: Int]
        /// Documented types with no fields at all. Held as an exact list
        /// because a prose section whose title happens to have no space in it
        /// looks exactly like one, and would otherwise be absorbed silently as
        /// a junk empty struct.
        var emptyStructNames: [String]

        /// Bot API 10.3, measured 2026-09-21.
        static let current = Expectation(
            // Only these two take part in a value-type cycle through a direct
            // field. `RichBlock` and `InputRichBlock` nest only through arrays,
            // which already break the cycle, so marking them `indirect` would
            // buy nothing and cost a heap allocation per value.
            indirectUnions: ["MaybeInaccessibleMessage", "RichText"],
            cycleBoxedFields: [
                "ChecklistTasksAdded.checklistMessage",
                "ChecklistTasksDone.checklistMessage",
                "GiveawayCompleted.giveawayMessage",
                "Message.replyToMessage",
                "SuggestedPostApprovalFailed.suggestedPostMessage",
                "SuggestedPostApproved.suggestedPostMessage",
                "SuggestedPostDeclined.suggestedPostMessage",
                "SuggestedPostPaid.suggestedPostMessage",
                "SuggestedPostRefunded.suggestedPostMessage",
            ],
            synthesizedUnionNames: ["MediaGroupInputMedia", "RichMessageInputMedia"],
            unionsWithoutDiscriminator: ["InputMessageContent", "MaybeInaccessibleMessage"],
            unionsDemotedForDuplicateValues: ["InlineQueryResult"],
            requiredValueEnums: [
                "ChatType": 4, "EncryptedPassportElementType": 13,
                "InlineQueryChatType": 5, "InputStickerFormat": 3,
                "KeyboardButtonStyle": 3, "MaskPositionPoint": 4,
                "MessageEntityType": 20, "PollType": 2,
                "RichMessageButtonStyle": 4, "StickerType": 3,
                // One per union, carried by each variant's discriminator field.
                "BotCommandScopeKind": 7, "ChatMemberKind": 6,
                "InlineQueryResultKind": 12, "InputMediaKind": 6,
                "MenuButtonKind": 3, "ReactionTypeKind": 3,
            ],
            emptyStructNames: [
                "CallbackGame", "CommunityChatRemoved", "DisabledButton",
                "ForumTopicClosed", "ForumTopicReopened", "GeneralForumTopicHidden",
                "GeneralForumTopicUnhidden", "VideoChatStarted",
            ]
        )
    }

    static func check(
        spec: ApiSpec,
        statistics s: ParseStatistics,
        against expected: Expectation = .current
    ) throws {
        var failures: [String] = []
        func require(_ condition: Bool, _ message: @autoclosure () -> String) {
            if !condition { failures.append(message()) }
        }
        func inRange(_ value: Int, _ range: ClosedRange<Int>, _ label: String) {
            require(range.contains(value), "\(label): got \(value), expected \(range.lowerBound)…\(range.upperBound)")
        }
        func exactly<T: Equatable>(_ value: T, _ want: T, _ label: String) {
            require(value == want, "\(label): got \(value), expected \(want)")
        }

        // --- Page structure ------------------------------------------------
        exactly(s.sectionTitles.count, 14, "top-level <h3> sections")
        for section in KnownDeviations.apiSections {
            require(s.sectionTitles.contains(section), "missing API section '\(section)'")
        }
        require(s.apiEntryCount >= 560, "API <h4> entries: got \(s.apiEntryCount), expected at least 560")
        require(
            s.sectionsWithMultipleTables.isEmpty,
            "sections with more than one table: \(s.sectionsWithMultipleTables) — the parser "
                + "reads the first table of each section and relies on there being only one"
        )
        inRange(spec.types.count - expected.synthesizedUnionNames.count - 1, 380...460, "documented types")
        inRange(spec.methods.count, 170...230, "documented methods")
        require(s.proseTitles.count <= 20, "prose sections: got \(s.proseTitles.count), expected at most 20")
        require(s.fieldTableCount >= 340, "field tables: got \(s.fieldTableCount), expected at least 340")
        require(s.parameterTableCount >= 160, "parameter tables: got \(s.parameterTableCount), expected at least 160")
        inRange(s.unionCount, 20...40, "documented unions")
        exactly(
            s.emptyStructNames.sorted(), expected.emptyStructNames,
            "documented types with no fields (an unexpected name here is usually a prose "
                + "section whose title has no space in it, absorbed as a junk empty struct)"
        )
        require(
            s.zeroParameterMethodCount <= 15,
            "zero-parameter methods: got \(s.zeroParameterMethodCount), expected at most 15"
        )
        exactly(s.inputFileEntryCount, 1, "InputFile entries")
        require(s.tableRowCount >= 2600, "table rows: got \(s.tableRowCount), expected at least 2600")

        // Reconciliation: every documented type is accounted for by exactly one
        // shape. No tolerance — a mismatch means an entry was silently dropped.
        let documented = s.fieldTableCount + s.unionCount + s.emptyStructCount + s.inputFileEntryCount
        let classified = spec.types.count - expected.synthesizedUnionNames.count - 1 + s.inputFileEntryCount
        exactly(
            documented, classified,
            "type reconciliation (fieldTables + unions + emptyStructs + InputFile vs. parsed types)"
        )

        // --- Resolution ----------------------------------------------------
        // Reaching this point already proves every type string parsed and every
        // method resolved a return type: both throw at the point of failure.
        exactly(spec.methods.count, s.parameterTableCount + s.zeroParameterMethodCount, "methods with/without parameters")

        let synthesizedResolved = expected.synthesizedUnionNames
            .filter { s.inlineUnionResolutions[$0] != nil }
        exactly(
            synthesizedResolved.sorted(), expected.synthesizedUnionNames.sorted(),
            "synthesized unions actually referenced by the documentation"
        )
        exactly(
            s.unionsWithExtraAlternatives, [KnownDeviations.unionWithExtraAlternatives],
            "unions whose prose adds non-struct alternatives"
        )
        exactly(
            s.unionsWithoutDiscriminator.sorted(), expected.unionsWithoutDiscriminator,
            "unions with no discriminator in the documentation"
        )
        exactly(
            s.unionsDemotedForDuplicateValues.sorted(), expected.unionsDemotedForDuplicateValues,
            "unions demoted because their discriminator values are not distinct"
        )
        exactly(s.indirectUnions.sorted(), expected.indirectUnions, "indirect unions")
        exactly(s.cycleBoxedFields, expected.cycleBoxedFields, "fields boxed to break a cycle")
        // Size-driven boxing is asserted as a property rather than a list: what
        // matters is that no type can be copied onto the stack at a dangerous
        // size, not which particular fields got boxed to achieve it.
        inRange(s.sizeBoxedFieldCount, 1...400, "fields boxed for size")
        require(
            s.largestEstimatedSize <= StorageAnalysis.maximumEstimatedSize,
            "largest estimated type size: got \(s.largestEstimatedSize) bytes, expected at most "
                + "\(StorageAnalysis.maximumEstimatedSize)"
        )

        for type in spec.types {
            require(
                !KnownDeviations.reservedTypeNames.contains(type.name),
                "documented type '\(type.name)' shadows a Swift standard library name"
            )
        }

        // --- Value enums ----------------------------------------------------
        inRange(spec.valueEnums.count, 30...90, "enums recovered from the documentation")
        inRange(s.valueEnumFieldCount, 80...400, "fields lifted into a value enum")
        let recovered = Set(s.valueEnumNames)
        for (name, cases) in expected.requiredValueEnums.sorted(by: { $0.key < $1.key }) {
            guard recovered.contains(name) else {
                failures.append(
                    "value enum '\(name)' is no longer recovered — the field's description was "
                        + "reworded, and its Swift type has silently reverted to String"
                )
                continue
            }
            let found = s.valueEnumCaseCounts[name] ?? 0
            require(
                found >= cases,
                "value enum '\(name)' shrank from \(cases) cases to \(found) — a reworded "
                    + "description dropped a value, and unknown(String) would hide it at runtime"
            )
        }
        let documentedNames = Set(spec.types.map(\.name))
        for enumeration in spec.valueEnums {
            require(
                !documentedNames.contains(enumeration.name),
                "value enum '\(enumeration.name)' collides with a documented type name"
            )
            require(
                !KnownDeviations.reservedTypeNames.contains(enumeration.name),
                "value enum '\(enumeration.name)' shadows a Swift standard library name"
            )
            require(
                Set(enumeration.values).count == enumeration.values.count,
                "value enum '\(enumeration.name)' has duplicate values \(enumeration.values)"
            )
        }

        // --- Sugar ---------------------------------------------------------
        inRange(s.fileInputParameterCount, 10...30, "InputFile parameters")
        inRange(s.fileInputMethodCount, 8...25, "methods taking an InputFile")
        require(s.chatIdOccurrences >= 60, "ChatId occurrences: got \(s.chatIdOccurrences), expected at least 60")
        require(
            s.replyMarkupOccurrences >= 10,
            "ReplyMarkup occurrences: got \(s.replyMarkupOccurrences), expected at least 10"
        )
        require(
            s.parseModeMethodCount >= 10,
            "methods with parse_mode: got \(s.parseModeMethodCount), expected at least 10"
        )
        exactly(s.chatActionParameterCount, 1, "sendChatAction.action parameters")

        let updateFields = spec.typesByName["Update"]?.fields.count ?? 0
        inRange(updateFields - 1, 20...40, "Update kinds")

        guard failures.isEmpty else {
            throw GeneratorError(
                "the documentation no longer has the shape this generator was written against:\n"
                    + failures.map { "  - \($0)" }.joined(separator: "\n")
            )
        }
    }
}
