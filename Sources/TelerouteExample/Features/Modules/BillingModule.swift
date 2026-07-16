import Teleroute
import TelerouteMacros

/// Reusable feature module with nested command and callback routes.
///
/// The module owns its route declarations and handler methods without exposing
/// either to the top-level app configuration.
struct BillingModule: TelerouteModule {
    struct Routes: Sendable {
        let pay: TelerouteCallbackRoute<PayInvoiceCallback>
        let fail: TelerouteCallbackRoute<FailInvoiceCallback>
    }

    func register(in routes: TelerouteRoutes) -> Routes {
        let callbacks = Routes(
            pay: routes.callback(PayInvoiceCallback.self, use: self.markInvoicePaid),
            fail: routes.callback(FailInvoiceCallback.self, use: self.markInvoiceFailed)
        )

        routes.command(
            "invoice",
            description: "Open an invoice",
            visibility: [.allPrivateChats]
        ) { context in
            try await self.openInvoice(context, routes: routes, callbacks: callbacks)
        }

        return callbacks
    }

    private func openInvoice(
        _ context: TelerouteContext,
        routes: TelerouteRoutes,
        callbacks: Routes
    ) async throws {
        let invoiceID = context.command?.get("invoiceID") ?? "unknown"
        let keyboard = try routes.keyboard([[
            callbacks.pay.button(PayInvoiceCallback(invoiceID: invoiceID), "Mark paid"),
            callbacks.fail.button(FailInvoiceCallback(invoiceID: invoiceID), "Mark failed"),
        ]])

        try await context.reply(
            "Invoice \(invoiceID)",
            replyMarkup: .inlineKeyboardMarkup(keyboard)
        )
    }

    private func markInvoicePaid(
        _ callback: PayInvoiceCallback,
        _ context: TelerouteContext
    ) async throws {
        try await context.answerCallbackQuery("Invoice \(callback.invoiceID) paid")
        try await context.edit("Invoice \(callback.invoiceID) paid")
    }

    private func markInvoiceFailed(
        _ callback: FailInvoiceCallback,
        _ context: TelerouteContext
    ) async throws {
        try await context.answerCallbackQuery("Invoice \(callback.invoiceID) failed")
        try await context.edit("Invoice \(callback.invoiceID) failed")
    }
}

@TelerouteCallback("invoice/{invoiceID}/pay")
struct PayInvoiceCallback {
    let invoiceID: String
}

@TelerouteCallback("invoice/{invoiceID}/fail")
struct FailInvoiceCallback {
    let invoiceID: String
}
