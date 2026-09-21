import AsyncHTTPClient
import Foundation
import HTTPTypes
import NIOCore
import NIOHTTP1

/// The default ``TelegramTransport``, over AsyncHTTPClient.
public struct AsyncHTTPClientTelegramTransport: TelegramTransport {
    /// Per-request timeout.
    ///
    /// It has to sit above the long-polling wait, or `getUpdates` gets cut off
    /// by the HTTP client before Telegram answers.
    public var timeout: Duration
    /// Largest response accepted, to bound memory on a hostile or broken server.
    public var maximumResponseBytes: Int
    private let client: HTTPClient

    /// - Parameters:
    ///   - client: HTTP client to use; the shared one by default, which needs
    ///     no lifecycle management from callers.
    ///   - timeout: Per-request timeout.
    ///   - maximumResponseBytes: Largest response accepted.
    public init(
        client: HTTPClient = .shared,
        timeout: Duration = .seconds(70),
        maximumResponseBytes: Int = 32 * 1024 * 1024
    ) {
        self.client = client
        self.timeout = timeout
        self.maximumResponseBytes = maximumResponseBytes
    }

    public func send(
        _ request: HTTPRequest,
        body: Data?,
        baseURL: URL,
        operationID: String
    ) async throws -> (HTTPResponse, Data) {
        var clientRequest = HTTPClientRequest(
            url: baseURL.appendingPathComponent(request.path ?? "").absoluteString
        )
        clientRequest.method = HTTPMethod(rawValue: request.method.rawValue)
        for field in request.headerFields {
            clientRequest.headers.add(name: field.name.rawName, value: field.value)
        }
        if let body {
            clientRequest.body = .bytes(ByteBuffer(bytes: body))
        }

        let response = try await self.client.execute(
            clientRequest,
            timeout: .nanoseconds(
                self.timeout.components.seconds * 1_000_000_000
                    + self.timeout.components.attoseconds / 1_000_000_000
            )
        )
        let buffer = try await response.body.collect(upTo: self.maximumResponseBytes)

        var fields = HTTPFields()
        for header in response.headers {
            guard let name = HTTPField.Name(header.name) else { continue }
            fields[name] = header.value
        }
        return (
            HTTPResponse(status: .init(code: Int(response.status.code)), headerFields: fields),
            Data(buffer.readableBytesView)
        )
    }
}
