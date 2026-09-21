import Foundation
import HTTPTypes
import Synchronization
import Testing
@_spi(Testing) @testable import Teleroute
@testable import TelegramBotKit
import TelerouteTestSupport

/// Wire-level tests for the generated flat client wrappers.
///
/// The client sends JSON unless a call actually uploads bytes, so these cover
/// both sides of that one rule: the JSON body every ordinary call produces, and
/// the multipart body an upload produces.
@Suite struct TelegramWrapperTests {
    @Test func formerQueryOperationsPostJSONBodies() async throws {
        let capture = CapturingTransport(respond: { _, _ in
            try CapturingTransport.okJSON(#"{"ok":true,"result":{"status":"member","user":{"id":7,"is_bot":false,"first_name":"U"}}}"#)
        })
        let client = try TelegramBotClient(token: "1:test", transport: capture)
        let member = try await client.getChatMember(chatId: .id(42), userId: 7)
        guard case .member = member else {
            Issue.record("Expected .member, got \(member)")
            return
        }
        let (request, body) = capture.captured.withLock { ($0!.request, $0!.body) }
        // Telegram ignores non-JSON query serialization of arrays/objects, so
        // every former GET operation posts a JSON body instead.
        #expect(request.method == .post)
        #expect(request.path?.contains("getChatMember") == true)
        let json = try JSONSerialization.jsonObject(with: body) as! [String: Any]
        #expect(json["chat_id"] as? Int == 42)
        #expect(json["user_id"] as? Int == 7)
    }

    @Test func jsonTemplateEncodesFullOptionSet() async throws {
        let capture = CapturingTransport(respond: { _, _ in
            try CapturingTransport.okJSON(Self.messageResultJSON)
        })
        let client = try TelegramBotClient(token: "1:test", transport: capture)
        try await client.sendMessage(
            chatId: .username("@channel"),
            text: "hi",
            messageThreadId: 5,
            parseMode: .html,
            linkPreviewOptions: .init(isDisabled: true),
            disableNotification: true,
            replyParameters: .init(messageId: 99),
            replyMarkup: .remove()
        )
        let body = capture.captured.withLock { $0!.body }
        let json = try JSONSerialization.jsonObject(with: body) as! [String: Any]
        #expect(json["chat_id"] as? String == "@channel")
        #expect(json["text"] as? String == "hi")
        #expect(json["message_thread_id"] as? Int == 5)
        #expect(json["parse_mode"] as? String == "HTML")
        #expect((json["link_preview_options"] as? [String: Any])?["is_disabled"] as? Bool == true)
        #expect(json["disable_notification"] as? Bool == true)
        #expect((json["reply_parameters"] as? [String: Any])?["message_id"] as? Int == 99)
        #expect((json["reply_markup"] as? [String: Any])?["remove_keyboard"] as? Bool == true)
    }

    @Test func multipartTemplateSendsUploadWithFilename() async throws {
        let capture = CapturingTransport(respond: { _, _ in
            try CapturingTransport.okJSON(Self.messageResultJSON)
        })
        let client = try TelegramBotClient(token: "1:test", transport: capture)
        let payload = Data("PNG-BYTES".utf8)
        try await client.sendPhoto(
            chatId: .id(1),
            photo: .upload(filename: "pic.png", data: payload),
            caption: "cap",
            parseMode: .markdownV2
        )
        let (request, body) = capture.captured.withLock { ($0!.request, $0!.body) }
        let parts = try TelerouteTestMultipart.parts(
            from: body,
            contentType: request.headerFields[.contentType] ?? ""
        )
        #expect(String(decoding: parts["chat_id"]!.body, as: UTF8.self) == "1")
        #expect(parts["photo"]?.body == payload)
        #expect(parts["photo"]?.filename == "pic.png")
        #expect(String(decoding: parts["caption"]!.body, as: UTF8.self) == "cap")
        #expect(String(decoding: parts["parse_mode"]!.body, as: UTF8.self) == "MarkdownV2")
    }

    @Test func fileIDArgumentGoesAsJSONWhenNothingIsUploaded() async throws {
        let capture = CapturingTransport(respond: { _, _ in
            try CapturingTransport.okJSON(Self.messageResultJSON)
        })
        let client = try TelegramBotClient(token: "1:test", transport: capture)
        try await client.sendPhoto(chatId: .id(1), photo: .fileID("AgAC-file"))
        let (request, body) = capture.captured.withLock { ($0!.request, $0!.body) }
        // No bytes to upload, so multipart buys nothing and the file reference
        // travels as an ordinary JSON string.
        #expect(request.headerFields[.contentType] == "application/json")
        let json = try JSONSerialization.jsonObject(with: body) as! [String: Any]
        #expect(json["photo"] as? String == "AgAC-file")
        #expect(json["chat_id"] as? Int == 1)
    }

    @Test func fileIDBecomesATextPartAlongsideAnUpload() async throws {
        let capture = CapturingTransport(respond: { _, _ in
            try CapturingTransport.okJSON(Self.messageResultJSON)
        })
        let client = try TelegramBotClient(token: "1:test", transport: capture)
        try await client.sendAudio(
            chatId: .id(1),
            audio: .upload(filename: "song.mp3", data: Data("MP3".utf8)),
            thumbnail: .fileID("AgAC-thumb")
        )
        let (request, body) = capture.captured.withLock { ($0!.request, $0!.body) }
        let parts = try TelerouteTestMultipart.parts(
            from: body,
            contentType: request.headerFields[.contentType] ?? ""
        )
        #expect(String(decoding: parts["thumbnail"]!.body, as: UTF8.self) == "AgAC-thumb")
        #expect(parts["thumbnail"]?.filename == nil)
        #expect(parts["audio"]?.filename == "song.mp3")
    }

    @Test func arrayFieldIsAJSONArrayInAJSONBody() async throws {
        let capture = CapturingTransport(respond: { _, _ in
            try CapturingTransport.okJSON(Self.messageResultJSON)
        })
        let client = try TelegramBotClient(token: "1:test", transport: capture)
        try await client.sendPoll(
            chatId: .id(1),
            question: "Best color?",
            options: [.init(text: "Red"), .init(text: "Blue")]
        )
        let (request, body) = capture.captured.withLock { ($0!.request, $0!.body) }
        #expect(request.headerFields[.contentType] == "application/json")
        let json = try JSONSerialization.jsonObject(with: body) as! [String: Any]
        let options = json["options"] as! [[String: Any]]
        #expect(options.map { $0["text"] as? String } == ["Red", "Blue"])
        #expect(json["question"] as? String == "Best color?")
    }

    @Test func arrayFieldIsOneJSONPartWhenUploading() async throws {
        let capture = CapturingTransport(respond: { _, _ in
            try CapturingTransport.okJSON(Self.messageResultJSON)
        })
        let client = try TelegramBotClient(token: "1:test", transport: capture)
        try await client.sendPhoto(
            chatId: .id(1),
            photo: .upload(filename: "pic.png", data: Data("PNG".utf8)),
            caption: "hi",
            captionEntities: [.init(type: .bold, offset: 0, length: 2)]
        )
        let (request, body) = capture.captured.withLock { ($0!.request, $0!.body) }
        let parts = try TelerouteTestMultipart.parts(
            from: body,
            contentType: request.headerFields[.contentType] ?? ""
        )
        // Telegram rejects repeated parts, so an array becomes one JSON part.
        let entities = try JSONSerialization.jsonObject(
            with: parts["caption_entities"]!.body
        ) as! [[String: Any]]
        #expect(entities.first?["type"] as? String == "bold")
    }

    @Test func answerInlineQuerySendsResultsAsAJSONArray() async throws {
        let capture = CapturingTransport(respond: { _, _ in
            try CapturingTransport.okJSON(#"{"ok":true,"result":true}"#)
        })
        let client = try TelegramBotClient(token: "1:test", transport: capture)
        try await client.answerInlineQuery(
            inlineQueryId: "iq1",
            results: [
                .InlineQueryResultArticle(.init(                    id: "1",
                    title: "Hello",
                    inputMessageContent: .InputTextMessageContent(.init(messageText: "hi"))
                )),
            ]
        )
        let (request, body) = capture.captured.withLock { ($0!.request, $0!.body) }
        #expect(request.headerFields[.contentType] == "application/json")
        let json = try JSONSerialization.jsonObject(with: body) as! [String: Any]
        let results = json["results"] as! [[String: Any]]
        #expect(results.first?["type"] as? String == "article")
        #expect(results.first?["title"] as? String == "Hello")
    }

    @Test func floodWaitMiddlewareRetriesAfter429() async throws {
        let calls = Mutex(0)
        let transport = ScriptedFloodTransport { operationID in
            let attempt = calls.withLock { count in
                count += 1
                return count
            }
            if attempt == 1 {
                var response = HTTPResponse(status: .tooManyRequests)
                response.headerFields[.contentType] = "application/json"
                let body = #"{"ok":false,"error_code":429,"description":"flood","parameters":{"retry_after":0}}"#
                return (response, Data(body.utf8))
            }
            var response = HTTPResponse(status: .ok)
            response.headerFields[.contentType] = "application/json"
            return (response, Data(#"{"ok":true,"result":true}"#.utf8))
        }
        let client = try TelegramBotClient(
            token: "1:test",
            transport: transport,
            middlewares: [TelegramFloodWaitRetryMiddleware(policy: .init(maxRetries: 2))]
        )
        let result = try await client.deleteMessage(chatId: .id(1), messageId: 2)
        #expect(result == true)
        #expect(calls.withLock { $0 } == 2)
    }

    @Test func sendPacerSpacesSameChatSends() async throws {
        let pacer = TelegramSendPacer(pacing: .init(
            perChatInterval: .milliseconds(30),
            perGroupInterval: .milliseconds(30)
        ))
        let clock = ContinuousClock()
        let elapsed = try await clock.measure {
            try await pacer.acquire(chatId: .id(1))
            try await pacer.acquire(chatId: .id(1))
            try await pacer.acquire(chatId: .id(1))
        }
        #expect(elapsed >= .milliseconds(55))

        let independent = try await clock.measure {
            try await pacer.acquire(chatId: .id(2))
        }
        #expect(independent < .milliseconds(25))
    }

    private static let messageResultJSON = #"""
    {"ok":true,"result":{"message_id":10,"date":1,"chat":{"id":1,"type":"private"},"text":"hi"}}
    """#
}

/// Captures the last request + collected body while serving a scripted response.
private final class CapturingTransport: TelegramTransport, @unchecked Sendable {
    struct Captured {
        let request: HTTPRequest
        let body: Data
    }

    let captured = Mutex<Captured?>(nil)
    private let respond: @Sendable (HTTPRequest, Data) throws -> (HTTPResponse, Data)

    init(respond: @escaping @Sendable (HTTPRequest, Data) throws -> (HTTPResponse, Data)) {
        self.respond = respond
    }

    func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        let data = body ?? Data()
        self.captured.withLock { $0 = Captured(request: request, body: data) }
        return try self.respond(request, data)
    }

    static func okJSON(_ json: String) throws -> (HTTPResponse, Data) {
        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"
        return (response, Data(json.utf8))
    }
}

private struct ScriptedFloodTransport: TelegramTransport {
    let respond: @Sendable (String) -> (HTTPResponse, Data)

    func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        self.respond(operationID)
    }
}
