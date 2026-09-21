import Foundation

/// Finds the wire key that tells a union's variants apart.
///
/// Telegram spells the discriminator out in the variant's own field
/// description, in one of two phrasings: `always “creator”` or
/// `must be *default*` (the second always wrapped in `<em>`, which is what
/// keeps "must be positive" from being mistaken for one).
enum DiscriminatorFinder {
    /// `always “creator”`, with Telegram's typographic quotes.
    private static let alwaysPattern = try! NSRegularExpression(
        pattern: "always [\u{201C}\"]([^\u{201D}\"]+)[\u{201D}\"]"
    )
    /// `must be *default*` — the emphasis is required, so prose like
    /// "must be positive" cannot match.
    private static let mustBePattern = try! NSRegularExpression(
        pattern: "must be \\*([a-z_0-9]+)\\*"
    )

    /// The candidate wire keys, in the order they are tried when two cover the
    /// same number of variants.
    private static let candidateKeys = ["type", "status", "source"]

    struct Outcome {
        var discriminator: ApiUnion.Discriminator?
        /// A key covered every variant but its literals were not pairwise
        /// distinct, so the union must decode by trying each variant instead.
        var demotedForDuplicateValues: Bool
        /// The key and per-variant literals as found, kept even when the union
        /// was demoted. Decoding cannot use them, but the variants' own
        /// discriminator fields still benefit from being typed.
        var found: ApiUnion.Discriminator?
    }

    /// Resolves the discriminator for one union.
    ///
    /// A key is promoted only when it covers **every** variant *and* its values
    /// are pairwise distinct. The distinctness rule is not cosmetic:
    /// `InlineQueryResult` covers all its variants but reuses `audio`,
    /// `document`, `gif`, `mpeg4_gif`, `photo`, `video` and `voice` across its
    /// cached and non-cached forms. Promoting it would emit duplicate Swift
    /// case names and a decoder that silently picked the wrong variant.
    static func find(variants: [String], types: [String: ApiType]) -> Outcome {
        var best: (key: String, values: [(variant: String, value: String)])?
        for key in self.candidateKeys {
            var values: [(variant: String, value: String)] = []
            for variant in variants {
                guard let field = types[variant]?.fields.first(where: { $0.wireName == key }),
                      case .string = field.type,
                      let literal = self.literal(in: field.doc)
                else { continue }
                values.append((variant, literal))
            }
            if best == nil || values.count > best!.values.count {
                best = (key, values)
            }
        }
        guard let best, best.values.count == variants.count else {
            return Outcome(discriminator: nil, demotedForDuplicateValues: false, found: nil)
        }
        let found = ApiUnion.Discriminator(wireKey: best.key, values: best.values)
        guard Set(best.values.map(\.value)).count == best.values.count else {
            return Outcome(discriminator: nil, demotedForDuplicateValues: true, found: found)
        }
        return Outcome(discriminator: found, demotedForDuplicateValues: false, found: found)
    }

    /// The literal a field always carries, mined from its description.
    static func literal(in doc: String) -> String? {
        let range = NSRange(doc.startIndex..., in: doc)
        for pattern in [self.alwaysPattern, self.mustBePattern] {
            guard let match = pattern.firstMatch(in: doc, range: range),
                  match.numberOfRanges > 1,
                  let captured = Range(match.range(at: 1), in: doc)
            else { continue }
            return String(doc[captured])
        }
        return nil
    }
}
