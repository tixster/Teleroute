# Routing

Register handlers for commands, messages, callbacks, and every other update kind, and understand the order they are matched in.

## Overview

Every Telegram update kind is routable. When an update arrives, Teleroute
dispatches it through a fixed pipeline:

1. **Discussion forwards** — an automatic forward of a channel post into its
   linked discussion chat is recorded and passed to every
   `onDiscussionForward` observer (see
   <doc:Routing#Channel-Discussion-Forwards>). This does not end routing.
2. **Replay protection** — duplicates within the TTL are dropped
   (``TelerouteConfiguration/replayProtectionStorage``).
3. **Flows** — if the chat/user has an active flow session, its step routes
   match first (<doc:Flows>).
4. **Callbacks** — callback-query routes matched against the callback data.
5. **Commands** — `/command` routes.
6. **Message routes** — content-filtered plain-message routes.
7. **Update-kind routes** — `on(_:)` and the typed payload sugar.
8. **`unmatched` hook** — the final fallback.

Within each stage, routes are tried in registration order. A route that
returns `.unhandled` (or whose guard returns `.skip`) falls through to the
next candidate, ending with the `unmatched` hook.

### Commands

```swift
router.command("start", description: "Begin") { _ in "Welcome!" }

// Commands with arguments: /ban 42 spamming
router.command("ban") { context in
    let userId = try context.command!.require("userId", as: Int64.self)
    let reason = context.command?.get("reason", at: 1) ?? "no reason"
    try await context.banMember(userId)
    return "Banned \(userId): \(reason)"
}
```

The optional `description:` feeds Telegram's command menu; see
``TelerouteBot/syncPublishedCommands()`` and
``TelerouteConfiguration/syncPublishedCommandsOnStart``. Parsed command
metadata — name, raw token, and whitespace-split arguments — is available as
``TelerouteCommandMatch`` through `context.command`.

Commands in groups may carry a bot mention (`/ping@my_bot`); pass
`botUsername:` to restrict a route to explicit mentions of your bot.

Long-running commands can be serialized per scope with `queue:`:

```swift
// One export at a time per chat+user; further /export commands wait in line.
router.command("export", queue: .perChatAndUser) { context in
    try await context.withChatAction(.uploadDocument) {
        try await generateAndSendReport(context)
    }
}
```

### Plain Messages

Message routes take a ``TelerouteMessageFilter`` and an optional set of
``TelerouteMessageSource`` values:

```swift
router.message(.text) { context in "echo: \(context.message?.text ?? "")" }
router.message(.photo) { _ in "Got a photo" }
router.message(.document, from: [.message, .business]) { _ in "Got a file" }

// Custom predicate over the raw Message.
router.message(.custom("long-text") { ($0.text?.count ?? 0) > 500 }) { _ in
    "That's a long one."
}
```

Built-in filters cover `.any`, `.text`, `.photo`, `.document`, `.video`,
`.audio`, `.voice`, `.videoNote`, `.sticker`, `.animation`, `.location`,
`.contact`, `.newChatMembers`, and `.successfulPayment`.

By default only fresh direct messages match (`[.message]`). Sources let a
route also receive `.edited` messages, `.channelPost` / `.editedChannelPost`,
and `.business` / `.editedBusiness` messages.

Text sugar narrows message routes further:

```swift
router.text("ping") { _ in "pong" }                     // exact match
router.text(prefix: "!roll") { _ in "🎲" }              // prefix
router.text(matching: /order-(\d+)/) { _ in "order!" }  // regex
```

### Callback Queries

Callback routes use path-style patterns with `{parameter}` segments, decoded
into ``TelerouteParameters``:

```swift
router.callback("orders/{id}/approve") { context in
    let id = try context.parameters.require("id")
    return .sequence([
        .answerCallback("Approved"),
        .edit("Order \(id) approved"),
    ])
}
```

Handled callback queries are auto-answered so buttons never keep spinning;
see <doc:Responses> for how to opt out. For compile-time-safe callbacks that
decode into a struct, see <doc:TypedRoutesAndMacros>.

### Typed Update-Kind Handlers

Every non-message update kind has payload-first sugar — the decoded payload is
handed to you together with the context:

```swift
router.inlineQuery { query, context in
    try await context.bot.answerInlineQuery(inlineQueryId: query.id, results: [])
}
router.preCheckoutQuery { query, context in
    try await context.bot.answerPreCheckoutQuery(preCheckoutQueryId: query.id, ok: true)
}
router.chatMember { updated, context in ... }
router.chatJoinRequest { request, context in try await context.approveJoinRequest() }
router.messageReaction { reaction, context in
    try await context.send("Thanks!", to: .id(reaction.chat.id))
}
router.poll { poll, _ in ... }
router.pollAnswer { answer, _ in ... }
```

Also available: `myChatMember`, `chosenInlineResult`, `shippingQuery`,
`messageReactionCount`, `businessConnection`, and `purchasedPaidMedia`. For
kinds without dedicated sugar, register on the raw kind:

```swift
router.on(.chatBoost, .removedChatBoost) { context in
    try await context.send("Boost status changed — thank you!")
}
```

### The Unmatched Hook

The `unmatched` hook is the final stage — use it for fallback replies or
diagnostics. Return `.unhandled` to stay silent:

```swift
router.unmatched { context in
    context.updateKind == .message ? .reply("I don't understand") : .unhandled
}
```

### Channel Discussion Forwards

When a channel has a linked discussion chat, Telegram copies each new post
into it as an automatic forward; replying to that copy comments under the
post. ``TelerouteConfiguration/discussionForwards`` tracks these copies by
default, so a bot can await the copy of a post it published:

```swift
let post = try await bot.client.sendMessage(chatId: .id(channelId), text: "Chapter 69")
if let forward = try await bot.discussionMessage(for: post) {
    try await bot.client.sendMessage(
        chatId: .id(forward.discussionChatId),
        text: "Discuss here",
        replyParameters: .init(messageId: forward.discussionMessageId)
    )
}
```

``TelerouteBot/discussionMessage(for:timeout:)`` returns `nil` straight away
when the channel has no linked chat, finds a copy that arrived before the call
while it is retained, and throws ``TelerouteDiscussionForwardError`` on
timeout. Request contexts offer the same call.
``TelerouteBot/sendWithDiscussionForward(timeout:_:)`` sends and waits in one
step, returning `(post, forward)`; if waiting fails after the post went out,
the thrown ``TelerouteDiscussionPostError`` still carries the post. Tracking does not change
`allowed_updates`; the bot must already ask for `message` — any command or
message route does — or the first wait logs a warning.

To react to every automatic forward, register an observer:

```swift
router.onDiscussionForward { forward, context in
    context.logger.info("post \(forward.channelMessageId) was forwarded")
}
```

Observers are not routes: they run before replay protection and routing for
every automatic forward, so a command route cannot swallow a post starting
with `/`. They leave the update's outcome alone, skip guards and core
middleware, and report a thrown error to ``TelerouteConfiguration/onError``.
The bot must see the discussion chat's messages (administrator, or privacy
mode disabled).

### Allowed Updates Are Derived Automatically

Teleroute inspects the registered routes and asks Telegram for exactly the
update kinds it can handle (`allowed_updates`). Registering an `unmatched`
hook widens the request to every kind; registering an `onDiscussionForward`
observer adds `message`. Override the behavior through
``TelegramPollingConfiguration``:

```swift
let configuration = TelerouteConfiguration(
    polling: .init(allowedUpdates: .explicit([.message, .callbackQuery]))
)
```

See ``TelerouteAllowedUpdates`` for the `.automatic` / `.all` / `.explicit`
modes, and ``TelerouteBot/resolvedAllowedUpdates(_:)`` to obtain the resolved
wire strings for a custom `setWebhook` call.

### Organize Routes into Collections

Larger bots split features into reusable ``TelerouteRouteCollection`` values
that register their own routes and may export typed route handles:

```swift
struct OrdersFeature: TelerouteRouteCollection {
    let store: OrderStore

    func addRoutes(to routes: TelerouteRouterGroup<TelerouteContext>) {
        routes.command("orders") { _ in "You have no orders." }
        routes.callback("orders/{id}/cancel") { context in
            .answerCallback("Cancelled \(context.parameters["id"] ?? "?")")
        }
    }
}

router.addRoutes(OrdersFeature(store: store))
```

Groups add a shared path prefix plus inherited middleware and guards:

```swift
router.group("admin") { admin in
    admin.guards.add(TelerouteAdminGuard(deny: .reply("Admins only")))
    admin.command("ban") { _ in "..." }       // matches /admin_ban
    admin.callback("users/{id}") { _ in "" }  // matches admin/users/{id}
}
```

See <doc:MiddlewareAndGuards> for inheritance rules and
<doc:ContextsAndHelpers> for groups with refined child contexts.

### Duplicate Route Detection

Registering two unguarded routes with the same signature is almost always a
bug. Inspect ``TelerouteRouterGroup/duplicateRouteSignatures`` at startup (or
assert on it in tests) to catch collisions early.
