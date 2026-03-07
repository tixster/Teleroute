import Teleroute

/// Typed callback for approving an order from an inline keyboard.
///
/// This demonstrates:
/// - typed callback parameter decoding
/// - callback data generation from the same type
/// - route handlers that live outside the callback value itself
struct ApproveOrderCallback: TelerouteCallback {
    static let path = "orders/{orderID}/approve"

    let orderID: String

    init(orderID: String) {
        self.orderID = orderID
    }

    init(parameters: TelerouteParameters) throws {
        self.orderID = try parameters.require("orderID")
    }

    var parameters: [String: String] {
        ["orderID": self.orderID]
    }
}

/// Typed callback whose handling logic lives on the callback type itself.
///
/// This demonstrates the "self-handling callback" style and shows that typed
/// callbacks can both render their data and fully own their route behavior.
struct ArchiveTicketCallback: TelerouteCallback {
    static let path = "tickets/{ticketID}/archive"

    let ticketID: String

    init(ticketID: String) {
        self.ticketID = ticketID
    }

    init(parameters: TelerouteParameters) throws {
        self.ticketID = try parameters.require("ticketID")
    }

    var parameters: [String: String] {
        ["ticketID": self.ticketID]
    }

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        try await context.answerCallbackQuery(text: "Ticket \(self.ticketID) archived")
        try await context.edit(text: "Ticket \(self.ticketID) archived")
    }
}
