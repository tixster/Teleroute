# Teleroute 3.2.0

Contexts and flows. Handlers get a request-scoped logger, typed failures and a
way to stop unwrapping optionals by hand; flows get a lifecycle they can observe
and react to, session expiry, persistence, and a lot less boilerplate.

Almost entirely source-compatible — the existing test suite passes unmodified.
Two exceptions are called out in [Upgrade notes](#upgrade-notes): a removed
enum case, and `TelerouteError` gaining cases.

## Contexts

- **`context.logger`** — a request-scoped `Logger` pre-populated with
  `update_id`, `chat_id`, `user_id`, `route_kind` and the matched command or
  callback data. Inside a flow step it also carries `flow_id` and `flow_step`.
  `context.logging(metadata:)` adds your own for a subtree of work.
- **`context.user`** resolves the Telegram user for every update kind that
  carries one. It is also correct where `message?.from` is not: on a callback
  query that is the bot, not the person who pressed the button. `context.chat`
  likewise.
- **A `require*` family** — `requireMessage`, `requireChatId`, `requireUser`,
  `requireUserId`, `requireCallbackQuery`, `requireCommand` — throws through the
  router's normal error pipeline instead of forcing a `guard` in every handler.
- **Typed throws.** The resolution and `require` families are declared
  `throws(TelerouteError)`, so a `catch` binds the concrete error with no cast:

  ```swift
  do {
      let user = try context.requireUser()
  } catch {
      switch error {              // TelerouteError, not any Error
      case .userTargetMissing: ...
      default: ...                // keep it — see Upgrade notes
      }
  }
  ```

  The same applies to `require` on `TelerouteParameters`, `TelerouteFlowValues`
  and `TelerouteCommandMatch`. Helpers that reach the network stay untyped: the
  client surfaces `TelegramAPIError` and transport errors, and Swift has no
  union of thrown types.
- **`withResolvedChat { bot, chatId in … }`** reaches the Bot API arguments the
  media helpers do not expose (`hasSpoiler`, `replyParameters`,
  `captionEntities`, …) without re-deriving the chat yourself.
- `requireAdmin` throws when the update carries no user, where `isAdmin` cannot
  tell that apart from "not an admin". `unpinCurrentMessage` mirrors
  `pinMessage`, which `unpinMessage` does not.
- `TelerouteParameters` gains the `get(_:as:)` it was missing next to
  `require(_:as:)`.

## Flows

### The flow context is a request context

`TelerouteFlowContext` now conforms to `TelerouteRequestContext`, so a step
reaches media, moderation, reactions, pinning, edit-target resolution, keyboards
and `logger` directly. The `context.context.sendPhoto(…)` hop the docs used to
recommend is no longer needed.

### Lifecycle hooks

```swift
flow.onEnd { context, reason in
    guard case let .interrupted(command) = reason else { return }
    try? await context.reply("Paused by /\(command). /resume to continue.")
}
```

`reason` is `.finished`, `.cancelled`, `.interrupted(command:)`, `.expired` or
`.replaced(by:)`. Three of those happen *to* a flow, and until now it had no way
of knowing about any of them.

### Deciding what an interrupting command does

```swift
flow.onInterrupt { _, command in
    command.name == "help" ? .keep : .handled(.reply("Finish signup first."))
}
```

| Decision | The session | The command |
|---|---|---|
| `.cancel` | ends, `onEnd(.interrupted)` fires | routes normally |
| `.keep` | stays active and capturing | routes normally |
| `.suspend` | stays, stops capturing until resumed | routes normally |
| `.handled(response)` | stays active | **stops here** — its own route does not run |

Without the hook, `flowCancellationPolicy` behaves exactly as before.

### Suspending instead of discarding

`suspendFlow()` / `resumeFlow()` park a half-finished conversation. The session
stays in storage, stops intercepting, and keeps counting toward its TTL.

### Session expiry

```swift
TelerouteConfiguration(flowSessionTTL: .seconds(30 * 60))
struct SignupFlow: TelerouteFlow { static let sessionTTL: Duration? = .seconds(600) }
```

`nil` is the default and preserves today's behavior. Expiry slides forward on
every write and is enforced when a session is read, inside the per-session
serialized section, so it cannot race a concurrent write.

### Persistence for shared stores

`TelerouteFlowSession`, `TelerouteFlowValues` and `TelerouteFlowKey` are
`Codable`. `TelerouteFlowSessionCoding` pins the format and
`TelerouteFlowKey.storageKey` the key, so a Redis or Postgres backend no longer
has to invent either. Records written without timestamps still decode.
`TelerouteFlowStorageCleanup` is opt-in for backends that can sweep.

### Less boilerplate

```swift
enum Step: String, CaseIterable { case name, email, confirm }

flow.start("signup", at: .name, asking: "What's your name?")
flow.ask(.name, store: "name", next: "And your email?")
flow.ask(.email, store: "email", next: "Confirm with /done.")
```

`ask` collapses prompt, capture, validation, storage and the transition. With a
`CaseIterable` `Step` the next step comes from declaration order. A rejected
answer leaves the session where it was, so re-asking is free. `boot` can now
return `Exports`, mirroring `TelerouteRouteCollection`.

### Typed state

```swift
struct FlowState: Codable, Sendable { var name = ""; var attempts = 0 }

try await context.transition(to: .confirm, state: .init())
let state = try context.requireState()
```

Persisted inside the existing flow values under a reserved key, so the storage
wire format is unchanged and every `TelerouteFlowStorage` keeps working.

### Typed value access

`values.require("amount", as: Double.self)` and `values.get("page", as: Int.self)`,
matching what `TelerouteParameters` and `TelerouteCommandMatch` already had.

## Observability

`TelerouteMetricsSink.recordFlowEnded` reports every session that ends with its
outcome (`finished` / `cancelled` / `expired`) and the age measured from
`createdAt` — so completion and abandonment are finally distinguishable.
`TelerouteSwiftMetricsSink` exports `teleroute.flows.ended` (dimensioned by
`flow` and `outcome`) and `teleroute.flow.age`.

New diagnostic: `unreachableFlowSteps`, alongside `duplicateRouteSignatures`,
reports a linear `ask` that tried to advance from a step with nowhere to go.

## Fixes

- **Flow sessions could come back from the dead.** `transition` and `update` fell
  back to the step's own snapshot, silently recreating a session a handler had
  just finished. They now refuse, throwing `flowSessionEnded` or
  `flowSessionReplaced`; because the mutation throws before returning, neither
  the default storage nor an atomic backend writes.
- **Buttons with inline handlers did not work inside a flow step.** The flow
  coordinator built its contexts without the inline-action store, so rendering
  one threw `inlineActionsDisabled` — reporting the feature as off even when it
  was explicitly enabled.
- **A replaced session vanished from the metrics.** `start` overwriting a live
  session emitted no `recordFlowEnded`.
- `start` and `restart` now write through the atomic `updateSession`, so all four
  flow writes take one path.
- `approveJoinRequest` / `declineJoinRequest` reported `chatTargetMissing` when
  it was the *user* that was missing.
- `reply(quote:)` now warns when it degrades to a plain send and drops the quote,
  instead of discarding it silently.

## Upgrade notes

### Two things that can stop your build

**`TelerouteFlowCancellationPolicy.manual` was removed** — see below.

**`TelerouteError` gained cases** — `userTargetMissing`, `flowSessionEnded`,
`flowSessionReplaced`. An exhaustive `switch` over it without a `default` will
not compile. Add a `default`.

This matters more than it used to: typed throws means a `catch` from
`requireUser()` and friends now binds `TelerouteError` concretely, so an
exhaustive `switch` there compiles too — and will break on the next added case.
Treat `TelerouteError` as a growing type and always carry a `default`.

### Three things that compile but behave differently

1. **A handler that ends a session and then transitions now throws.** Previously
   the session was silently recreated. Reorder it to reply first, end second.
2. **Restart-heavy bots will start reporting `recordFlowEnded(.cancelled)`
   events they never reported before**, now that replacement is no longer
   invisible. If you alert on that counter, expect a step change.
   `TelerouteFlowOutcome` has no `.replaced` case because adding one would break
   exhaustive switches; that is a 4.0 change.
3. **A `TelerouteFlowStorage` that hand-rolls its own encoder** rather than using
   `TelerouteFlowSessionCoding` will silently drop the new timestamp and
   suspension fields — so TTL and suspension will not work, with no error. Use
   `TelerouteFlowValues.rawDictionary` for values.

### Removed: `TelerouteFlowCancellationPolicy.manual`

`.manual` and `.preserveOnUnmatchedCommand` were the same code path — two
spellings of "an unmatched command does not end the session". `.manual` is gone;
use `.preserveOnUnmatchedCommand`, which names the scope honestly and pairs with
`.cancelOnAnyUnmatchedCommand`.

```diff
-TelerouteConfiguration(flowCancellationPolicy: .manual)
+TelerouteConfiguration(flowCancellationPolicy: .preserveOnUnmatchedCommand)
```

`.manual`'s documentation also claimed it meant a session is *never* cancelled
automatically. That was true when it was written and stopped being true in this
release: `flowSessionTTL` expires idle sessions regardless of the policy, and
`start` still replaces whatever session held the chat. The policy has only ever
governed unmatched commands.

For per-flow control, `onInterrupt` now does what no policy could: suspend the
session, or answer the command and stop it reaching its own route.
