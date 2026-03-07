import Teleroute

/// Group-owning collection that declares its own path.
///
/// Mounting this collection with `router.group(ModerationCollection())` produces
/// routes like `/moderation_audit` without repeating the `"moderation"` prefix
/// in the main router configuration.
struct ModerationCollection: TelerouteGroupCollection {
    let path = "moderation"

    func boot(collection: TelerouteCollectionGroup) {
        collection.command(
            "audit",
            description: "Show moderation diagnostics",
            visibility: [.allChatAdministrators]
        ) { _, context in
            try await context.reply(text: "Moderation audit ready.")
        }
    }
}
