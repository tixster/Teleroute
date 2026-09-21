import Foundation
import HTTPTypes
import TelegramBotAPI

/// Turns a ``TelegramRequest`` into an HTTP body.
///
/// Telegram accepts a JSON body for every method, so JSON is the default and
/// multipart is used only when the call actually carries bytes to upload. That
/// keeps `editMessageText`, `sendPoll` and `answerInlineQuery` — which have no
/// file parameter at all — off the multipart path, and avoids the string
/// coercion multipart otherwise forces on `chat_id` and every boolean.
enum TelegramRequestEncoder {
    struct Encoded {
        var contentType: String
        var body: Data
    }

    static func encode(_ request: TelegramRequest) throws -> Encoded {
        if request.needsMultipart {
            let boundary = self.makeBoundary()
            return Encoded(
                contentType: "multipart/form-data; boundary=\(boundary)",
                body: try self.multipartBody(request, boundary: boundary)
            )
        }
        let encoder = JSONEncoder()
        return Encoded(
            contentType: "application/json",
            body: try encoder.encode(JSONBody(fields: request.fields))
        )
    }

    // MARK: - JSON

    private struct JSONBody: Encodable {
        let fields: [TelegramRequest.Field]

        func encode(to encoder: any Encoder) throws {
            var container = encoder.container(keyedBy: TelegramCodingKey.self)
            for field in self.fields {
                let key = TelegramCodingKey(field.name)
                switch field.value {
                case let .string(value): try container.encode(value, forKey: key)
                case let .integer(value): try container.encode(value, forKey: key)
                case let .boolean(value): try container.encode(value, forKey: key)
                case let .double(value): try container.encode(value, forKey: key)
                case let .chatId(value): try container.encode(value, forKey: key)
                case let .json(value): try container.encode(AnyEncodable(value), forKey: key)
                case let .file(input):
                    // Reaching JSON means no part of the request uploads bytes,
                    // so every file argument is a file_id or a URL.
                    try container.encode(input.stringValue ?? "", forKey: key)
                }
            }
        }
    }

    // MARK: - Multipart

    /// A boundary that cannot collide with the payload: a fixed marker plus 128
    /// random bits. Random per request, never per generation run, so generated
    /// sources stay reproducible.
    private static func makeBoundary() -> String {
        let bytes = (0..<16).map { _ in UInt8.random(in: .min ... .max) }
        return "Teleroute-" + bytes.map { String(format: "%02x", $0) }.joined()
    }

    private static func multipartBody(_ request: TelegramRequest, boundary: String) throws -> Data {
        var body = Data()
        for field in request.fields {
            body.append(Data("--\(boundary)\r\n".utf8))
            switch field.value {
            case let .file(.upload(filename, data)):
                let safe = self.sanitize(filename)
                body.append(
                    Data(
                        """
                        Content-Disposition: form-data; name="\(field.name)"; filename="\(safe)"\r
                        Content-Type: application/octet-stream\r
                        \r

                        """.utf8
                    )
                )
                body.append(data)
            case let .json(value):
                // Telegram rejects repeated parts for array-valued fields, so
                // objects and arrays go as a single JSON-serialised part.
                body.append(self.textHeader(field.name))
                body.append(try JSONEncoder().encode(AnyEncodable(value)))
            default:
                body.append(self.textHeader(field.name))
                body.append(Data(self.text(for: field.value).utf8))
            }
            body.append(Data("\r\n".utf8))
        }
        body.append(Data("--\(boundary)--\r\n".utf8))
        return body
    }

    private static func textHeader(_ name: String) -> Data {
        Data("Content-Disposition: form-data; name=\"\(name)\"\r\n\r\n".utf8)
    }

    private static func text(for value: TelegramRequest.Value) -> String {
        switch value {
        case let .string(value): value
        case let .integer(value): String(value)
        case let .boolean(value): value ? "true" : "false"
        case let .double(value): String(value)
        case let .chatId(value):
            switch value {
            case let .case1(id): String(id)
            case let .case2(username): username
            }
        case let .file(input): input.stringValue ?? ""
        case .json: ""
        }
    }

    /// A filename cannot carry a quote or a newline without breaking the part
    /// header it is embedded in.
    private static func sanitize(_ filename: String) -> String {
        filename.filter { $0 != "\"" && $0 != "\r" && $0 != "\n" }
    }
}
