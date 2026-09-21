import Foundation

/// Writes the parsed documentation as JSON.
///
/// This exists to be diffed. While the previous pipeline's
/// `openapi/telegram-bot-api.patched.json` is still in the tree it is the best
/// oracle available for "did the parser read the documentation correctly", and
/// a flat JSON dump is what makes that comparison mechanical.
enum IRDump {
    static func write(spec: ApiSpec, to url: URL) throws {
        let object: [String: Any] = [
            "botApiVersion": spec.botApiVersion,
            "botApiDate": spec.botApiDate,
            "sha256": spec.sourceSHA256,
            "types": spec.types.map { self.encode($0, indirect: spec.indirectUnions) },
            "methods": spec.methods.map(self.encode),
        ]
        let data = try JSONSerialization.data(
            withJSONObject: object,
            options: [.prettyPrinted, .sortedKeys, .withoutEscapingSlashes]
        )
        try data.write(to: url)
    }

    private static func encode(_ type: ApiType, indirect: Set<String>) -> [String: Any] {
        var object: [String: Any] = ["name": type.name, "section": type.section]
        switch type.shape {
        case let .object(fields):
            object["kind"] = "object"
            object["fields"] = fields.map(self.encode)
        case let .union(union):
            object["kind"] = "union"
            object["variants"] = union.variants
            object["extraAlternatives"] = union.extraAlternatives.map(\.swiftTypeName)
            object["indirect"] = indirect.contains(type.name)
            if let discriminator = union.discriminator {
                object["discriminator"] = [
                    "key": discriminator.wireKey,
                    "values": discriminator.values.map { [$0.variant, $0.value] },
                ]
            }
        case .empty:
            object["kind"] = "empty"
        }
        return object
    }

    private static func encode(_ field: ApiField) -> [String: Any] {
        var object: [String: Any] = [
            "wire": field.wireName,
            "swift": field.swiftName,
            "type": field.type.swiftTypeName,
            "optional": field.isOptional,
        ]
        if field.needsBoxing { object["boxed"] = true }
        if let constant = field.constantValue { object["constant"] = constant }
        return object
    }

    private static func encode(_ method: ApiMethod) -> [String: Any] {
        [
            "name": method.name,
            "group": method.group,
            "returns": method.returnType.swiftTypeName,
            "parameters": method.parameters.map { parameter in
                var object = self.encode(parameter.field)
                if parameter.sugar != .none { object["sugar"] = "\(parameter.sugar)" }
                return object
            },
        ]
    }
}
