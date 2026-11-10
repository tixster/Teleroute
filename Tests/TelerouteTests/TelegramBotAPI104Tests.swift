import Foundation
import HTTPTypes
import Synchronization
import Testing
import Teleroute
import TelerouteTestSupport

// Deliberately no @testable import: new models, methods, routes, and context
// helpers must all be usable by a library consumer.
@Suite struct TelegramBotAPI104Tests {
    @Test func versionAndRenamedPositionArePublic() throws {
        #expect(BotAPIVersion.version == "10.4")
        #expect(BotAPIVersion.releaseDate == "November 9, 2026")
        let position = AreaPosition(xPercentage: 10, yPercentage: 20, widthPercentage: 30,
                                    heightPercentage: 40, rotationAngle: 0, cornerRadiusPercentage: 0)
        #expect(try roundTrip(position) == position)
        #expect(MessageEntityType.tonAddress.rawValue == "ton_address")
        #expect(MessageEntityType.bankCardNumber.rawValue == "bank_card_number")
        #expect(try JSONDecoder().decode(MessageEntityType.self, from: Data("\"future_entity\"".utf8)) == .unknown("future_entity"))
    }

    @Test(arguments: ["data", "sign_data", "sent_transaction"])
    func widgetQueryVariantsDecodeFromWire(_ kind: String) throws {
        let wallet = #"{"address":"EQ-wallet","amount":"100000000000000000000"}"#
        let extra: String
        switch kind {
        case "data": extra = #", "wallet_card":{"address":"EQ-wallet","amount":"1","stickers":[]}"#
        case "sign_data": extra = #", "wallet":\#(wallet),"sign_data":"signed""#
        default: extra = #", "wallet":\#(wallet),"msg_hash":"hash""#
        }
        let payload = #"{"type":"\#(kind)"\#(extra)}"#
        let query = try JSONDecoder().decode(WidgetQueryType.self, from: Data(payload.utf8))
        #expect(try roundTrip(query) == query)
        switch query {
        case let .data(value): #expect(value.walletCard?.address == "EQ-wallet")
        case let .signData(value): #expect(value.signData == "signed")
        case let .sentTransaction(value): #expect(value.msgHash == "hash")
        }
    }

    @Test func newMessageAndThemeModelsRoundTrip() throws {
        let json = #"""
        {"message_id":1,"date":0,"chat":{"id":42,"type":"private"},
         "widget":{"html":"<p>Hello</p>","id":"widget","public_data":"public","chat_data":"chat"},
         "paid_messages_waived":{},
         "ton_wallet_transfer":{"transaction_id":"tx","peer_address":"EQ-peer","amount":"-1"},
         "quote":{"text":"TON","position":0,"rich_texts":[{"type":"ton_address","text":"TON","address":"EQ-wallet"}]}}
        """#
        let message = try JSONDecoder().decode(Message.self, from: Data(json.utf8))
        #expect(message.widget?.id == "widget")
        #expect(message.paidMessagesWaived != nil)
        #expect(message.tonWalletTransfer?.amount == "-1")
        #expect(message.quote?.richTexts == [.tonAddress(.init(text: .text("TON"), address: "EQ-wallet"))])
        #expect(try roundTrip(message) == message)
        let card = TonWalletCard(address: "EQ-wallet", amount: "999999999999999999999", stickers: [
            .init(position: .init(xPercentage: 1, yPercentage: 2, widthPercentage: 3,
                                  heightPercentage: 4, rotationAngle: 5, cornerRadiusPercentage: 0),
                  nft: .init(address: "EQ-nft", index: "12345678901234567890", name: "NFT", description: "Art",
                             attributes: [.init(traitType: "Color", value: "Blue")]))
        ])
        #expect(try roundTrip(card) == card)
        let theme = ChatShareTheme.emoji(.init(emojis: [.emoji(.init(emoji: "🌟")), .customEmoji(.init(customEmojiId: "7"))]))
        #expect(try roundTrip(theme) == theme)
        let gift = try JSONDecoder().decode(UniqueGift.self, from: Data(API104Transport.giftJSON.utf8))
        let giftTheme = ChatShareTheme.uniqueGift(.init(gift: gift))
        #expect(try roundTrip(giftTheme) == giftTheme)
        let reply = ReplyParameters(messageId: 1, quoteRichTexts: [.tonAddress(.init(text: .text("TON"), address: "EQ-wallet"))])
        #expect(try roundTrip(reply) == reply)
    }

    @Test func widgetInlineContentUsesTheCorrectUnionVariants() throws {
        let widget = InputMessageContent.InputWidgetMessageContent(.init(html: "<p>Hi</p>", allowQueries: true))
        let shared = InputMessageContent.InputSharedWidgetMessageContent(.init(widgetId: "widget", chatData: "state"))
        #expect(try roundTrip(widget) == widget)
        #expect(try roundTrip(shared) == shared)
    }

    @Test func allNewOperationsAndVerificationParametersReachTheWire() async throws {
        let transport = API104Transport()
        let client = try TelegramBotClient(token: "1:test", transport: transport)
        #expect(try await client.sendWidget(chatId: .id(42), html: "<p>Hi</p>", allowQueries: true).messageId == 1)
        #expect(try await client.sendSharedWidget(chatId: .id(42), widgetId: "widget", chatData: "chat").messageId == 1)
        #expect(try await client.answerWidgetQuery(widgetQueryId: "query", data: "answer"))
        #expect(try await client.editMessageWidgetData(chatId: .id(42), messageId: 7, publicData: "public", chatData: "chat"))
        #expect(try await client.editMessageWidgetData(inlineMessageId: "inline", chatData: "inline-data"))
        #expect(try await client.editSharedWidgetData(widgetId: "widget", publicData: "public", cacheTime: 2))
        #expect(try await client.getChatShareThemeBackdrops().backdrops.first?.id == 9)
        #expect(try await client.getUniqueGift(name: "Gift-1").name == "Gift-1")
        #expect(try await client.deleteBusinessAccountGift(businessConnectionId: "business", ownedGiftId: "gift"))
        #expect(try await client.verifyUser(userId: 7, customDescription: "site", customDescriptionParseMode: "HTML"))
        #expect(try await client.verifyChat(chatId: .id(42), customDescription: "site",
                                          customDescriptionEntities: [.init(type: .textLink, offset: 0, length: 4, url: "https://example.com")]))
        let calls = transport.calls
        #expect(calls.map(\.operation) == ["sendWidget", "sendSharedWidget", "answerWidgetQuery", "editMessageWidgetData",
                                         "editMessageWidgetData", "editSharedWidgetData", "getChatShareThemeBackdrops",
                                         "getUniqueGift", "deleteBusinessAccountGift", "verifyUser", "verifyChat"])
        #expect(try calls[0].json()["html"] as? String == "<p>Hi</p>")
        #expect(try calls[1].json()["widget_id"] as? String == "widget")
        #expect(try calls[2].json()["widget_query_id"] as? String == "query")
        #expect(try calls[3].json()["message_id"] as? Int == 7)
        #expect(try calls[4].json()["chat_id"] == nil)
        #expect(try calls[4].json()["inline_message_id"] as? String == "inline")
        #expect(try calls[5].json()["cache_time"] as? Int == 2)
        #expect(try calls[7].json()["name"] as? String == "Gift-1")
        #expect(try calls[8].json()["owned_gift_id"] as? String == "gift")
        #expect(try calls[9].json()["custom_description_parse_mode"] as? String == "HTML")
        #expect(try (calls[10].json()["custom_description_entities"] as? [[String: Any]])?.first?["type"] as? String == "text_link")
        #expect(calls.allSatisfy { $0.request.method == .post && $0.request.headerFields[.contentType] == "application/json" })
    }

    @Test(.timeLimit(.minutes(1)))
    func ephemeralSendsOmitChatAndReceiverAndDoNotAcquireAPacingSlot() async throws {
        let transport = API104Transport()
        let client = try TelegramBotClient(token: "1:test", transport: transport,
                                          sendPacing: .init(perChatInterval: .seconds(120), perGroupInterval: .seconds(120)))
        let ephemeral = EphemeralMessageParameters(callbackQueryId: "callback")
        try await client.sendMessage(text: "one", ephemeralMessageParameters: ephemeral)
        try await client.sendMessage(text: "two", ephemeralMessageParameters: ephemeral)
        for call in transport.calls {
            let json = try call.json()
            #expect(json["chat_id"] == nil)
            let parameters = try #require(json["ephemeral_message_parameters"] as? [String: Any])
            #expect(parameters["callback_query_id"] as? String == "callback")
            #expect(parameters["receiver_user_id"] == nil)
        }
    }

    @Test(arguments: [false, true])
    func optionalChatMediaSupportsBothWireFormats(_ upload: Bool) async throws {
        let transport = API104Transport()
        let client = try TelegramBotClient(token: "1:test", transport: transport)
        let data = Data("photo-bytes".utf8)
        try await client.sendPhoto(photo: upload ? .upload(filename: "photo.png", data: data) : .fileID("photo-id"),
                                   ephemeralMessageParameters: .init(callbackQueryId: "callback"))
        let call = try #require(transport.calls.first)
        if upload {
            let parts = try TelerouteTestMultipart.parts(from: call.body, contentType: call.request.headerFields[.contentType] ?? "")
            #expect(parts["chat_id"] == nil)
            #expect(parts["photo"]?.body == data)
            #expect(parts["photo"]?.filename == "photo.png")
            let parameters = try #require(parts["ephemeral_message_parameters"])
            #expect(try JSONSerialization.jsonObject(with: parameters.body) as? [String: String] == ["callback_query_id": "callback"])
        } else {
            let json = try call.json()
            #expect(json["photo"] as? String == "photo-id")
            #expect(json["chat_id"] == nil)
            #expect(json["ephemeral_message_parameters"] as? [String: String] == ["callback_query_id": "callback"])
        }
    }

    @Test(arguments: ["chat", "inline", "shared"])
    func widgetContextsResolveOnlyDocumentedIdentity(_ variant: String) async throws {
        let transport = API104Transport()
        let client = try TelegramBotClient(token: "1:test", transport: transport)
        let update = Self.update(variant)
        #expect(try roundTrip(update) == update)
        let context = TelerouteContext(bot: client, update: update)
        #expect(context.user?.id == 7)
        #expect(context.userId == 7)
        #expect(context.message == nil)
        #expect(context.chatId == (variant == "chat" ? 42 : nil))
        #expect(context.chat?.id == context.chatId)
        #expect(context.chatType == (variant == "chat" ? .private : nil))
        #expect(context.flowKey == (variant == "chat" ? TelerouteFlowKey(chatId: 42, userId: 7) : nil))
        #expect(context.updateKind == (variant == "shared" ? .sharedWidgetQuery : .widgetQuery))
        #expect(try await context.answerWidgetQuery(data: "ok"))
        #expect(try transport.calls[0].json()["widget_query_id"] as? String == variant)
        #expect(try transport.calls[0].json()["data"] as? String == "ok")
    }

    @Test func widgetHelpersForwardOptionsAndResolveCaptionDefaults() async throws {
        let transport = API104Transport()
        let client = try TelegramBotClient(token: "1:test", transport: transport)
        let context = TelerouteContext(bot: client, update: Self.update("chat"), defaultParseMode: .html)
        try await context.sendWidget(html: "<p>Hi</p>", messageThreadId: 3, width: 250, height: 100,
                                     publicData: "public", chatData: "chat", caption: "Hello",
                                     showCaptionAboveMedia: true, allowQueries: true, isShared: true,
                                     disableNotification: true, protectContent: true, allowPaidBroadcast: false,
                                     messageEffectId: "effect", replyParameters: .init(messageId: 8), replyMarkup: .remove())
        let sent = try transport.calls[0].json()
        #expect(sent["chat_id"] as? Int == 42)
        #expect(sent["parse_mode"] as? String == "HTML")
        #expect(sent["width"] as? Int == 250)
        #expect(sent["height"] as? Int == 100)
        #expect(sent["public_data"] as? String == "public")
        #expect(sent["chat_data"] as? String == "chat")
        #expect(sent["caption"] as? String == "Hello")
        #expect(sent["show_caption_above_media"] as? Bool == true)
        #expect(sent["allow_queries"] as? Bool == true)
        #expect(sent["is_shared"] as? Bool == true)
        #expect(sent["disable_notification"] as? Bool == true)
        #expect(sent["protect_content"] as? Bool == true)
        #expect(sent["allow_paid_broadcast"] as? Bool == false)
        #expect(sent["message_effect_id"] as? String == "effect")
        #expect((sent["reply_parameters"] as? [String: Int])?["message_id"] == 8)
        #expect((sent["reply_markup"] as? [String: Bool])?["remove_keyboard"] == true)
        #expect(sent["message_thread_id"] as? Int == 3)

        let entities = [MessageEntity(type: .bold, offset: 0, length: 5)]
        try await context.sendWidget(html: "<p>Hi</p>", caption: "Hello", captionEntities: entities)
        #expect(try transport.calls[1].json()["parse_mode"] == nil)
        try await context.sendSharedWidget(widgetId: "widget", to: .id(99), messageThreadId: 3,
                                           chatData: "shared-chat", caption: "Hello", captionEntities: entities,
                                           showCaptionAboveMedia: true, disableNotification: true, protectContent: true,
                                           allowPaidBroadcast: false, messageEffectId: "effect",
                                           replyParameters: .init(messageId: 8), replyMarkup: .remove())
        let shared = try transport.calls[2].json()
        #expect(shared["chat_id"] as? Int == 99)
        #expect(shared["widget_id"] as? String == "widget")
        #expect(shared["chat_data"] as? String == "shared-chat")
        #expect(shared["parse_mode"] == nil)
        #expect((shared["caption_entities"] as? [[String: Any]])?.first?["type"] as? String == "bold")
        for key in ["message_thread_id", "caption", "show_caption_above_media", "disable_notification",
                    "protect_content", "allow_paid_broadcast", "message_effect_id", "reply_parameters", "reply_markup"] {
            #expect(NSDictionary(dictionary: [key: shared[key] as Any]).isEqual(to: [key: sent[key] as Any]), "\(key)")
        }
        try await context.sendSharedWidget(widgetId: "widget", parseMode: .markdownV2)
        #expect(try transport.calls[3].json()["parse_mode"] as? String == "MarkdownV2")
        try await context.sendSharedWidget(widgetId: "widget")
        #expect(try transport.calls[4].json()["parse_mode"] as? String == "HTML")
    }

    @Test func missingWidgetTargetsThrowBeforeSending() async throws {
        let transport = API104Transport()
        let context = TelerouteContext(bot: try TelegramBotClient(token: "1:test", transport: transport), update: Update(updateId: 1))
        await #expect {
            try await context.answerWidgetQuery()
        } throws: { error in
            guard let error = error as? TelerouteError, case .widgetQueryMissing = error else { return false }
            return true
        }
        await #expect {
            try await context.sendWidget(html: "<p>Hi</p>")
        } throws: { error in
            guard let error = error as? TelerouteError, case .chatTargetMissing = error else { return false }
            return true
        }
        await #expect(throws: TelerouteError.self) { try await context.sendSharedWidget(widgetId: "widget") }
        #expect(transport.calls.isEmpty)
        try await context.sendWidget(html: "<p>Hi</p>", to: .id(42))
        #expect(transport.calls.count == 1)
    }

    @Test func typedRoutesInheritMiddlewareAndRespectGuardsAndFallthrough() async throws {
        let transport = API104Transport()
        let router = Teleroute(context: WidgetAppContext.self)
        router.middlewares.add(WidgetMarkerMiddleware())
        router.widgetQuery { query, context -> TelerouteResponse in
            #expect(query.id == "chat")
            #expect(context.marked)
            return .unhandled
        }
        let group = router.group("widgets")
        group.widgetQuery(guards: [WidgetSkipGuard()]) { _, _ in
            Issue.record("A skipped route must not execute")
        }
        group.widgetQuery(guards: [TeleroutePrivateChatGuard()]) { query, context in
            #expect(context.marked)
            #expect(context.widgetQuery == query)
            try await context.answerWidgetQuery(data: "routed")
            return TelerouteResponse.none
        }
        group.sharedWidgetQuery { query, context in
            #expect(context.marked)
            #expect(context.sharedWidgetQuery == query)
            #expect(context.chatId == nil)
            // Intentionally no answer: widgets do not use callback auto-answer.
        }
        let bot = try TelerouteBot(token: "1:test", router: router, configuration: .init(replayProtectionStorage: nil),
                                   transport: transport, rateLimit: nil)
        try await bot.test { client in
            let first = await client.execute(Self.update("chat"))
            #expect(first.terminalEvent?.kind == .handled)
            #expect(first.terminalEvent?.routeKind == .update(.widgetQuery))
            let second = await client.execute(Self.update("shared"))
            #expect(second.terminalEvent?.kind == .handled)
            #expect(second.terminalEvent?.routeKind == .update(.sharedWidgetQuery))
        }
        #expect(transport.calls.map(\.operation) == ["answerWidgetQuery"])
        await bot.shutdown()
    }

    @Test func widgetMessageFilterAndGenericOnRouteAreAvailable() async throws {
        let router = Teleroute()
        router.message(.widget) { context -> TelerouteResponse in
            #expect(context.message?.widget?.html == "<p>Hi</p>")
            return .none
        }
        router.on(.widgetQuery, .sharedWidgetQuery) { context -> TelerouteResponse in
            #expect(context.userId == 7)
            return .none
        }
        let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
        try await bot.test { client in
            let message = Update(updateId: 99, message: .init(messageId: 1, date: 0, chat: .init(id: 42, type: .private),
                                                            widget: .init(html: "<p>Hi</p>")))
            #expect(await client.execute(message).terminalEvent?.kind == .handled)
            #expect(await client.execute(Self.update("inline")).terminalEvent?.kind == .handled)
            #expect(await client.execute(Self.update("shared")).terminalEvent?.kind == .handled)
        }
        await bot.shutdown()
    }

    private func roundTrip<T: Codable & Equatable>(_ value: T) throws -> T {
        try JSONDecoder().decode(T.self, from: JSONEncoder().encode(value))
    }

    private static func update(_ variant: String) -> Update {
        let user = User(id: 7, isBot: false, firstName: "User")
        if variant == "shared" {
            return Update(updateId: 2, sharedWidgetQuery: .init(id: variant, from: user, type: .data(.init()), data: "request", widgetId: "widget"))
        }
        return Update(updateId: 1, widgetQuery: .init(id: variant, from: user,
                                                     chat: variant == "chat" ? .init(id: 42, type: .private) : nil,
                                                     messageId: variant == "chat" ? 8 : nil,
                                                     inlineMessageId: variant == "inline" ? "inline-id" : nil,
                                                     chatInstance: "instance", type: .data(.init()), data: "request"))
    }
}

private struct WidgetAppContext: TelerouteInitializableRequestContext {
    let coreContext: TelerouteContext
    var marked = false
    init(source: TelerouteContextSource) { self.coreContext = source.coreContext }
}

private struct WidgetMarkerMiddleware: TelerouteMiddleware {
    func handle(_ context: WidgetAppContext, next: @escaping @Sendable (WidgetAppContext) async throws -> TelerouteResponse) async throws -> TelerouteResponse {
        var context = context
        context.marked = true
        return try await next(context)
    }
}

private struct WidgetSkipGuard: TelerouteGuard {
    func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult { .skip }
}

private final class API104Transport: TelegramTransport, Sendable {
    struct Call: Sendable {
        let operation: String
        let request: HTTPRequest
        let body: Data
        func json() throws -> [String: Any] {
            if body.isEmpty { return [:] }
            return try #require(JSONSerialization.jsonObject(with: body) as? [String: Any])
        }
    }
    private let storage = Mutex<[Call]>([])
    var calls: [Call] { storage.withLock { $0 } }

    func send(_ request: HTTPRequest, body: Data?, baseURL: URL, operationID: String) async throws -> (HTTPResponse, Data) {
        storage.withLock { $0.append(.init(operation: operationID, request: request, body: body ?? Data())) }
        let result: String
        switch operationID {
        case "sendMessage", "sendPhoto", "sendWidget", "sendSharedWidget":
            result = #"{"message_id":1,"date":0,"chat":{"id":42,"type":"private"}}"#
        case "getChatShareThemeBackdrops":
            result = #"{"backdrops":[{"id":9,"name":"Blue","colors":{"center_color":1,"edge_color":2,"symbol_color":3,"text_color":4}}]}"#
        case "getUniqueGift": result = Self.giftJSON
        case "answerWidgetQuery", "editMessageWidgetData", "editSharedWidgetData", "deleteBusinessAccountGift", "verifyUser", "verifyChat":
            result = "true"
        default: throw TelerouteTestNetworkError.unsupportedMethod(operationID)
        }
        return (HTTPResponse(status: .ok), Data("{\"ok\":true,\"result\":\(result)}".utf8))
    }

    static let giftJSON = #"""
    {"gift_id":"gift","base_name":"Gift","name":"Gift-1","number":1,
     "model":{"name":"Model","sticker":{"file_id":"s","file_unique_id":"u","type":"regular","width":1,"height":1,"is_animated":false,"is_video":false},"rarity_per_mille":10},
     "symbol":{"name":"Symbol","sticker":{"file_id":"s","file_unique_id":"u","type":"regular","width":1,"height":1,"is_animated":false,"is_video":false},"rarity_per_mille":20},
     "backdrop":{"name":"Blue","colors":{"center_color":1,"edge_color":2,"symbol_color":3,"text_color":4},"rarity_per_mille":30}}
    """#
}
