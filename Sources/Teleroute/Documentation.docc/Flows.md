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

``TelerouteFlowContext`` **is** a ``TelerouteRequestContext``, so every helper
a handler has, a step has too — `reply`, `send`, `edit`, media, moderation,
reactions, pinning, `keyboard { }`, `resolvedEditTarget`, `logger` — alongside
the flow-specific ones (`transition`, `finish`, `cancel`, `values`):

```swift
flow.message(at: .photo) { context in
    try await context.sendPhoto(.fileID(id), caption: "Saved")
    try await context.react("👍")
}
```

``TelerouteFlowContext/context`` still exposes the underlying
``TelerouteContext`` for code that wants it explicitly, and `context.bot`
reaches any Bot API operation.

Values are `String`-keyed and `String`-valued. Read them with
``TelerouteFlowValues/get(_:)``, ``TelerouteFlowValues/require(_:)``, or
subscripting, and decode them in place when they are not really strings:

```swift
let amount = try context.values.require("amount", as: Double.self)
let page = context.values.get("page", as: Int.self) ?? 1
```

A malformed value throws ``TelerouteError/invalidParameter(name:value:)``
rather than silently coercing.

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

### Ending a Session

``TelerouteFlowContext/finish()`` completes a flow and
``TelerouteFlowContext/cancel()`` abandons it. Both end the session; they
differ in the ``TelerouteFlowOutcome`` reported to the metrics sink, which is
what lets you measure whether users finish a wizard or drop out of it.

A step must not advance a session it has already ended — `transition` and
`update` throw ``TelerouteError/flowSessionEnded(flowID:)`` rather than
silently recreating it:

```swift
flow.command("done", at: .confirm) { context in
    try await context.reply("All set!")   // reply first…
    try await context.finish()            // …then end the session
}
```

### Session Lifetime

By default a session lives until a handler ends it — so an abandoned
conversation keeps capturing its chat indefinitely. Set a TTL to make idle
sessions expire:

```swift
let configuration = TelerouteConfiguration(flowSessionTTL: .seconds(30 * 60))

// Or per flow:
struct SignupFlow: TelerouteFlow {
    static let sessionTTL: Duration? = .seconds(10 * 60)
}
```

Expiry is sliding: every write — start, transition, update, restart —
refreshes the deadline. When an expired session is next read, it is dropped and
the update falls through to normal routing, so the user is not stuck.

### Knowing When a Session Ends

Three of the four ways a session can end happen *to* a flow rather than being
asked for by it. ``TelerouteFlowGroup/onEnd(_:)`` is how a flow finds out:

```swift
flow.onEnd { context, reason in
    switch reason {
    case let .interrupted(command):
        try? await context.reply("Paused by /\(command). Send /resume to continue.")
    case .expired:
        try? await context.reply("That took too long — start again with /signup.")
    case let .replaced(by: flowID) where flowID != SignupFlow.id:
        try? await context.reply("Switching to something else.")
    case .finished, .cancelled, .replaced:
        break
    }
}
```

The hook receives a ``TelerouteFlowEndContext`` — a full request context, so
`reply`, `edit`, media and `logger` all work — plus the final session snapshot
in `endedSession`. It is deliberately *not* a ``TelerouteFlowContext``: the
session is already gone, so `transition` and `update` would only throw. Read
the collected values from `endedSession` instead.

The hook cannot throw; teardown has already happened and there would be
nowhere to report a failure. Handle send errors with `try?`.

### Cancellation Policy, and Deciding Per Flow

By default an unrelated command arriving mid-flow (say `/help`) cancels the
session, so the next message is no longer captured. The configuration-level
knob is ``TelerouteFlowCancellationPolicy``:

- `cancelOnAnyUnmatchedCommand` — the default;
- `preserveOnUnmatchedCommand` — the session survives and the command falls
  through to regular routes, so cancellation only happens where a handler asks
  for it.

> Note: the policy covers unmatched commands and nothing else. It does not hold
> a session open against ``TelerouteConfiguration/flowSessionTTL``, and starting
> a flow still replaces whatever session held the chat.

``TelerouteFlowGroup/onInterrupt(_:)`` lets the flow itself decide, overriding
the policy for that flow only:

```swift
flow.onInterrupt { _, command in
    switch command.name {
    case "help":   .keep                                    // harmless, let it through
    case "cancel": .cancel                                  // end the conversation
    default:       .handled(.reply("Finish signup first, or /cancel."))
    }
}
```

| Decision | The session | The command |
|---|---|---|
| `.cancel` | ends, `onEnd(.interrupted)` fires | routes normally |
| `.keep` | stays active and capturing | routes normally |
| `.suspend` | stays, stops capturing until resumed | routes normally |
| `.handled(response)` | stays active | **stops here** — its own route does not run |

Without the hook, the configured policy decides exactly as it always has.

### Suspending and Resuming

`.suspend` — or ``TelerouteRequestContext/suspendFlow()`` from any handler —
parks a session instead of discarding it:

```swift
router.command("pause") { context in
    try await context.suspendFlow()
    return "Paused. /resume when you're ready."
}

router.command("resume") { context in
    try await context.resumeFlow()
    return "Where were we?"
}
```

A suspended session stays in storage and stops intercepting updates, so they
route normally. It keeps counting toward its TTL, so an abandoned suspended
session still expires rather than leaking. Resuming refreshes the deadline, and
any `transition` or `update` wakes it automatically.

### Observability

``TelerouteMetricsSink/recordFlowEnded(flowID:step:outcome:age:chatId:userId:)``
fires whenever a session ends, with the outcome (`finished`, `cancelled`,
`expired`) and the session's age measured from `createdAt`.
``TelerouteSwiftMetricsSink`` exports these as `teleroute.flows.ended`
(dimensioned by `flow` and `outcome`) and `teleroute.flow.age`.

### Typed State

String keys get old. Declare a `FlowState` and work with fields:

```swift
struct SignupFlow: TelerouteFlow {
    struct FlowState: Codable, Sendable, TelerouteDefaultInitializable {
        var name = ""
        var attempts = 0
        init() {}
    }

    func boot(flow: TelerouteFlowGroup<SignupFlow>) {
        flow.message(at: .name) { context in
            try await context.transition(to: .confirm, state: .init())
            try await context.mutateState { $0.attempts += 1 }
            let state = try context.requireState()
            try await context.reply("Hello, \(state.name)")
        }
    }
}
```

The state is persisted **inside** the ordinary ``TelerouteFlowValues`` under a
reserved key, so the storage wire format is unchanged and every existing
``TelerouteFlowStorage`` keeps working. The key is hidden from `values.keys`,
`count`, `isEmpty` and `dictionary`; a backend that persists values itself must
use ``TelerouteFlowValues/rawDictionary`` so typed state is not dropped.

Sessions written before a flow adopted `FlowState` simply have none, and
`state()` returns `nil`.

> Note: the associated type is called `FlowState`, not `State`, on purpose.
> Swift prefers a conformer's nested type over an associated type's default, so
> a flow with an unrelated `struct State` would bind to it and fail to conform.

### Storage

Sessions live in the configured ``TelerouteFlowStorage``. The default
``TelerouteInMemoryFlowStorage`` is process-local; multi-instance deployments
implement the four-method protocol over a shared store (Redis, Postgres, …).

```swift
let configuration = TelerouteConfiguration(flowStorage: RedisFlowStorage(pool: pool))
```

Use ``TelerouteFlowSessionCoding`` and ``TelerouteFlowKey/storageKey`` rather
than inventing a format — they pin the date strategy and carry a schema
version, so records stay readable across deployments:

```swift
actor RedisFlowStorage: TelerouteFlowStorage {
    let redis: RedisClient

    func session(for key: TelerouteFlowKey) async -> TelerouteFlowSession? {
        guard let raw: String = try? await redis.get(key.storageKey) else { return nil }
        return try? TelerouteFlowSessionCoding.decode(raw)
    }

    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) async {
        guard let payload = try? TelerouteFlowSessionCoding.encodeToString(session) else { return }
        // Native expiry is an optimization; the router re-checks on read.
        try? await redis.set(key.storageKey, to: payload, expiring: session.timeToLive())
    }

    func removeSession(for key: TelerouteFlowKey) async {
        try? await redis.delete(key.storageKey)
    }

    func updateSession(
        for key: TelerouteFlowKey,
        _ mutation: TelerouteFlowSessionMutation
    ) async rethrows -> TelerouteFlowSession? {
        // Apply atomically where you can (Lua, WATCH, SELECT … FOR UPDATE).
        // A mutation that throws must leave the stored session untouched.
        ...
    }
}
```

Checklist for an implementation:

- Persist all six fields. `createdAt` is never rewritten — the router owns
  `updatedAt` and `expiresAt`.
- If the store expires keys natively, set the deadline from
  ``TelerouteFlowSession/timeToLive(at:)`` on every write. This is an
  optimization, never a correctness requirement: the router checks
  ``TelerouteFlowSession/isExpired(at:)`` whenever it reads a session, so
  returning an expired one is fine — it will be removed.
- Implement ``TelerouteFlowStorage/updateSession(for:_:)`` atomically if the
  backend supports it, and **propagate a thrown mutation without writing** —
  that is what stops a finished session from being resurrected.
- Conform to ``TelerouteFlowStorageCleanup`` only when a sweep is cheap.

> Note: expiry uses wall-clock `Date` rather than a monotonic clock, precisely
> because sessions outlive a process. Clock skew between instances can make a
> session expire a little early or late; it can never lose one mid-step.

### Middleware, Guards, and Keyboards in Flows

Flows mounted in a group inherit that group's middleware and guards. Flow
groups can also render typed callback buttons for their own callback routes
via `flow.render(_:)` and `flow.keyboard(_:)`, keeping button generation
scope-validated just like router keyboards (<doc:Keyboards>).
