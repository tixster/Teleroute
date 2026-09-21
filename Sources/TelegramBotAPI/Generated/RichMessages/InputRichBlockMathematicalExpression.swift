// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A block with a mathematical expression in LaTeX format, corresponding to the custom HTML tag
/// `<tg-math-block>`.
public struct InputRichBlockMathematicalExpression: Codable, Hashable, Sendable {
    /// Type of the block, always “mathematical_expression”
    public var type: RichBlockKind

    /// The mathematical expression in LaTeX format
    public var expression: Swift.String

    public init(
        type: RichBlockKind = .mathematicalExpression,
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
