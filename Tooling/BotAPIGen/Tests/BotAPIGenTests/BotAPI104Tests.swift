import Foundation
import Testing
@testable import BotAPIGen

@Suite struct BotAPI104Tests {
    @Test func committedSnapshotResolvesTheComplete104Surface() throws {
        let root = URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent().deletingLastPathComponent()
            .deletingLastPathComponent()
        let snapshot = try Snapshot.load(directory: root.appendingPathComponent("botapi"), refreshing: false)
        let (spec, stats) = try SpecParser(html: snapshot.html, sha256: snapshot.sha256).parse()
        try snapshot.verify(botApiVersion: spec.botApiVersion, botApiDate: spec.botApiDate)
        try Invariants.check(spec: spec, statistics: stats)
        #expect(spec.botApiVersion == "10.4")
        #expect(spec.botApiDate == "November 9, 2026")
        #expect(spec.types.count == 427)
        #expect(spec.methods.count == 193)
        #expect(spec.typesByName["StoryAreaPosition"] == nil)
        #expect(spec.typesByName["AreaPosition"] != nil)
        #expect(stats.emptyStructNames.contains("PaidMessagesWaived"))

        let kinds = try #require(spec.typesByName["Update"]).fields.map(\.wireName)
        #expect(kinds.contains("widget_query"))
        #expect(kinds.contains("shared_widget_query"))
        let input = try #require(spec.typesByName["InputMessageContent"]?.union)
        #expect(input.variants.suffix(2) == ["InputWidgetMessageContent", "InputSharedWidgetMessageContent"])
        #expect(spec.valueEnums.first { $0.name == "MessageEntityType" }?.values.count == 22)
        #expect(spec.valueEnums.first { $0.name == "InlineQueryChatType" }?.users.contains("WidgetQuery.chat_type") == true)
        #expect(spec.valueEnums.first { $0.name == "InlineQueryChatType" }?.users.contains("InlineQuery.chat_type") == true)

        let sends = ["sendMessage", "sendRichMessage", "sendAnimation", "sendAudio", "sendContact",
                     "sendDocument", "sendLivePhoto", "sendLocation", "sendPhoto", "sendSticker",
                     "sendVenue", "sendVideo", "sendVideoNote", "sendVoice"]
        for name in sends {
            let method = try #require(spec.methods.first { $0.name == name })
            let chat = try #require(method.parameters.first { $0.field.wireName == "chat_id" })
            #expect(chat.field.isOptional, "\(name).chat_id")
            #expect(MethodEmitter.declaration(of: chat) == "chatId: ChatId? = nil")
            #expect(MethodEmitter.pacingArgument(for: method) == "chatId")
        }
        #expect(spec.typesByName["EphemeralMessageParameters"]?.fields.first?.isOptional == true)
    }

    @Test func chatTypeNamingOnlySharesIdenticalVocabularies() {
        func type(_ name: String, values: String) -> ApiType {
            .init(name: name, section: "Available types", doc: "", shape: .object([
                .init(wireName: "chat_type", swiftName: "chatType", type: .string,
                      isOptional: true, doc: "Can be either \(values)")
            ]))
        }
        var spec = ApiSpec(botApiVersion: "test", botApiDate: "test", sourceSHA256: "",
                           types: [type("WidgetQuery", values: "\"private\", \"channel\""),
                                   type("InlineQuery", values: "\"sender\", \"private\", \"channel\"")], methods: [])
        var stats = ParseStatistics()
        ValueEnumAnalysis.apply(to: &spec, statistics: &stats)
        #expect(Set(spec.valueEnums.map(\.name)) == ["WidgetQueryChatType", "InlineQueryChatType"])
    }
}
