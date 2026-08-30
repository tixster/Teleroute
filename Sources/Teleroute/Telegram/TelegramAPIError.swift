import Foundation
import OpenAPIRuntime
import TelegramBotAPI

/// Error returned by the Telegram Bot API for a non-success response.
///
/// The OpenAPI specification documents only successful responses, so every
/// API-level failure surfaces as an undocumented response; this type carries
/// the decoded Telegram error payload when one was present.
public struct TelegramAPIError: Error, Sendable, Hashable {
    /// The Telegram Bot API method that failed, e.g. `sendMessage`.
    public let operation: String
    /// HTTP status code of the response.
    public let statusCode: Int
    /// Telegram error code, usually mirroring the HTTP status.
    public let errorCode: Int64?
    /// Human-readable explanation from Telegram.
    public let errorDescription: String?
    /// Seconds to wait before retrying, for flood-limited requests.
    public let retryAfter: Int64?
    /// The supergroup id a group was migrated to, when relevant.
    public let migrateToChatId: Int64?

    public init(
        operation: String,
        statusCode: Int,
        errorCode: Int64? = nil,
        errorDescription: String? = nil,
        retryAfter: Int64? = nil,
        migrateToChatId: Int64? = nil
    ) {
        self.operation = operation
        self.statusCode = statusCode
        self.errorCode = errorCode
        self.errorDescription = errorDescription
        self.retryAfter = retryAfter
        self.migrateToChatId = migrateToChatId
    }
}

extension TelegramAPIError: CustomStringConvertible {
    public var description: String {
        var parts = ["Telegram API error: \(self.operation) failed with status \(self.statusCode)"]
        if let errorDescription = self.errorDescription {
            parts.append(errorDescription)
        }
        if let retryAfter = self.retryAfter {
            parts.append("retry after \(retryAfter)s")
        }
        return parts.joined(separator: " — ")
    }
}

extension TelegramAPIError {
    private static let maximumErrorBodyBytes = 16 * 1024

    /// Builds an error from an undocumented response, decoding Telegram's
    /// error payload when the body carries one.
    static func undocumented(
        operation: String,
        statusCode: Int,
        payload: OpenAPIRuntime.UndocumentedPayload
    ) async -> TelegramAPIError {
        guard let body = payload.body,
              let data = try? await Data(collecting: body, upTo: Self.maximumErrorBodyBytes),
              let decoded = try? JSONDecoder().decode(Components.Schemas._Error.self, from: data) else {
            return TelegramAPIError(operation: operation, statusCode: statusCode)
        }
        return TelegramAPIError(
            operation: operation,
            statusCode: statusCode,
            errorCode: decoded.errorCode,
            errorDescription: decoded.description,
            retryAfter: decoded.parameters?.retryAfter,
            migrateToChatId: decoded.parameters?.migrateToChatId
        )
    }
}
