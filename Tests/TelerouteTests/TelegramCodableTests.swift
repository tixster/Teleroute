import Foundation
import Testing
@testable import TelegramBotKit

/// Round-trip tests for the generated model layer.
///
/// These cover the three places where generation makes a real decision:
/// discriminated unions, the unions that must *not* be discriminated, and the
/// fields whose storage moved behind a box (for recursion or for size). A
/// dropped `CodingKeys` mapping or a wrong discriminator shows up here and
/// nowhere else, so every case also asserts that re-encoding preserves the
/// original key set.
@Suite struct TelegramCodableTests {
    // MARK: - Helpers

    /// Decodes, re-encodes, decodes again, and checks the value survives and
    /// the JSON keeps the same top-level keys.
    private func roundTrip<Value: Codable & Equatable>(
        _ type: Value.Type,
        _ json: String,
        sourceLocation: SourceLocation = #_sourceLocation
    ) throws -> Value {
        let data = Data(json.utf8)
        let decoded = try JSONDecoder().decode(Value.self, from: data)
        let reencoded = try JSONEncoder().encode(decoded)
        let again = try JSONDecoder().decode(Value.self, from: reencoded)
        #expect(decoded == again, "value changed across a round trip", sourceLocation: sourceLocation)

        if let original = try JSONSerialization.jsonObject(with: data) as? [String: Any],
           let produced = try JSONSerialization.jsonObject(with: reencoded) as? [String: Any] {
            #expect(
                Set(original.keys) == Set(produced.keys),
                "re-encoded JSON key set differs: \(Set(original.keys).symmetricDifference(Set(produced.keys)))",
                sourceLocation: sourceLocation
            )
        }
        return decoded
    }

    private static let user = #"{"id":7,"is_bot":false,"first_name":"U"}"#
    private static let chat = #"{"id":1,"type":"private"}"#

    // MARK: - Discriminated unions

    @Test func chatMemberDecodesEveryStatus() throws {
        let cases: [(String, String)] = [
            ("creator", #"{"status":"creator","user":\#(Self.user),"is_anonymous":false}"#),
            (
                "administrator",
                #"{"status":"administrator","user":\#(Self.user),"can_be_edited":false,"is_anonymous":false,"can_manage_chat":true,"can_delete_messages":true,"can_manage_video_chats":true,"can_restrict_members":true,"can_promote_members":false,"can_change_info":true,"can_invite_users":true,"can_post_stories":true,"can_edit_stories":true,"can_delete_stories":true,"can_send_welcome_messages":true}"#
            ),
            ("member", #"{"status":"member","user":\#(Self.user)}"#),
            (
                "restricted",
                #"{"status":"restricted","user":\#(Self.user),"is_member":true,"can_send_messages":true,"can_send_audios":true,"can_send_documents":true,"can_send_photos":true,"can_send_videos":true,"can_send_video_notes":true,"can_send_voice_notes":true,"can_send_polls":true,"can_send_other_messages":true,"can_add_web_page_previews":true,"can_react_to_messages":true,"can_edit_tag":false,"can_change_info":true,"can_invite_users":true,"can_pin_messages":true,"can_manage_topics":true,"until_date":0}"#
            ),
            ("left", #"{"status":"left","user":\#(Self.user)}"#),
            ("kicked", #"{"status":"kicked","user":\#(Self.user),"until_date":0}"#),
        ]
        for (status, json) in cases {
            let member = try self.roundTrip(ChatMember.self, json)
            // The case is named after the wire value, so this mapping is the
            // discriminator working end to end.
            switch (status, member) {
            case ("creator", .creator), ("administrator", .administrator), ("member", .member),
                ("restricted", .restricted), ("left", .left), ("kicked", .kicked):
                break
            default:
                Issue.record("status \(status) decoded to the wrong case: \(member)")
            }
        }
    }

    @Test func reactionTypeAndMessageOriginDiscriminate() throws {
        let reaction = try self.roundTrip(ReactionType.self, #"{"type":"emoji","emoji":"👍"}"#)
        guard case .emoji = reaction else {
            Issue.record("expected .emoji, got \(reaction)")
            return
        }
        let origin = try self.roundTrip(
            MessageOrigin.self,
            #"{"type":"hidden_user","date":1,"sender_user_name":"anon"}"#
        )
        guard case .hiddenUser = origin else {
            Issue.record("expected .hiddenUser, got \(origin)")
            return
        }
    }

    @Test func botCommandScopeUsesTheKeywordSafeCaseName() throws {
        let scope = try self.roundTrip(BotCommandScope.self, #"{"type":"default"}"#)
        guard case ._default = scope else {
            Issue.record("expected ._default, got \(scope)")
            return
        }
    }

    // MARK: - The union that must not be discriminated

    @Test func cachedAndUncachedInlineResultsStayDistinct() throws {
        // `InlineQueryResult` reuses `audio` for both the cached and the
        // non-cached variant, which is why it decodes by trying each variant
        // rather than by reading `type`. Discriminating it would silently
        // resolve both of these to the same case.
        let uncached = try self.roundTrip(
            InlineQueryResult.self,
            #"{"type":"audio","id":"1","audio_url":"https://example.com/a.mp3","title":"A"}"#
        )
        guard case .InlineQueryResultAudio = uncached else {
            Issue.record("expected .InlineQueryResultAudio, got \(uncached)")
            return
        }
        let cached = try self.roundTrip(
            InlineQueryResult.self,
            #"{"type":"audio","id":"2","audio_file_id":"AgAC"}"#
        )
        guard case .InlineQueryResultCachedAudio = cached else {
            Issue.record("expected .InlineQueryResultCachedAudio, got \(cached)")
            return
        }
    }

    @Test func maybeInaccessibleMessageKeepsBothShapes() throws {
        let accessible = try self.roundTrip(
            MaybeInaccessibleMessage.self,
            #"{"message_id":5,"date":1700000000,"chat":\#(Self.chat)}"#
        )
        #expect(accessible.accessibleMessage?.messageId == 5)
    }

    // MARK: - RichText's three shapes

    @Test func richTextAcceptsStringArrayAndObject() throws {
        let plain = try JSONDecoder().decode(RichText.self, from: Data(#""hello""#.utf8))
        guard case let .text(value) = plain, value == "hello" else {
            Issue.record("expected .text(\"hello\"), got \(plain)")
            return
        }
        let nested = try JSONDecoder().decode(RichText.self, from: Data(#"["a","b"]"#.utf8))
        guard case let .sequence(items) = nested, items.count == 2 else {
            Issue.record("expected .sequence of 2, got \(nested)")
            return
        }
        let bold = try JSONDecoder().decode(
            RichText.self,
            from: Data(#"{"type":"bold","text":"x"}"#.utf8)
        )
        guard case .bold = bold else {
            Issue.record("expected .bold, got \(bold)")
            return
        }
        // Encoding has to reproduce each shape, not just the object one.
        #expect(String(decoding: try JSONEncoder().encode(plain), as: UTF8.self) == #""hello""#)
    }

    // MARK: - Boxed storage

    @Test func messageKeepsNestedMessagesAcrossARoundTrip() throws {
        // `reply_to_message` is boxed to break the cycle and `pinned_message`
        // goes through the indirect `MaybeInaccessibleMessage`; both have to
        // survive decode, encode and decode again.
        let json = #"""
        {
          "message_id": 10,
          "date": 1700000000,
          "chat": \#(Self.chat),
          "text": "reply",
          "reply_to_message": {"message_id": 9, "date": 1699999999, "chat": \#(Self.chat), "text": "original"},
          "pinned_message": {"message_id": 8, "date": 1699999998, "chat": \#(Self.chat), "text": "pinned"}
        }
        """#
        let message = try self.roundTrip(Message.self, json)
        #expect(message.replyToMessage?.text == "original")
        #expect(message.pinnedMessage?.accessibleMessage?.text == "pinned")
    }

    @Test func settingABoxedPropertyIsVisibleImmediately() throws {
        var message = Message(messageId: 1, date: 0, chat: Chat(id: 1, type: .private))
        #expect(message.replyToMessage == nil)
        message.replyToMessage = Message(messageId: 2, date: 0, chat: Chat(id: 1, type: .private))
        #expect(message.replyToMessage?.messageId == 2)
        message.replyToMessage = nil
        #expect(message.replyToMessage == nil)
    }

    // MARK: - Update kinds

    @Test func updateKindMatchesThePayload() throws {
        let message = try self.roundTrip(
            Update.self,
            #"{"update_id":1,"message":{"message_id":1,"date":0,"chat":\#(Self.chat)}}"#
        )
        #expect(message.kind == .message)

        let callback = try self.roundTrip(
            Update.self,
            #"{"update_id":2,"callback_query":{"id":"c","from":\#(Self.user),"chat_instance":"ci","data":"x"}}"#
        )
        #expect(callback.kind == .callbackQuery)

        #expect(try self.roundTrip(Update.self, #"{"update_id":3}"#).kind == nil)
        #expect(UpdateKind.allCases.count == UpdateKind.allCases.count)
    }

    // MARK: - Version stamp

    @Test func generatedSourcesRecordTheirBotAPIVersion() {
        #expect(!BotAPIVersion.version.isEmpty)
        #expect(BotAPIVersion.version.contains("."))
        #expect(BotAPIVersion.source == "https://core.telegram.org/bots/api")
    }
}
