// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// A button.
public struct RichTextButton: Codable, Hashable, Sendable {
    /// Type of the rich text, always “button”
    public var type: RichTextKind

    private var buttonBox: _IndirectBox<RichMessageButton>
    /// The button
    public var button: RichMessageButton {
        get { self.buttonBox.value }
        set { self.buttonBox = _IndirectBox(newValue) }
    }

    public init(
        type: RichTextKind = .button,
        button: RichMessageButton
    ) {
        self.type = type
        self.buttonBox = _IndirectBox(button)
    }

    public enum CodingKeys: String, CodingKey {
        case type
        case buttonBox = "button"
    }
}
