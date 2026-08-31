import Foundation
import HTTPTypes
import OpenAPIRuntime
import Synchronization
import Testing
@_spi(Testing) @testable import Teleroute
@testable import TelegramBotKit

@Suite struct TelegramClientTests {
    @Test func undocumentedErrorResponseMapsToTelegramAPIError() async throws {
        let transport = ScriptedTransport { _, _, operationID in
            #expect(operationID == "sendMessage")
            let body = """
            {
                "ok": false,
                "error_code": 429,
                "description": "Too Many Requests: retry after 14",
                "parameters": {"retry_after": 14}
            }
            """
            var response = HTTPResponse(status: .tooManyRequests)
            response.headerFields[.contentType] = "application/json"
            return (response, HTTPBody(Data(body.utf8)))
        }
        let client = try TelegramBotClient(token: "1:test", transport: transport)

        do {
            _ = try await client.sendMessage(chatId: .id(1), text: "hi")
            Issue.record("Expected TelegramAPIError")
        } catch let error as TelegramAPIError {
            #expect(error.operation == "sendMessage")
            #expect(error.statusCode == 429)
            #expect(error.errorCode == 429)
            #expect(error.errorDescription == "Too Many Requests: retry after 14")
            #expect(error.retryAfter == 14)
        }
    }

    @Test func undocumentedErrorWithoutBodyStillCarriesStatusCode() async throws {
        let transport = ScriptedTransport { _, _, _ in
            (HTTPResponse(status: .badGateway), nil)
        }
        let client = try TelegramBotClient(token: "1:test", transport: transport)

        do {
            _ = try await client.getMe()
            Issue.record("Expected TelegramAPIError")
        } catch let error as TelegramAPIError {
            #expect(error.operation == "getMe")
            #expect(error.statusCode == 502)
            #expect(error.errorCode == nil)
        }
    }

    @Test func longPollingAdvancesOffsetAndStopsOnCancellation() async throws {
        let requests = Mutex<[Int64?]>([])
        let transport = ScriptedTransport { request, body, operationID in
            guard operationID == "getUpdates" else {
                return try ScriptedTransport.okJSON(#"{"ok":true,"result":true}"#)
            }
            let offset = try await Self.bodyValue(body, name: "offset")
            let call = requests.withLock { calls in
                calls.append(offset)
                return calls.count
            }
            switch call {
            case 1:
                return try ScriptedTransport.okJSON(
                    #"{"ok":true,"result":[{"update_id":10},{"update_id":11}]}"#
                )
            default:
                // Quiet long poll until the loop is cancelled.
                try await Task.sleep(for: .seconds(30))
                return try ScriptedTransport.okJSON(#"{"ok":true,"result":[]}"#)
            }
        }

        let received = Mutex<[Int64]>([])
        let connection = TelegramLongPollingConnection(
            client: try TelegramBotClient(token: "1:test", transport: transport),
            configuration: .init(deleteWebhookOnStart: false),
            resolvedAllowedUpdates: nil,
            logger: .init(label: "tests.polling")
        )
        let task = Task {
            await connection.run { updates in
                received.withLock { $0.append(contentsOf: updates.map { $0.updateId }) }
            }
        }

        // Wait until the first batch is consumed and the second poll started.
        for _ in 0..<200 {
            if requests.withLock({ $0.count }) >= 2 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        task.cancel()
        await task.value

        #expect(received.withLock { $0 } == [10, 11])
        let offsets = requests.withLock { $0 }
        #expect(offsets.first == .some(nil))
        #expect(offsets.dropFirst().first == 12)
    }

    @Test func longPollingRetriesAfterFailure() async throws {
        let calls = Mutex(0)
        let transport = ScriptedTransport { _, _, operationID in
            guard operationID == "getUpdates" else {
                return try ScriptedTransport.okJSON(#"{"ok":true,"result":true}"#)
            }
            let call = calls.withLock { count in
                count += 1
                return count
            }
            switch call {
            case 1:
                throw TelerouteTestScriptError.simulatedOutage
            default:
                try await Task.sleep(for: .seconds(30))
                return try ScriptedTransport.okJSON(#"{"ok":true,"result":[]}"#)
            }
        }

        let connection = TelegramLongPollingConnection(
            client: try TelegramBotClient(token: "1:test", transport: transport),
            configuration: .init(
                deleteWebhookOnStart: false,
                initialBackoff: .milliseconds(10),
                maximumBackoff: .milliseconds(20)
            ),
            resolvedAllowedUpdates: nil,
            logger: .init(label: "tests.polling.retry")
        )
        let task = Task {
            await connection.run { _ in }
        }

        // The loop must survive the failure and issue another poll.
        for _ in 0..<200 {
            if calls.withLock({ $0 }) >= 2 { break }
            try await Task.sleep(for: .milliseconds(10))
        }
        #expect(calls.withLock { $0 } >= 2)
        task.cancel()
        await task.value
    }

    @Test func tokenBucketEnforcesSustainedRate() async throws {
        // Burst of 1, 100 tokens/s: 4 extra acquisitions need >= ~40ms.
        let bucket = TelegramTokenBucket(ratePerSecond: 100, capacity: 1)
        let clock = ContinuousClock()
        let elapsed = try await clock.measure {
            for _ in 0..<5 {
                try await bucket.acquire()
            }
        }
        #expect(elapsed >= .milliseconds(35))
    }

    @Test func chatIdHelpersRoundTrip() {
        #expect(ChatId.id(42).int64Value == 42)
        #expect(ChatId.username("@channel").int64Value == nil)
    }

    @Test func maybeInaccessibleMessageTreatsZeroDateAsInaccessible() throws {
        let chat = Chat(id: 1, _type: ChatType.private.rawValue)
        let accessible = Message(messageId: 1, date: 100, chat: chat)
        let inaccessible = Message(messageId: 2, date: 0, chat: chat)

        #expect(MaybeInaccessibleMessage.Message(accessible).accessibleMessage?.messageId == 1)
        #expect(MaybeInaccessibleMessage.Message(inaccessible).accessibleMessage == nil)
        #expect(MaybeInaccessibleMessage.Message(inaccessible).chat.id == 1)
    }

    private static func bodyValue(_ body: HTTPBody?, name: String) async throws -> Int64? {
        guard let body else { return nil }
        let data = try await Data(collecting: body, upTo: 1024 * 1024)
        let json = try JSONSerialization.jsonObject(with: data) as? [String: Any]
        return (json?[name] as? NSNumber)?.int64Value
    }
}

private enum TelerouteTestScriptError: Error {
    case simulatedOutage
}

private struct ScriptedTransport: ClientTransport {
    let handler: @Sendable (
        HTTPRequest, HTTPBody?, String
    ) async throws -> (HTTPResponse, HTTPBody?)

    init(
        handler: @escaping @Sendable (
            HTTPRequest, HTTPBody?, String
        ) async throws -> (HTTPResponse, HTTPBody?)
    ) {
        self.handler = handler
    }

    func send(
        _ request: HTTPRequest,
        body: HTTPBody?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, HTTPBody?) {
        try await self.handler(request, body, operationID)
    }

    static func okJSON(_ json: String) throws -> (HTTPResponse, HTTPBody?) {
        var response = HTTPResponse(status: .ok)
        response.headerFields[.contentType] = "application/json"
        return (response, HTTPBody(Data(json.utf8)))
    }
}
