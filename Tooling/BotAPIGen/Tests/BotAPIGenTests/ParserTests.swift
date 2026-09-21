import XCTest

@testable import BotAPIGen

final class HTMLScannerTests: XCTestCase {
    func testDecodesNumericAndNamedEntities() throws {
        XCTAssertEqual(try HTMLScanner.decodeEntities("it&#39;s &amp; more"), "it's & more")
        XCTAssertEqual(try HTMLScanner.decodeEntities("&ldquo;creator&rdquo;"), "\u{201C}creator\u{201D}")
    }

    func testRejectsUnknownEntity() {
        // Silence is the dangerous failure mode: an entity we do not know about
        // means the page grew a construct nobody has looked at.
        XCTAssertThrowsError(try HTMLScanner.decodeEntities("&frob;"))
    }

    func testProseAmpersandIsNotAnEntity() throws {
        // A run too long to be an entity is just prose punctuation.
        XCTAssertEqual(
            try HTMLScanner.decodeEntities("Tom & Jerry; and friends"),
            "Tom & Jerry; and friends"
        )
    }

    func testPlainTextStripsTagsAndCollapsesWhitespace() throws {
        XCTAssertEqual(
            try HTMLScanner.plainText("<td>  Type of the <em>result</em>\n </td>"),
            "Type of the result"
        )
    }
}

final class InlineTextTests: XCTestCase {
    private let inline = InlineText(knownTypes: ["Message", "User"])

    func testTypeAnchorsBecomeSymbolLinks() throws {
        XCTAssertEqual(
            try self.inline.markdown(##"the sent <a href="#message">Message</a>"##),
            "the sent ``Message``"
        )
    }

    func testMethodAnchorsBecomeCodeSpans() throws {
        // Methods live in another module, so a symbol link would dangle.
        XCTAssertEqual(
            try self.inline.markdown(##"see <a href="#sendmessage">sendMessage</a>"##),
            "see `sendMessage`"
        )
    }

    func testProseAnchorsLoseTheirLink() throws {
        XCTAssertEqual(
            try self.inline.markdown(##"<a href="#sending-files">Sending files</a>"##),
            "Sending files"
        )
    }

    func testExternalLinksKeepTheirURL() throws {
        XCTAssertEqual(
            try self.inline.markdown(#"<a href="https://example.com">docs</a>"#),
            "[docs](https://example.com)"
        )
    }

    func testEmphasisIsClosed() throws {
        // A closing-tag bug here silently drops the trailing marker.
        XCTAssertEqual(try self.inline.markdown("<em>Optional</em>. Text"), "*Optional*. Text")
    }

    func testNestedAnchorsDoNotDoubleWrap() throws {
        // RichBlockThinking's description really does nest identical anchors.
        let source = #"<a href="https://t.me/x"><a href="https://t.me/x">https://t.me/x</a></a>"#
        XCTAssertEqual(try self.inline.markdown(source), "[https://t.me/x](https://t.me/x)")
    }
}

final class TypeGrammarTests: XCTestCase {
    private func makeGrammar() -> TypeGrammar {
        TypeGrammar(
            knownTypes: ["Message", "MessageEntity", "InlineKeyboardMarkup", "ForceReply"],
            unionsByVariants: [["Message", "ForceReply"]: "Either"]
        )
    }

    func testPrimitivesAndArrays() throws {
        var grammar = self.makeGrammar()
        XCTAssertEqual(try grammar.parse("String", context: "t"), .string)
        XCTAssertEqual(try grammar.parse("Integer", context: "t"), .integer)
        XCTAssertEqual(try grammar.parse("True", context: "t"), .trueLiteral)
        XCTAssertEqual(
            try grammar.parse("Array of Array of MessageEntity", context: "t"),
            .array(.array(.named("MessageEntity")))
        )
    }

    func testChatIdAndFileInputAreHoisted() throws {
        var grammar = self.makeGrammar()
        XCTAssertEqual(try grammar.parse("Integer or String", context: "t"), .chatId)
        XCTAssertEqual(try grammar.parse("InputFile or String", context: "t"), .fileOrString)
        XCTAssertEqual(try grammar.parse("InputFile", context: "t"), .fileOrString)
    }

    func testIrregularArrayOfUnionSpelling() throws {
        var grammar = self.makeGrammar()
        // One site uses "Array of A, B and C" rather than an "or" chain.
        XCTAssertEqual(
            try grammar.parse("Array of Message and ForceReply", context: "t"),
            .array(.named("Either"))
        )
    }

    func testUnknownNameIsAHardFailure() {
        var grammar = self.makeGrammar()
        XCTAssertThrowsError(try grammar.parse("Frobnicator", context: "t"))
        XCTAssertThrowsError(try grammar.parse("Message or MessageEntity", context: "t"))
    }
}

final class ReturnGrammarTests: XCTestCase {
    private let grammar = ReturnGrammar(
        knownTypes: ["Message", "MessageId", "User", "ForumTopic", "WebhookInfo", "Update", "ChatMember"]
    )

    func testCommonPhrasings() throws {
        let cases: [(String, ReturnType)] = [
            ("On success, the sent Message is returned.", .value(.named("Message"))),
            ("Returns an Array of Update objects.", .value(.array(.named("Update")))),
            ("Returns basic information about the bot in form of a User object.", .value(.named("User"))),
            ("Returns the new invite link as String on success.", .value(.string)),
            ("Returns information about the created topic as a ForumTopic object.", .value(.named("ForumTopic"))),
            ("On success, an Array of MessageId of the sent messages is returned.", .value(.array(.named("MessageId")))),
            ("Returns True on success.", .value(.boolean)),
            ("Returns Integer on success.", .value(.integer)),
        ]
        for (description, expected) in cases {
            XCTAssertEqual(try self.grammar.parse(description: description, method: "m"), expected, description)
        }
    }

    func testEditedMessageOrTrue() throws {
        let description = "On success, if the edited message is not an inline message, "
            + "the edited Message is returned, otherwise True is returned."
        XCTAssertEqual(try self.grammar.parse(description: description, method: "m"), .messageOrBool)
    }

    func testDecoyObjectMentionIsIgnored() throws {
        // getWebhookInfo's trailing sentence mentions "an object" with no type.
        let description = "Use this method to get current webhook status. On success, returns a "
            + "WebhookInfo object. If the bot is using getUpdates, will return an object with "
            + "the url field empty."
        XCTAssertEqual(
            try self.grammar.parse(description: description, method: "getWebhookInfo"),
            .value(.named("WebhookInfo"))
        )
    }

    func testUnresolvableReturnIsAHardFailure() {
        XCTAssertThrowsError(
            try self.grammar.parse(description: "Does a thing.", method: "mystery")
        )
    }
}

final class DiscriminatorTests: XCTestCase {
    private func stringField(_ name: String, _ doc: String) -> ApiField {
        ApiField(wireName: name, swiftName: name, type: .string, isOptional: false, doc: doc)
    }

    private func variant(_ name: String, _ doc: String) -> ApiType {
        ApiType(name: name, section: "s", doc: "", shape: .object([self.stringField("type", doc)]))
    }

    func testBothDocumentedPhrasings() {
        let types = [
            "A": self.variant("A", "Type of the thing, always \u{201C}alpha\u{201D}"),
            "B": self.variant("B", "Type of the thing, must be *beta*"),
        ]
        let outcome = DiscriminatorFinder.find(variants: ["A", "B"], types: types)
        XCTAssertEqual(outcome.discriminator?.wireKey, "type")
        XCTAssertEqual(outcome.discriminator?.values.map(\.value), ["alpha", "beta"])
    }

    func testDuplicateValuesDemoteTheUnion() {
        // InlineQueryResult reuses "audio" across its cached and non-cached
        // forms; discriminating it would silently pick the wrong variant.
        let types = [
            "A": self.variant("A", "Type of the result, must be *audio*"),
            "B": self.variant("B", "Type of the result, must be *audio*"),
        ]
        let outcome = DiscriminatorFinder.find(variants: ["A", "B"], types: types)
        XCTAssertNil(outcome.discriminator)
        XCTAssertTrue(outcome.demotedForDuplicateValues)
    }

    func testProseIsNotMistakenForADiscriminator() {
        let types = ["A": self.variant("A", "Identifier; must be positive and unique")]
        XCTAssertNil(DiscriminatorFinder.find(variants: ["A"], types: types).discriminator)
    }

    func testPartialCoverageIsNotPromoted() {
        let types = [
            "A": self.variant("A", "Type, always \u{201C}alpha\u{201D}"),
            "B": ApiType(name: "B", section: "s", doc: "", shape: .empty),
        ]
        let outcome = DiscriminatorFinder.find(variants: ["A", "B"], types: types)
        XCTAssertNil(outcome.discriminator)
        XCTAssertFalse(outcome.demotedForDuplicateValues)
    }
}

final class SwiftNameTests: XCTestCase {
    func testSnakeCaseBecomesCamelCase() throws {
        XCTAssertEqual(try SpecParser.swiftName(for: "message_id", owner: "Message"), "messageId")
        XCTAssertEqual(try SpecParser.swiftName(for: "mpeg4_url", owner: "X"), "mpeg4Url")
        XCTAssertEqual(try SpecParser.swiftName(for: "street_line1", owner: "X"), "streetLine1")
    }

    func testKeywordsGoThroughTheRenameTable() throws {
        XCTAssertEqual(try SpecParser.swiftName(for: "default", owner: "X"), "_default")
    }

    func testTypeIsNotTreatedAsAKeyword() throws {
        // `type` is not reserved in Swift. The previous pipeline spelled it
        // `_type`, which was noise on the most-used field name in the API.
        XCTAssertEqual(try SpecParser.swiftName(for: "type", owner: "Chat"), "type")
    }
}

final class ValueEnumMiningTests: XCTestCase {
    private let open = "\u{201C}"
    private let close = "\u{201D}"
    private func q(_ value: String) -> String { self.open + value + self.close }

    func testReadsAClosedValueList() {
        let doc = "Type of the chat, can be either \(q("private")), \(q("group")), "
            + "\(q("supergroup")) or \(q("channel"))"
        XCTAssertEqual(ValueEnumAnalysis.mine(doc), ["private", "group", "supergroup", "channel"])
    }

    func testReadsValuesInterleavedWithExplanations() {
        // MessageEntity.type puts a parenthetical after almost every value.
        let doc = "Type of the entity. Currently, can be \(q("mention")) (@username), "
            + "\(q("hashtag")) (#hashtag), \(q("url")) (https://telegram.org)"
        XCTAssertEqual(ValueEnumAnalysis.mine(doc), ["mention", "hashtag", "url"])
    }

    func testIgnoresIllustrativeLists() {
        // "for example" introduces an illustration, not a closed set, so the
        // field has to stay a String.
        let doc = "Codec that was used to encode the video, for example, \(q("h264")), "
            + "\(q("h265")), or \(q("av01"))"
        XCTAssertNil(ValueEnumAnalysis.mine(doc))
    }

    func testIgnoresValuesBelongingToAnotherField() {
        // EncryptedPassportElement.data lists the element types it is available
        // *for*, not the values it can itself take.
        let doc = "Base64-encoded encrypted data; available only for \(q("personal_details")), "
            + "\(q("passport")), \(q("address"))"
        XCTAssertNil(ValueEnumAnalysis.mine(doc))
    }

    func testSingleValueIsADiscriminatorNotAnEnum() {
        XCTAssertNil(ValueEnumAnalysis.mine("Type of the result, must be *article*"))
    }

    func testCaseNamesEscapeKeywordsOnlyWhereNeeded() {
        XCTAssertEqual(ValueEnumEmitter.caseName(for: "private"), "`private`")
        XCTAssertEqual(ValueEnumEmitter.reference(for: "private"), "private")
        XCTAssertEqual(ValueEnumEmitter.caseName(for: "bot_command"), "botCommand")
    }
}
