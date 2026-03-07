import Teleroute

/// Collection demonstrating the plain `TelerouteCollection` protocol.
///
/// Unlike `TelerouteCollectionBuilder`, this variant boots directly with a raw
/// `TelerouteGroup`. Use this when a feature does not need the collection-specific
/// wrapper API.
struct DiagnosticsCollection: TelerouteCollection {
    func boot(routes: TelerouteGroup) {
        routes.group("diag") { diagnostics in
            diagnostics.command(
                "ping",
                description: "Check diagnostics connectivity",
                visibility: [.allPrivateChats]
            ) { _, context in
                try await context.send(text: "pong")
            }
        }
    }
}
