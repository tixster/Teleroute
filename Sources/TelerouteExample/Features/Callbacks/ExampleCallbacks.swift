import Teleroute

/// Typed callback for approving an order from an inline keyboard.
///
/// This demonstrates:
/// - typed callback parameter decoding
/// - callback data generation from the same type
/// - opt-in behavior owned by the decoded callback value
struct ApproveOrderCallback: TelerouteHandlingCallback {
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

    typealias Context = ExampleRequestContext

    func handle(context: ExampleRequestContext) async throws -> TelerouteResponse {
        .sequence([
            .answerCallback("Order \(self.orderID) approved"),
            .edit("Order \(self.orderID) approved"),
        ])
    }
}

/// Another typed callback used in a heterogeneous keyboard row.
struct ArchiveTicketCallback: TelerouteHandlingCallback {
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

    typealias Context = ExampleRequestContext

    func handle(context: ExampleRequestContext) async throws -> TelerouteResponse {
        .sequence([
            .answerCallback("Ticket \(self.ticketID) archived"),
            .edit("Ticket \(self.ticketID) archived"),
        ])
    }
}

/// Data-only callback handled by the root controller.
struct SupportCallback: TelerouteCallback {
    static let path = "support/{topic}"

    let topic: String

    init(topic: String) {
        self.topic = topic
    }

    init(parameters: TelerouteParameters) throws {
        self.topic = try parameters.require("topic")
    }

    var parameters: [String: String] {
        ["topic": self.topic]
    }
}

/// Data-only callback mounted into the admin route scope.
struct AdminBanCallback: TelerouteCallback {
    static let path = "users/{userID}/ban"

    let userID: String

    init(userID: String) {
        self.userID = userID
    }

    init(parameters: TelerouteParameters) throws {
        self.userID = try parameters.require("userID")
    }

    var parameters: [String: String] {
        ["userID": self.userID]
    }
}
