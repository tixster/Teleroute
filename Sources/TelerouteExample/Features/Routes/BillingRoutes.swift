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
            try await self.openInvoice(context)
        }

        return callbacks
    }

    private func openInvoice(
        _ context: ExampleRequestContext
    ) async throws -> TelerouteResponse {
        let invoiceID = context.command?.get("invoiceID") ?? "unknown"
        return Reply("Invoice \(invoiceID)").keyboard {
            Row {
                TelerouteButton("Mark paid") { PayInvoiceCallback(invoiceID: invoiceID) }
                    .style(.success)
                TelerouteButton("Mark failed") { FailInvoiceCallback(invoiceID: invoiceID) }
                    .style(.danger)
            }
        }
        .makeResponse()
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
