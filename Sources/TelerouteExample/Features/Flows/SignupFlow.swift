import Teleroute
import TelerouteMacros

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
        let decisions = flow.callback(
            SignupDecisionCallback.self,
            at: .confirm,
            use: self.handleDecision
        )

        flow.start(
            "signup",
            at: .name,
            description: "Start a multi-step signup flow",
            visibility: [.allPrivateChats],
            queue: .perChatAndUser
        ) { context in
            try await context.reply("Send your name to begin signup.")
        }

        flow.message(at: .name) { context in
            let name = context.message?.text ?? "Anonymous"
            let keyboard = try flow.keyboard([[
                decisions.button(
                    SignupDecisionCallback(decision: "approve"),
                    "Approve",
                    style: "success"
                ),
                decisions.button(
                    SignupDecisionCallback(decision: "restart"),
                    "Restart",
                    style: "danger"
                ),
            ]])

            try await context.transition(to: .confirm, merging: ["name": name])
            try await context.reply(
                "Confirm signup for \(name)?",
                replyMarkup: .inline(keyboard)
            )
        }

        flow.command("cancel", at: .confirm) { context in
            try await context.finish()
            try await context.reply("Signup cancelled.")
        }
    }

    private func handleDecision(
        _ callback: SignupDecisionCallback,
        _ context: TelerouteFlowContext<Self>
    ) async throws {
        if callback.decision == "restart" {
            try await context.restart(at: .name)
            try await context.answerCallbackQuery("Restarted")
            try await context.edit("Signup restarted. Send your name again.")
            return
        }

        let name = try context.values.require("name")
        try await context.finish()
        try await context.answerCallbackQuery("Signup complete")
        try await context.edit("Signup complete for \(name).")
    }
}

@TelerouteCallback("confirm/{decision}")
private struct SignupDecisionCallback {
    let decision: String
}
