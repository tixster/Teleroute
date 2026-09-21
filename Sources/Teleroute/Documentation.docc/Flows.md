# Flows

Build multi-step conversations with per-chat/user session state.

## Overview

A flow is a small state machine: one session per `chatId + userId` pair, a
current step, and a string-keyed bag of collected values. While a session is
active, the flow's step routes match **before** everything else in the
dispatch pipeline, so the flow "captures" the conversation until it finishes
or is cancelled.

### Define a Flow

Conform to ``TelerouteFlow``, enumerate the steps, and register step handlers
in `boot(flow:)`:

```swift
struct SignupFlow: TelerouteFlow {
    enum Step: String { case name, confirm }

    func boot(flow: TelerouteFlowGroup<SignupFlow>) {
        // /signup starts (or restarts) the flow at .name.
        flow.start("signup", at: .name) { context in
            try await context.reply("Send your name.")
        }

        // Any plain message while at .name.
        flow.message(at: .name) { context in
            try await context.transition(
                to: .confirm,
                merging: ["name": context.message?.text ?? ""]
            )
            try await context.reply("Confirm with /done.")
        }

        // /done, but only while at .confirm.
        flow.command("done", at: .confirm) { context in
            try await context.finish()
            try await context.reply("Welcome, \(try context.values.require("name"))!")
        }
    }
}

router.flow(SignupFlow())
```

Step registration methods on ``TelerouteFlowGroup``:

- ``TelerouteFlowGroup/start(_:at:botUsername:description:visibility:guards:middlewares:queue:use:)``
  — a command that begins the flow;
- ``TelerouteFlowGroup/message(at:guards:middlewares:use:)`` — any non-command
  message at a step;
- ``TelerouteFlowGroup/command(_:at:botUsername:guards:middlewares:use:)`` — a
  command valid only at a step;
- `callback(_:at:guards:middlewares:use:)` — a callback pattern (or a typed
  callback type) valid only at a step.

### The Flow Context

Step handlers receive a ``TelerouteFlowContext`` carrying the decoded current
`step`, the active ``TelerouteFlowSession``, and the accumulated
``TelerouteFlowValues``. Session control:

```swift
flow.message(at: .amount) { context in
    guard let amount = Double(context.message?.text ?? "") else {
        try await context.reply("Please send a number.")
        return                                            // stay on this step
    }
    try await context.transition(to: .confirm, merging: ["amount": "\(amount)"])
    try await context.update(merging: ["attempts": "0"])  // values only
    // context.restart(at: .name)  — wipe and start over
    // context.finish()            — end the session
}
```

``TelerouteFlowContext`` is its own type rather than a
``TelerouteRequestContext``. It carries the helpers a step usually needs —
`reply`, `send`, `edit`, `answerCallbackQuery`, `keyboard { }` — alongside the
flow ones (`transition`, `finish`, `values`).

The rest of the surface is one hop away through
``TelerouteFlowContext/context``, the underlying ``TelerouteContext``:

```swift
flow.message(at: .photo) { context in
    try await context.context.sendPhoto(.fileID(id), caption: "Saved")
    try await context.context.react("👍")
}
```

`context.context.bot` reaches any Bot API operation from a step.

Values are `String`-keyed and `String`-valued; read them with
``TelerouteFlowValues/get(_:)``, ``TelerouteFlowValues/require(_:)``, or
subscripting.

### Starting Flows from Outside

Any context can start or cancel a session imperatively — useful when a button
press should begin a wizard:

```swift
router.callback("wizard/begin") { context in
    try await context.start(SignupFlow.self, at: .name)
    return .edit("Let's begin. Send your name.")
}

router.command("cancel") { context in
    try await context.cancelFlow()
    return "Cancelled."
}
```

### Cancellation Policy

By default an unrelated command arriving mid-flow (say `/help`) cancels the
session, so the next message is no longer captured. Tune this with
``TelerouteFlowCancellationPolicy`` on the configuration:

```swift
let configuration = TelerouteConfiguration(
    flowCancellationPolicy: .preserveOnUnmatchedCommand
)
```

- `cancelOnAnyUnmatchedCommand` — the default;
- `preserveOnUnmatchedCommand` — the command falls through to regular routes
  and the flow keeps capturing;
- `manual` — only `context.cancelFlow()` / `finish()` end a session.

### Storage

Sessions live in the configured ``TelerouteFlowStorage``. The default
``TelerouteInMemoryFlowStorage`` is process-local; multi-instance deployments
implement the four-method protocol over a shared store (Redis, Postgres, …).
The ``TelerouteFlowStorage/updateSession(for:_:)`` requirement enables atomic
read-modify-write for backends that support it.

```swift
let configuration = TelerouteConfiguration(flowStorage: RedisFlowStorage(pool: pool))
```

### Middleware, Guards, and Keyboards in Flows

Flows mounted in a group inherit that group's middleware and guards. Flow
groups can also render typed callback buttons for their own callback routes
via `flow.render(_:)` and `flow.keyboard(_:)`, keeping button generation
scope-validated just like router keyboards (<doc:Keyboards>).
