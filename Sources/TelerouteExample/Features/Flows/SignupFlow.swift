import Teleroute

/// Multi-step signup flow used by the example project.
///
/// This flow demonstrates:
/// - `flow.start(...)` as an entry command
/// - message routing by active step
/// - callback routing by active step
/// - persisted flow values
/// - restart and finish transitions
/// - flow-local callback keyboard generation
struct SignupFlow: TelerouteFlow {
    /// Stable flow steps stored in the session payload.
    enum Step: String, Sendable {
        case name
        case confirm
    }

    func boot(flow: TelerouteFlowGroup<SignupFlow>) {
        flow.start(
            "signup",
            at: .name,
            description: "Start a multi-step signup flow",
            visibility: [.allPrivateChats],
            queueing: .chatUser
        ) { _, context in
            try await context.reply(text: "Send your name to begin signup.")
        }

        flow.message(at: .name) { _, context in
            let name = context.message?.text ?? "Anonymous"
            let approve = try flow.callbackButton(
                "Approve",
                path: "confirm/{decision}",
                parameters: ["decision": "approve"],
                style: "success"
            )
            let restart = try flow.callbackButton(
                "Restart",
                path: "confirm/{decision}",
                parameters: ["decision": "restart"],
                style: "danger"
            )

            try await context.transition(to: .confirm, merging: ["name": name])
            try await context.reply(
                text: "Confirm signup for \(name)?",
                replyMarkup: .inlineKeyboardMarkup(flow.callbackKeyboard([[approve, restart]]))
            )
        }

        flow.command("cancel", at: .confirm) { _, context in
            try await context.finish()
            try await context.reply(text: "Signup cancelled.")
        }

        flow.callback("confirm/{decision}", at: .confirm) { _, context in
            let decision = try context.parameters.require("decision")

            if decision == "restart" {
                try await context.restart(at: .name)
                try await context.answerCallbackQuery(text: "Restarted")
                try await context.edit(text: "Signup restarted. Send your name again.")
                return
            }

            let name = try context.values.require("name")
            try await context.finish()
            try await context.answerCallbackQuery(text: "Signup complete")
            try await context.edit(text: "Signup complete for \(name).")
        }
    }
}
