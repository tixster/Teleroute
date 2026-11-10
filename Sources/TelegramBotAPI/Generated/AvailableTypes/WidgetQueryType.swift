// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.4 (November 9, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object describes the type of a query from a widget. Currently, it can be one of
public enum WidgetQueryType: Codable, Hashable, Sendable {
    case data(WidgetQueryTypeData)
    case signData(WidgetQueryTypeSignData)
    case sentTransaction(WidgetQueryTypeSentTransaction)

    public enum CodingKeys: String, CodingKey {
        case type
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        switch try container.decode(Swift.String.self, forKey: .type) {
        case "data":
            self = .data(try WidgetQueryTypeData(from: decoder))
        case "sign_data":
            self = .signData(try WidgetQueryTypeSignData(from: decoder))
        case "sent_transaction":
            self = .sentTransaction(try WidgetQueryTypeSentTransaction(from: decoder))
        case let other:
            throw DecodingError.dataCorruptedError(
                forKey: .type, in: container,
                debugDescription: "unknown WidgetQueryType type '\(other)'")
        }
    }

    public func encode(to encoder: any Encoder) throws {
        switch self {
        case let .data(value):
            try value.encode(to: encoder)
        case let .signData(value):
            try value.encode(to: encoder)
        case let .sentTransaction(value):
            try value.encode(to: encoder)
        }
    }
}
