# Middleware and Guards

Wrap handlers with cross-cutting behavior and gate routes with access control.

## Overview

Two composition primitives run around every handler:

- **Middleware** (``TelerouteMiddleware``) wraps handler execution — it can
  mutate the context, replace the response, retry, time out, or short-circuit.
- **Guards** (``TelerouteGuard``) return a verdict *before* the handler runs:
  allow, skip silently, or deny with a response.

Both can be attached at three levels: per route (`middlewares:`/`guards:`
parameters), per group (inherited by everything registered afterwards), and on
the router itself.

### Writing Middleware

One protocol serves every level. Middleware over your custom context is added
through the group's ``TelerouteRouterGroup/middlewares`` collection:

```swift
struct AuthMiddleware: TelerouteMiddleware {
    func handle(
        _ context: AppContext,
        next: @escaping @Sendable (AppContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        var context = context
        context.user = await lookup(context.userId)
        return try await next(context)      // may inspect/replace the response
    }
}

let router = Teleroute(context: AppContext.self)
router.middlewares.add(AuthMiddleware())
```

A middleware can also post-process the response the chain produced:

```swift
struct SignatureMiddleware: TelerouteMiddleware {
    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        let response = try await next(context)
        guard case let .reply(reply) = response else { return response }
        return .reply(Reply(reply.text + "\n— MyBot"))
    }
}
```

Low-level middleware over ``TelerouteContext`` can be attached to any route or
group via the `middlewares:` parameter, or added with
``TelerouteRouterMiddlewareCollection/add(core:)`` so it also wraps flows
mounted in the scope.

> Important: Middleware is snapshotted when a route is registered. **Add
> middleware before registering the routes that should use it** — later
> additions do not apply retroactively.

### Guards

Guards return a ``TelerouteGuardResult``:

- `.allow` — the route may handle the update;
- `.skip` — the route silently passes; matching continues with the next
  candidate (useful for overloading one command per audience);
- `.deny(response)` — the route consumes the update and responds.

```swift
struct WorkingHoursGuard: TelerouteGuard {
    func check(_ context: TelerouteContext) async throws -> TelerouteGuardResult {
        Calendar.current.component(.hour, from: .now) < 22
            ? .allow
            : .deny(.reply("The bot sleeps after 22:00 🌙"))
    }
}

router.group("admin") { admin in
    admin.guards.add(TelerouteAdminGuard(deny: .reply("Admins only")))
    admin.command("ban") { _ in "..." }
}
```

Every built-in guard accepts an optional `deny:` response; without one, a
failing guard skips silently:

```swift
TelerouteChatTypeGuard(.private)                  // chat type must match
TeleroutePrivateChatGuard()                       // 1:1 chats only
TelerouteGroupChatGuard()                         // groups/supergroups only
TelerouteUserAllowlistGuard([42, 128])            // sender allow-list
TelerouteChatAllowlistGuard([-1001234567890])     // chat allow-list
TelerouteArgumentCountGuard(2, deny: .reply("Usage: /pay <user> <amount>"))
TelerouteAdminGuard(deny: .reply("Admins only"))  // getChatMember-backed
```

### Aborting from a Handler

Handlers and context initializers may throw ``TelerouteAbort`` — the carried
response is rendered to the user and the update is reported as handled:

```swift
router.command("pay") { context in
    guard let amount = context.command?.get("amount", at: 1) else {
        throw TelerouteAbort("Usage: /pay <user> <amount>")
    }
    return "Paying \(amount)..."
}
```

Unexpected errors propagate to the configured
``TelerouteConfiguration/errorRenderer`` (converting them into a user-facing
response) and ``TelerouteConfiguration/onError`` (centralized reporting):

```swift
let configuration = TelerouteConfiguration(
    onError: { error, context in
        await alerting.report(error, chat: context.chatId)
    },
    errorRenderer: { _, _ in .reply(Reply("Something went wrong 😔")) }
)
```

### Built-In Middleware

```swift
// Log entry/exit around matched routes.
router.command("slow", middlewares: [TelerouteAccessLogMiddleware(label: "bot.access")]) { ... }

// Cancel handlers that exceed a deadline (throws TelerouteTimeoutError).
TelerouteTimeoutMiddleware(.seconds(5))

// Retry a flaky handler with exponential backoff.
TelerouteRetryMiddleware(retries: 2) { attempt in .seconds(1 << attempt) }

// Convert (or swallow) downstream errors for a scope.
TelerouteErrorHandlingMiddleware(renderer: { error, _ in
    .reply(Reply("Failed: \(error.localizedDescription)"))
})

// Drop repeats arriving within the interval, keyed by chat+user.
TelerouteThrottleMiddleware(interval: .seconds(2))

// Wait until input settles; superseded updates are dropped.
TelerouteDebounceMiddleware(interval: .milliseconds(700), scope: .chatUser)
```

Throttle and debounce share ``TelerouteRateLimitScope`` — key by `.chat`,
`.user`, `.chatUser`, `.callbackData`, `.command`, or a `.custom` closure
producing a ``TelerouteRateLimitKey``.

### Replay Protection

Telegram redelivers updates after restarts and webhook retries. The runtime
claims each update key in ``TelerouteConfiguration/replayProtectionStorage``
(default: in-memory, 2-second TTL) and drops duplicates before any route
runs. Multi-instance deployments plug in a shared backend by implementing
``TelerouteReplayProtectionStorage`` (for example over Redis `SET NX PX`).
Pass `replayProtectionStorage: nil` to disable — the in-process test helpers
do exactly that.

### Execution Order

For one matched route the chain is:

```
guards (scope, then route) → middleware (outermost first) → handler
```

Groups prepend their inherited middleware and guards to whatever a route adds
locally, so a route's own `guards:`/`middlewares:` always run innermost.
