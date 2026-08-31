import Foundation

/// Text formatting helpers for Telegram parse modes.
public enum TelegramText {
    /// Escapes the characters HTML parse mode treats specially.
    public static func escapeHTML(_ text: String) -> String {
        text
            .replacingOccurrences(of: "&", with: "&amp;")
            .replacingOccurrences(of: "<", with: "&lt;")
            .replacingOccurrences(of: ">", with: "&gt;")
    }

    /// Escapes every character MarkdownV2 treats specially.
    public static func escapeMarkdownV2(_ text: String) -> String {
        let special: Set<Character> = [
            "_", "*", "[", "]", "(", ")", "~", "`", ">", "#",
            "+", "-", "=", "|", "{", "}", ".", "!", "\\",
        ]
        var escaped = ""
        escaped.reserveCapacity(text.count)
        for character in text {
            if special.contains(character) {
                escaped.append("\\")
            }
            escaped.append(character)
        }
        return escaped
    }

    // MARK: HTML fragment builders (escape their content)

    public static func bold(_ text: String) -> String {
        "<b>\(self.escapeHTML(text))</b>"
    }

    public static func italic(_ text: String) -> String {
        "<i>\(self.escapeHTML(text))</i>"
    }

    public static func code(_ text: String) -> String {
        "<code>\(self.escapeHTML(text))</code>"
    }

    public static func pre(_ text: String, language: String? = nil) -> String {
        if let language {
            return "<pre><code class=\"language-\(language)\">\(self.escapeHTML(text))</code></pre>"
        }
        return "<pre>\(self.escapeHTML(text))</pre>"
    }

    public static func link(_ text: String, _ url: String) -> String {
        "<a href=\"\(self.escapeHTML(url))\">\(self.escapeHTML(text))</a>"
    }

    public static func mention(_ text: String, userId: Int64) -> String {
        self.link(text, "tg://user?id=\(userId)")
    }

    public static func spoiler(_ text: String) -> String {
        "<tg-spoiler>\(self.escapeHTML(text))</tg-spoiler>"
    }
}
