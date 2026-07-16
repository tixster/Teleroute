import Teleroute
import TelerouteMacros

/// Reusable route collection with nested command and callback routes.
///
/// The collection owns its route declarations and handler methods without exposing
/// either to the top-level app configuration.
struct BillingRoutes: TelerouteRouteCollection {
    struct Routes: Sendable {
        let pay: TelerouteCallbackRoute<PayInvoiceCallback>
        let fail: TelerouteCallbackRoute<FailInvoiceCallback>
    }

    func addRoutes(to routes: ExampleRoutes) -> Routes {
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
        _ context: ExampleRequestContext,
        routes: ExampleRoutes,
        callbacks: Routes
    ) async throws -> TelerouteResponse {
        let invoiceID = context.command?.get("invoiceID") ?? "unknown"
        let keyboard = try routes.keyboard([[
            callbacks.pay.button(PayInvoiceCallback(invoiceID: invoiceID), "Mark paid"),
            callbacks.fail.button(FailInvoiceCallback(invoiceID: invoiceID), "Mark failed"),
        ]])

        return .reply(
            "Invoice \(invoiceID)",
            replyMarkup: .inlineKeyboardMarkup(keyboard)
        )
    }

    private func markInvoicePaid(
        _ callback: PayInvoiceCallback,
        _ context: ExampleRequestContext
    ) async throws -> TelerouteResponse {
        .sequence([
            .answerCallback("Invoice \(callback.invoiceID) paid"),
            .edit("Invoice \(callback.invoiceID) paid"),
        ])
    }

    private func markInvoiceFailed(
        _ callback: FailInvoiceCallback,
        _ context: ExampleRequestContext
    ) async throws -> TelerouteResponse {
        .sequence([
            .answerCallback("Invoice \(callback.invoiceID) failed"),
            .edit("Invoice \(callback.invoiceID) failed"),
        ])
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
