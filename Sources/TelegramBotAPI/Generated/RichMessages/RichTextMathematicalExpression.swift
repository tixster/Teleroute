// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A mathematical expression.
public struct RichTextMathematicalExpression: Codable, Hashable, Sendable {
    /// Type of the rich text, always “mathematical_expression”
    public var type: RichTextKind

    /// The expression in LaTeX format
    public var expression: Swift.String

    public init(
        type: RichTextKind = .mathematicalExpression,
        expression: Swift.String
    ) {
        self.type = type
        self.expression = expression
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case expression
    }
}
