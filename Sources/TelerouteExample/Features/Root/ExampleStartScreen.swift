import Teleroute

/// Precomputed data for the `/start` response.
struct ExampleStartScreen {
    /// The screen depends on registered callback routes, not path strings or
    /// the controller that owns their handlers.
    struct CallbackRoutes: Sendable {
        let support: TelerouteCallbackRoute<SupportCallback>
        let approveOrder: TelerouteCallbackRoute<ApproveOrderCallback>
        let archiveTicket: TelerouteCallbackRoute<ArchiveTicketCallback>
        let adminBan: TelerouteCallbackRoute<AdminBanCallback>
        let payInvoice: TelerouteCallbackRoute<PayInvoiceCallback>
    }

    let text: String
    let replyMarkup: ReplyMarkup

    init<Context: TelerouteRequestContext>(
        routes: TelerouteRouterGroup<Context>,
        callbacks: CallbackRoutes
    ) throws {
        let keyboard = try routes.keyboard([
            [
                callbacks.support.button(SupportCallback(topic: "billing"), "Billing FAQ"),
                callbacks.support.button(SupportCallback(topic: "shipping"), "Shipping FAQ"),
            ],
            [
                callbacks.approveOrder.button(
                    ApproveOrderCallback(orderID: "42"),
                    "Approve order #42",
                    style: "success"
                ),
                callbacks.archiveTicket.button(
                    ArchiveTicketCallback(ticketID: "42"),
                    "Archive ticket #42",
                    style: "danger"
                ),
            ],
            [
                callbacks.approveOrder.button(
                    ApproveOrderCallback(orderID: "43"),
                    "Approve #43",
                    style: "primary"
                ),
                callbacks.archiveTicket.button(
                    ArchiveTicketCallback(ticketID: "43"),
                    "Archive #43",
                    style: "primary"
                ),
            ],
            [
                callbacks.adminBan.button(
                    AdminBanCallback(userID: "99"),
                    "Admin ban #99",
                    style: "danger"
                ),
            ],
            [
                callbacks.payInvoice.button(
                    PayInvoiceCallback(invoiceID: "42"),
                    "Pay invoice #42",
                    style: "success"
                ),
            ],
        ])

        let supportData = try callbacks.support.callbackData(
            for: SupportCallback(topic: "billing")
        )
        let archiveData = try callbacks.archiveTicket.callbackData(
            for: ArchiveTicketCallback(ticketID: "42")
        )

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
        self.replyMarkup = .inline(keyboard)
    }
}
