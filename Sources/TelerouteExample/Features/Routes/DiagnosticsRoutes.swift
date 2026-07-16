import Teleroute

/// Small reusable diagnostics route collection.
struct DiagnosticsRoutes: TelerouteRouteCollection {
    private let response: String

    init(response: String = "pong") {
        self.response = response
    }

    func addRoutes(to routes: ExampleRoutes) {
        routes.command(
            "ping",
            description: "Check diagnostics connectivity",
            visibility: [.allPrivateChats],
            use: self.ping
        )
    }

    private func ping(_ context: ExampleRequestContext) async throws -> TelerouteResponse {
        .send(self.response)
    }
}
