import Foundation
import TelegramBotAPI

/// Telegram's uniform response envelope.
///
/// Every Bot API response is `{"ok": true, "result": …}` or `{"ok": false,
/// "error_code": …, "description": …}`, so a failure is just a field in the
/// same envelope rather than a separate error shape to reconstruct.
struct TelegramEnvelope<Result: Decodable>: Decodable {
    var ok: Bool
    var result: Result?
    var errorCode: Int64?
    var description: String?
    var parameters: ResponseParameters?

    enum CodingKeys: String, CodingKey {
        case ok
        case result
        case errorCode = "error_code"
        case description
        case parameters
    }
}

/// The error half of the envelope, decoded on its own when the result type is
/// unknown or the body is a failure.
struct TelegramErrorEnvelope: Decodable {
    var ok: Bool
    var errorCode: Int64?
    var description: String?
    var parameters: ResponseParameters?

    enum CodingKeys: String, CodingKey {
        case ok
        case errorCode = "error_code"
        case description
        case parameters
    }
}

/// The `Message | True` result the `editMessage*` family returns: a `Message`
/// for a normal message, `true` for an inline one.
enum TelegramMessageOrFlag: Decodable {
    case message(Message)
    case flag(Bool)

    init(from decoder: any Decoder) throws {
        let container = try decoder.singleValueContainer()
        if let flag = try? container.decode(Bool.self) {
            self = .flag(flag)
            return
        }
        self = .message(try container.decode(Message.self))
    }

    var message: Message? {
        if case let .message(message) = self { return message }
        return nil
    }
}
