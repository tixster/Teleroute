import Teleroute

/// Precomputed data for the `/start` response.
///
/// Separating this from route registration keeps the `/start` handler short and
/// makes it easier to see which parts of the start screen are demonstrating:
/// - path-based callback generation
/// - typed callback generation
/// - heterogeneous typed callback rows
/// - grouped callback generation
struct ExampleStartScreen {
    /// Text sent alongside the inline keyboard.
    let text: String
    /// Inline keyboard attached to the start message.
    let replyMarkup: TGReplyMarkup

    init(router: Teleroute, admin: TelerouteGroup) throws {
        let faqRow = try router.callbackButtons([
            ("Billing FAQ", path: "support/{topic}", parameters: ["topic": "billing"]),
            ("Shipping FAQ", path: "support/{topic}", parameters: ["topic": "shipping"]),
        ])

        let primaryActions = [
            try router.callbackButton(
                "Approve order #42",
                callback: ApproveOrderCallback(orderID: "42"),
                style: "success"
            ),
            try router.callbackButton(
                "Archive ticket #42",
                callback: ArchiveTicketCallback(ticketID: "42"),
                style: "danger"
            ),
        ]

        let secondaryCallbacks: [(text: String, callback: any TelerouteCallback)] = [
            ("Approve #43", ApproveOrderCallback(orderID: "43")),
            ("Archive #43", ArchiveTicketCallback(ticketID: "43")),
        ]
        let secondaryRow = try router.callbackButtons(secondaryCallbacks, style: "primary")

        let adminRow = [
            try admin.callbackButton(
                "Admin ban #99",
                path: "users/{userID}/ban",
                parameters: ["userID": "99"],
                style: "danger"
            ),
        ]

        let supportData = try router.callbackData(
            "support/{topic}",
            parameters: ["topic": "billing"]
        )
        let callbackValue: any TelerouteCallback = ArchiveTicketCallback(ticketID: "42")
        let archiveData = try router.callbackData(for: callbackValue)

        let keyboard = router.callbackKeyboard([
            faqRow,
            primaryActions,
            secondaryRow,
            adminRow,
        ])

        self.text = """
        Teleroute example is running.

        Commands:
        /profile <name>
        /signup
        /sync_catalog
        /refresh_menu
        /billing_invoice <id>
        /moderation_audit
        /diag_ping

        Debug callback data:
        support -> \(supportData)
        archive -> \(archiveData)
        """
        self.replyMarkup = .inlineKeyboardMarkup(keyboard)
    }
}
