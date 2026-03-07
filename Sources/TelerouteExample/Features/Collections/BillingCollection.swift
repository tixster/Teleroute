import Teleroute

/// Collection demonstrating nested command and callback routes under a feature namespace.
///
/// This collection shows how a reusable feature can own its internal callback
/// routes without exposing them to the top-level app configuration.
struct BillingCollection: TelerouteCollectionBuilder {
    func boot(collection: TelerouteCollectionGroup) {
        collection.group("billing") { billing in
            billing.command(
                "invoice",
                description: "Open an invoice",
                visibility: [.allPrivateChats]
            ) { _, context in
                let invoiceID = context.command?.get("invoiceID") ?? "unknown"
                let actions = try billing.callbackButtons([
                    ("Mark paid", path: "invoice/{invoiceID}/pay", parameters: ["invoiceID": invoiceID]),
                    ("Mark failed", path: "invoice/{invoiceID}/fail", parameters: ["invoiceID": invoiceID]),
                ])

                try await context.reply(
                    text: "Invoice \(invoiceID)",
                    replyMarkup: .inlineKeyboardMarkup(billing.callbackKeyboard([actions]))
                )
            }

            billing.callback("invoice/{invoiceID}/pay") { _, context in
                let invoiceID = try context.parameters.require("invoiceID")
                try await context.answerCallbackQuery(text: "Invoice \(invoiceID) paid")
                try await context.edit(text: "Invoice \(invoiceID) paid")
            }

            billing.callback("invoice/{invoiceID}/fail") { _, context in
                let invoiceID = try context.parameters.require("invoiceID")
                try await context.answerCallbackQuery(text: "Invoice \(invoiceID) failed")
                try await context.edit(text: "Invoice \(invoiceID) failed")
            }
        }
    }
}
