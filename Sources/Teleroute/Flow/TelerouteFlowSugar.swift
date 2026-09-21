import Foundation
import TelegramBotAPI

/// What a validator decided about the answer a step just received.
public enum TelerouteFlowAnswer: Sendable {
    /// Store it and move on.
    case accept
    /// Say this and stay on the current step, so the user can try again.
    case retry(String)
}

public extension TelerouteFlowGroup {
    /// Asks a question at a step, stores the reply, and moves on — the
    /// prompt/capture/store/transition idiom in one line.
    ///
    /// ```swift
    /// flow.start("signup", at: .name, asking: "What's your name?")
    /// flow.ask(.name, store: "name", then: .confirm, next: "Confirm with /done.")
    /// ```
    ///
    /// Equivalent to registering ``message(at:guards:middlewares:use:)`` that
    /// transitions with the captured text merged in, so anything this does not
    /// cover stays expressible the long way.
    ///
    /// - Parameters:
    ///   - step: The step that captures the reply.
    ///   - key: Flow-values key the reply is stored under.
    ///   - next: The step to move to once the reply is accepted.
    ///   - prompt: Optional text sent after the transition, i.e. the next
    ///     question.
    ///   - empty: Sent instead of storing when the message carries no text.
    ///   - guards: Guards applied to the capturing step.
    ///   - middlewares: Middleware applied to the capturing step.
    func ask(
        _ step: Flow.Step,
        store key: String,
        then next: Flow.Step,
        next prompt: String? = nil,
        empty: String? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = []
    ) {
        self.message(at: step, guards: guards, middlewares: middlewares) { context in
            guard let text = context.message?.text, text.isEmpty == false else {
                if let empty {
                    try await context.reply(empty)
                }
                return
            }
            try await context.transition(to: next, merging: [key: text])
            if let prompt {
                try await context.reply(prompt)
            }
        }
    }

    /// ``ask(_:store:then:next:empty:guards:middlewares:)`` with the reply
    /// decoded and validated first.
    ///
    /// ```swift
    /// flow.ask(.amount, store: "amount", as: Double.self, then: .confirm) { value in
    ///     value > 0 ? .accept : .retry("Send a positive number.")
    /// }
    /// ```
    ///
    /// A reply that does not decode, or that the validator rejects, leaves the
    /// session on this step — so the user simply answers again.
    func ask<Value: LosslessStringConvertible & Sendable>(
        _ step: Flow.Step,
        store key: String,
        as type: Value.Type,
        then next: Flow.Step,
        next prompt: String? = nil,
        invalid: String? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        validate: (@Sendable (Value) -> TelerouteFlowAnswer)? = nil
    ) {
        self.message(at: step, guards: guards, middlewares: middlewares) { context in
            guard let text = context.message?.text, let value = Value(text) else {
                if let invalid {
                    try await context.reply(invalid)
                }
                return
            }
            if case let .retry(message) = validate?(value) ?? .accept {
                try await context.reply(message)
                return
            }
            try await context.transition(to: next, merging: [key: text])
            if let prompt {
                try await context.reply(prompt)
            }
        }
    }

    /// Registers a command that starts the flow and immediately asks the first
    /// question, replacing the empty `use:` closure that always follows.
    ///
    /// ```swift
    /// flow.start("signup", at: .name, asking: "What's your name?")
    /// ```
    func start(
        _ path: String,
        at step: Flow.Step,
        asking prompt: String,
        botUsername: String? = nil,
        description: String? = nil,
        visibility: [TelerouteCommandVisibility] = [.default],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        queue: TelerouteQueueScope? = nil
    ) {
        self.start(
            path,
            at: step,
            botUsername: botUsername,
            description: description,
            visibility: visibility,
            guards: guards,
            middlewares: middlewares,
            queue: queue
        ) { context in
            try await context.reply(prompt)
        }
    }
}

// MARK: - Linear flows

public extension TelerouteFlowGroup where Flow.Step: CaseIterable,
                                          Flow.Step.AllCases: BidirectionalCollection,
                                          Flow.Step.AllCases.Element == Flow.Step {
    /// The step declared after this one, or `nil` at the end.
    ///
    /// Available only when `Step` is `CaseIterable`, which is what lets a
    /// linear flow skip spelling `then:` on every question.
    func step(after step: Flow.Step) -> Flow.Step? {
        let all = Flow.Step.allCases
        guard let index = all.firstIndex(of: step) else { return nil }
        let next = all.index(after: index)
        return next == all.endIndex ? nil : all[next]
    }

    /// ``ask(_:store:then:next:empty:guards:middlewares:)`` with the next step
    /// taken from the declaration order of `Step`.
    ///
    /// ```swift
    /// enum Step: String, CaseIterable { case name, email, confirm }
    ///
    /// flow.ask(.name, store: "name", next: "And your email?")
    /// flow.ask(.email, store: "email", next: "Confirm with /done.")
    /// ```
    ///
    /// Asking on the last step is a programmer error — there is nowhere to go —
    /// so it registers nothing and reports the step through the router's
    /// `unreachableFlowSteps` diagnostics.
    ///
    /// - Parameters:
    ///   - step: The step that captures the reply.
    ///   - key: Flow-values key the reply is stored under.
    ///   - prompt: Optional text sent after advancing.
    ///   - empty: Sent instead of storing when the message carries no text.
    ///   - guards: Guards applied to the capturing step.
    ///   - middlewares: Middleware applied to the capturing step.
    func ask(
        _ step: Flow.Step,
        store key: String,
        next prompt: String? = nil,
        empty: String? = nil,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = []
    ) {
        guard let next = self.step(after: step) else {
            self.storage.recordFlowStepWithoutSuccessor(
                flowID: Flow.id,
                step: step.rawValue
            )
            return
        }
        self.ask(
            step,
            store: key,
            then: next,
            next: prompt,
            empty: empty,
            guards: guards,
            middlewares: middlewares
        )
    }
}
