import Foundation

/// The small hand-shaped pieces the model layer needs: the revision stamp, the
/// indirect box that breaks value-type cycles and bounds struct size, and the
/// one union Telegram never names.
struct SupportEmitter {
    let spec: ApiSpec

    struct File {
        var path: String
        var contents: String
    }

    func render() -> [File] {
        [
            File(path: "Support/BotAPIVersion.swift", contents: self.file(self.version)),
            File(path: "Support/IndirectBox.swift", contents: self.file(self.indirectBox)),
            File(path: "Shared/ChatId.swift", contents: self.file(self.chatId)),
        ]
    }

    private func file(_ body: String) -> String {
        var printer = SwiftPrinter()
        printer.raw(GeneratedFile.header(spec: self.spec))
        printer.raw(body.components(separatedBy: "\n"))
        return printer.text
    }

    private var version: String {
        """
        /// The Telegram Bot API revision these sources were generated from.
        public enum BotAPIVersion {
            /// The Bot API version, e.g. `10.3`.
            public static let version = "\(self.spec.botApiVersion)"
            /// The date Telegram published that version.
            public static let releaseDate = "\(self.spec.botApiDate)"
            /// The documentation page the sources were parsed from.
            public static let source = "https://core.telegram.org/bots/api"
        }
        """
    }

    private var indirectBox: String {
        """
        /// Reference storage for a field that cannot be held inline.
        ///
        /// Two unrelated problems need this. A handful of Telegram objects
        /// contain themselves — a `Message` carries the `Message` it replies to
        /// — which a struct cannot do directly. And a few are simply too big to
        /// copy onto the stack: left inline, `Update` lays out at roughly
        /// 125 KB because it holds seven `Message` fields.
        ///
        /// Only the offending field is boxed, so the rest of the type keeps its
        /// inline storage and its public API is unchanged.
        public final class _IndirectBox<Value>: @unchecked Sendable {
            public let value: Value
            public init(_ value: Value) { self.value = value }
        }

        extension _IndirectBox: Equatable where Value: Equatable {
            public static func == (lhs: _IndirectBox, rhs: _IndirectBox) -> Bool {
                lhs.value == rhs.value
            }
        }

        extension _IndirectBox: Hashable where Value: Hashable {
            public func hash(into hasher: inout Hasher) { hasher.combine(self.value) }
        }

        extension _IndirectBox: Encodable where Value: Encodable {
            public func encode(to encoder: any Encoder) throws {
                try self.value.encode(to: encoder)
            }
        }

        extension _IndirectBox: Decodable where Value: Decodable {
            public convenience init(from decoder: any Decoder) throws {
                self.init(try Value(from: decoder))
            }
        }
        """
    }

    private var chatId: String {
        """
        /// A chat identifier: either a numeric id or an `@username`.
        public enum ChatId: Codable, Hashable, Sendable {
            case case1(Swift.Int64)
            case case2(Swift.String)

            public init(from decoder: any Decoder) throws {
                let container = try decoder.singleValueContainer()
                if let id = try? container.decode(Swift.Int64.self) {
                    self = .case1(id)
                    return
                }
                self = .case2(try container.decode(Swift.String.self))
            }

            public func encode(to encoder: any Encoder) throws {
                var container = encoder.singleValueContainer()
                switch self {
                case let .case1(id): try container.encode(id)
                case let .case2(username): try container.encode(username)
                }
            }
        }
        """
    }
}
