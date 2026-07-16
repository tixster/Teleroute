import Teleroute

/// Small reusable diagnostics module.
struct DiagnosticsModule: TelerouteModule {
    private let response: String

    init(response: String = "pong") {
        self.response = response
    }

    func register(in routes: TelerouteRoutes) {
        routes.command(
            "ping",
            description: "Check diagnostics connectivity",
            visibility: [.allPrivateChats],
            use: self.ping
        )
    }

    private func ping(_ context: TelerouteContext) async throws {
        try await context.send(self.response)
    }
}
