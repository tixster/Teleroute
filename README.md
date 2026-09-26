# Teleroute

[![Linux CI](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml/badge.svg?branch=main)](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml)
[![Documentation](https://img.shields.io/badge/Documentation-DocC-blue)](https://tixster.github.io/Teleroute/documentation/teleroute/)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/tixster/Teleroute/blob/main/LICENSE)
[![Swift 6.4](https://img.shields.io/badge/Swift-6.4-F05138?logo=swift&logoColor=white)](https://swift.org)

Teleroute is a route-style Swift framework for the Telegram Bot API, designed
after Hummingbird 2:

- `Teleroute` builds a bot-independent route graph over typed request contexts;
- `TelerouteBot` owns the Telegram client, lifecycle, and update runtime, and
  conforms to `Service` (swift-service-lifecycle);
- handlers return any `TelerouteResponseGenerator` — a `String`, a chainable
  `Reply(...)`, a full `TelerouteResponse`, or `.unhandled` to fall through;
- **the entire Bot API** ships as typed flat methods (185 operations) and flat
  model types, generated directly from Telegram's own documentation.

```swift
import Teleroute

let router = Teleroute()

router.command("ping") { _ in "pong" }

router.text(prefix: "!roll") { _ in
    Reply("🎲 \(Int.random(in: 1...6))").quoting("rolled")
}

router.message(.photo) { context in
    "Nice photo, \(context.message?.from?.firstName ?? "friend")!"
}

router.messageReaction { reaction, context in
    try await context.send("Thanks!", to: .id(reaction.chat.id))
}

router.callback("orders/{id}/approve") { context in
    .sequence([
        .answerCallback("Approved"),
        .edit("Order \(context.parameters["id"] ?? "?") approved"),
    ])
}

let bot = try TelerouteBot(
    token: TelerouteEnvironment.token(),   // TELEGRAM_BOT_TOKEN
    router: router
)
try await bot.runService()   // SIGTERM/SIGINT → graceful drain + shutdown
```

## Requirements

- Swift 6.4
- macOS 15+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/tixster/Teleroute.git", from: "3.1.0"),
],
targets: [
    .executableTarget(
        name: "MyBot",
        dependencies: [
            .product(name: "Teleroute", package: "Teleroute"),
            // Only when using @TelerouteCommand / @TelerouteCallback:
            // .product(name: "TelerouteMacros", package: "Teleroute"),
        ]
    ),
    .testTarget(
        name: "MyBotTests",
        dependencies: [
            "MyBot",
            .product(name: "TelerouteTestSupport", package: "Teleroute"),
        ]
    ),
]
```

Additional products:

- `TelegramBotKit` — the standalone Telegram client (vocabulary types,
  `TelegramBotClient` with all 185 flat methods, rate limiting, flood-wait
  retry, per-chat pacing) without the router;
- `TelegramBotAPI` — every documented Bot API type, under its own name
  (`Message`, `ChatMember`, `ChatId`, …);
- `TelerouteHummingbird` — webhook integration for Hummingbird 2 apps.

## The Client: the Whole Bot API

`TelegramBotClient` exposes one flat, fully typed method per Bot API operation,
generated from a committed snapshot of Telegram's documentation
(see [botapi/README.md](botapi/README.md)):

```swift
try await context.bot.sendPoll(
    chatId: .id(chatId),
    question: "Best color?",
    options: [.init(text: "Red"), .init(text: "Blue")]
)
try await context.bot.banChatMember(chatId: "@group", userId: 42)
try await context.bot.answerPreCheckoutQuery(preCheckoutQueryId: id, ok: true)
try await context.bot.sendVideo(
    chatId: .id(chatId),
    video: .upload(filename: "clip.mp4", data: data)   // or .fileID / .url
)
```

Every method unwraps Telegram's `{ok, result}` envelope; failures throw
`TelegramAPIError` with the decoded `error_code`, `description`, and
`retry_after`. Anything Telegram ships before Teleroute regenerates is still
reachable through `context.bot.call("someNewMethod", ["chat_id": 1])`.

Model types are plain structs and enums under their own names — `Message`,
`Update`, `ChatMember`, `ChatId` — in scope from `import Teleroute`.
`BotAPIVersion.version` reports which Bot API revision they were generated from.

Built-in client policies (all configurable on `TelegramBotClient` /
`TelerouteBot` initializers):

- global 30 req/s token-bucket rate limit;
- bounded automatic retry on 429 flood-wait responses;
- optional per-chat send pacing (1 msg/s per chat, 20 msg/min per group);
- `ChatId` literals: `to: 123` and `to: "@channel"` both work.

## Routing

Every update kind is routable. Dispatch order per update:
discussion-forward observers → replay-protection → flows → callbacks →
commands → message routes → update-kind routes → `unmatched` hook.

```swift
// Commands (also /admin_ban style names via groups).
router.command("start", description: "Begin") { _ in "Welcome!" }

// Plain messages with source and content filters.
router.message(.text) { context in "echo: \(context.message?.text ?? "")" }
router.message(.document, from: [.message, .business]) { _ in "Got a file" }
router.text("ping") { _ in "pong" }
router.text(matching: /order-(\d+)/) { _ in "order!" }

// Typed update-kind handlers (payload first).
router.inlineQuery { query, context in ... }
router.preCheckoutQuery { query, context in ... }
router.chatMember { updated, context in ... }
router.chatJoinRequest { request, context in try await context.approveJoinRequest() }
router.poll { poll, _ in ... }
router.on(.chatBoost, .removedChatBoost) { context in ... }

// Final hook when nothing matched; `.unhandled` falls through.
router.unmatched { context in
    context.updateKind == .message ? .reply("I don't understand") : .unhandled
}
```

`allowed_updates` is derived automatically from the registered routes (override
with `TelegramPollingConfiguration(allowedUpdates: .all/.explicit(...))`).

## Responses

Handlers return any `TelerouteResponseGenerator`:

```swift
router.command("hi") { _ in "hello" }                       // String → reply
router.command("fancy") { _ in
    Reply("<b>Done</b>").parseMode(.html).silent().quoting("summary")
}
router.command("classic") { _ in .send("Posted", to: "@channel") }
router.command("chain") { _ in
    [TelerouteResponse.answerCallback("Ok"), .edit("Done")]  // array → sequence
}
router.command("quiet") { context in                        // Void → done
    try await context.sendChatAction(.typing)
}
```

`reply` attaches `reply_parameters`, so replies are visibly linked to the
incoming message. A configured `defaultParseMode` applies to every text helper.
Handled callback queries are auto-answered so buttons never keep spinning
(`autoAnswerCallbackQueries: false` or `context.skipCallbackAutoAnswer()` to
opt out).

## Context Helpers

Every `TelerouteRequestContext` — the built-in one, your own, and flow step
contexts — carries the full helper surface: `reply`, `send`, `edit`,
`editCaption`, `editReplyMarkup`,
`removePressedButton`, `deleteMessage`, `forwardMessage`, `copyMessage`,
`react`, `pinMessage`,
`sendPhoto`/`Video`/`Audio`/`Voice`/`Sticker`/`MediaGroup`/`Location`/`Contact`/`Dice`,
`sendChatAction`/`typing()`/`withChatAction`, `banMember`/`unbanMember`/
`restrictMember`, `getChatMember`/`isAdmin`, `approveJoinRequest`,
`publishCommands`, `keyboard { }`/`render`, `resolvedEditTarget`,
`discussionMessage(for:)`/`sendWithDiscussionForward` (see
[Channel Discussion Forwards](#channel-discussion-forwards)), and flow control
(`start`/`cancelFlow`).

```swift
router.command("hi") { context in
    // `user` resolves for every update kind that carries one — including a
    // callback query, where `message?.from` is the bot, not the presser.
    "Hello, \(context.user?.firstName ?? "friend")!"
}

router.command("promote") { context in
    let admin = try context.requireUser()   // throws instead of guard-per-handler
    context.logger.info("promoting")        // carries update_id, chat_id, user_id
    return "\(admin.firstName) promoted"
}
```

`require*` covers `requireMessage`, `requireChatId`, `requireUser`,
`requireUserId`, `requireCallbackQuery`, and `requireCommand`; each throws a
`TelerouteError` through the router's normal error pipeline. For Bot API
arguments the helpers do not expose, `withResolvedChat { bot, chatId in … }`
hands you the full client without re-deriving the chat. Anything else:
`context.bot.<operation>`.

## Groups, Contexts, Middleware, Guards

```swift
struct AppContext: TelerouteInitializableRequestContext {
    let coreContext: TelerouteContext
    var user: User?
    init(source: TelerouteContextSource) { self.coreContext = source.coreContext }
}

let router = Teleroute(context: AppContext.self)
router.middlewares.add(AuthMiddleware())          // middleware over AppContext

router.group("admin", context: AdminContext.self) { admin in   // child context
    admin.guards.add(TelerouteAdminGuard(deny: .reply("Admins only")))
    admin.command("ban") { context in "Banned by \(context.adminName)" }
}
```

One middleware protocol serves every level:

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
```

Middleware is snapshotted when a route is registered — **add middleware before
registering the routes that should use it**.

Guards return a verdict: `.allow`, `.skip` (silent fall-through), or
`.deny(response)`. Handlers may also `throw TelerouteAbort("Access denied")` —
rendered to the user and reported as handled. A configuration-level
`errorRenderer` converts unexpected errors into user-facing responses.

Built-in middleware: access log, timeout, retry, error handling, throttle,
debounce. Built-in guards: chat type, private/group, user/chat allow-lists,
argument count, admin (each with an optional `deny:` response).

## Typed Commands, Callbacks, and Macros

```swift
@TelerouteCommand("transfer")
struct TransferCommand {
    let userId: Int64          // required, decoded & validated
    var amount: Double = 1.0   // optional with default
    let comment: String?       // optional
}

@TelerouteCallback("orders/{orderId}/page/{page}")
struct OrderPageCallback {
    let orderId: String
    let page: Int              // non-String path parameters round-trip
}

router.command(TransferCommand.self) { command, context in
    "Sending \(command.amount) to \(command.userId)"
}
let route = router.callback(OrderPageCallback.self) { callback, _ in
    .edit("Page \(callback.page)")
}
```

Malformed arguments throw `TelerouteError.invalidParameter` before your
handler runs. Self-handling types (`TelerouteHandlingCommand`/`Callback`)
declare their own `Context` and return a response.

## Keyboards

Build the markup right where you answer — `Reply`, `Send`, and `Edit` all take
the keyboard builder, and render it against the router serving the update:

```swift
router.command("orders") { _ in
    Reply("Your orders:").keyboard {
        Row {
            TelerouteButton("Next") { OrderPageCallback(orderId: "7", page: 2) }
            TelerouteButton("Docs", url: "https://example.com")
        }
        TelerouteButton.switchInlineQuery("Share", query: "cats")
    }
}
```

A button can also carry its handler directly (opt in with
`configuration: .init(inlineActions: .enabled())`):

```swift
router.command("orders") { _ in
    Reply("Order 7").keyboard {
        Row {
            TelerouteButton("Approve") { press in
                try await orders.approve(7)
                return .edit("Order 7 approved")
            }
            // Clears itself once the handler returns cleanly.
            TelerouteButton("Snooze", onSuccess: .removeButton) { _ in
                .answerCallback("Snoozed")
            }
        }
    }
}
```

Inline handlers are closures, so they live in memory: they expire (30 min by
default), do not survive a restart, and do not work across replicas — a dead
press gets the configured `expired` response. By default only the user the
keyboard was rendered for can press them.

`context.keyboard { … }` returns the markup directly when a handler sends its
own messages, and `router.keyboard { … }` still builds one ahead of time.

Laying out longer menus:

```swift
Reply("Pick an order:").keyboard {
    orders.map { route.button(Open(id: $0.id), $0.title) }.grid(columns: 2)
    Row {
        TeleroutePagination.pageStrip(route, page: page, pageCount: pages) {
            OrderPageCallback(orderId: id, page: $0)
        }
    }
    Row { TelerouteConfirm.row(confirm, confirm: .yes, cancel: .no) }
}
```

```swift
let replyKeyboard = ReplyKeyboardMarkup(resize: true) {
    KeyRow {
        KeyButton("Share contact").requestContact()
        KeyButton("Pick a chat").requestChat(id: 1, isChannel: false)
        "Cancel"
    }
}
```

Typed callback buttons are validated when the keyboard renders, so a button
for an unregistered route fails fast — and `callback_data` over Telegram's
64-byte limit is rejected at render time rather than by the API. A callback
registered inside a group resolves from anywhere, so a handler at the root can
still build a button for it.
`TelegramText` provides `escapeHTML`/`escapeMarkdownV2` and
`bold`/`italic`/`code`/`link`/`mention` fragment builders.

## Flows

Multi-step conversations with per-chat/user session state:

```swift
struct SignupFlow: TelerouteFlow {
    enum Step: String, CaseIterable { case name, email, confirm }

    func boot(flow: TelerouteFlowGroup<SignupFlow>) {
        flow.start("signup", at: .name, asking: "Send your name.")

        // ask = prompt + capture + validate + store + advance. With a
        // CaseIterable Step the next step is inferred from declaration order.
        flow.ask(.name, store: "name", next: "And your email?")
        flow.ask(.email, store: "email", next: "Confirm with /done.")

        flow.command("done", at: .confirm) { context in
            try await context.finish()
            try await context.reply("Welcome, \(try context.values.require("name"))!")
        }

        // The flow is told when something ends it that it did not ask for.
        flow.onEnd { context, reason in
            guard case let .interrupted(command) = reason else { return }
            try? await context.reply("Paused by /\(command). /resume to continue.")
        }

        // ...and decides what an unrelated command should do to it.
        flow.onInterrupt { _, command in
            command.name == "help" ? .keep : .suspend
        }
    }
}
router.flow(SignupFlow())
```

Every ending reaches `onEnd` with a reason — `.finished`, `.cancelled`,
`.interrupted(command:)`, `.expired`, or `.replaced(by:)` — so a flow can say
goodbye or clean up. `onInterrupt` decides per flow what an unhandled command
does: `.cancel`, `.keep`, `.suspend`, or `.handled(response)` to answer from the
flow and swallow the command entirely. Without either hook the configured
`flowCancellationPolicy` behaves exactly as before.

`suspendFlow()` / `resumeFlow()` park a conversation instead of discarding it:
the session stays, stops intercepting, and keeps counting toward its TTL.

For state beyond string keys, declare a `FlowState`:

```swift
struct FlowState: Codable, Sendable { var name = ""; var attempts = 0 }

try await context.transition(to: .confirm, state: .init())
let state = try context.requireState()
```

It is persisted inside the existing flow values under a reserved key, so every
`TelerouteFlowStorage` keeps working unchanged.

A flow step context **is** a `TelerouteRequestContext`, so every helper above
works inside a step — media, moderation, reactions, keyboards, `logger` —
alongside the flow ones (`transition`, `finish`, `cancel`, `values`):

```swift
flow.message(at: .photo) { context in
    try await context.sendPhoto(.fileID(id), caption: "Saved")
    try await context.react("👍")
}
```

Sessions can expire, so an abandoned conversation stops capturing its chat.
Opt in globally or per flow; expiry slides forward on every write:

```swift
TelerouteConfiguration(flowSessionTTL: .seconds(30 * 60))
struct SignupFlow: TelerouteFlow { static let sessionTTL: Duration? = .seconds(10 * 60) }
```

Values decode in place — `try context.values.require("amount", as: Double.self)`
— and `finish()` vs `cancel()` are reported distinctly to the metrics sink, so
completion and abandonment are measurable. For a shared store, persist sessions
with `TelerouteFlowSessionCoding` and key them by `TelerouteFlowKey.storageKey`
rather than inventing a format.

## Channel Discussion Forwards

When a channel has a linked discussion chat, Telegram copies every new post
into that chat as an automatic forward. Replying to the copy comments under
the post. Tracking is on by default, so a bot can await the copy of a post it
just published:

```swift
let post = try await bot.client.sendMessage(chatId: .id(channelId), text: "Chapter 69")
if let forward = try await bot.discussionMessage(for: post, timeout: .seconds(20)) {
    try await bot.client.sendMessage(
        chatId: .id(forward.discussionChatId),
        text: "Discuss here",
        replyParameters: .init(messageId: forward.discussionMessageId)
    )
}
```

`discussionMessage` looks the linked chat up with `getChat` (cached for
`linkedChatCacheTTL`) and returns `nil` straight away when the channel has
none. A copy that arrives before you start waiting — a webhook can beat the
`sendMessage` response — is still found while it is retained
(`retention`/`capacity`). It throws `TelerouteDiscussionForwardError`:
`.timeout`, `.notAChannelPost`, `.trackingDisabled` (after
`discussionForwards: .disabled`), or `.shutdown`; cancelling the waiting task
throws `CancellationError`. Tune the buffer with
`.enabled(retention:capacity:linkedChatCacheTTL:)`. The same call is available
on every request context: `try await context.discussionMessage(for: post)`.

To send and wait in one step, pass the send call to `sendWithDiscussionForward`
— any send method returning one `Message` works:

```swift
let (post, forward) = try await bot.sendWithDiscussionForward { client in
    try await client.sendPhoto(chatId: .id(channelId), photo: .upload(filename: "cover.jpg", data: cover))
}
```

It throws `.trackingDisabled` before sending anything when tracking is off, and
passes the send's own error through. Once the post is out, a failed wait
throws `TelerouteDiscussionPostError`, which carries the sent `post` and the
`underlying` reason, so the published message is never lost. Request contexts
offer it too.

To react to every automatic forward instead, register an observer:

```swift
router.onDiscussionForward { forward, context in
    context.logger.info("post \(forward.channelMessageId) → \(forward.discussionMessageId)")
}
```

Observers are not routes. They run before replay protection and routing, for
every automatic forward, so a command route cannot swallow a post that starts
with `/`; they do not change the update's handled/unmatched outcome, guards
and core middleware do not apply, and a thrown error goes to `onError` without
stopping routing. Observers work with tracking disabled.

Automatic forwards arrive as plain messages, so the bot has to ask for
`message` updates. Tracking does not change `allowed_updates`: any command or
message route already asks for them, and registering an observer adds
`message`. If neither does, the first `discussionMessage` call logs a warning.
The bot also has to see the discussion chat's messages — make it an
administrator there or disable its privacy mode.

## Lifecycle and Webhooks

`TelerouteBot` is a `Service`. Long polling is the default mode; graceful
shutdown stops intake, drains in-flight handlers (bounded by
`shutdownGracePeriod`), and then cancels stragglers.

```swift
// Standalone: signals → graceful shutdown.
try await bot.runService()

// Composed with other services:
try await bot.runService(with: [database, worker])
```

Webhooks via the `TelerouteHummingbird` product:

```swift
import Hummingbird
import TelerouteHummingbird

let webhook = TelegramWebhookConfiguration(
    url: "https://bot.example.com/telegram",
    secretToken: .randomSecret()
)
let bot = try TelerouteBot(token: token, router: router, mode: .webhook)

let app = Application.teleroute(
    bot: bot,
    webhook: webhook,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
) { router in
    router.get("/health") { _, _ in "ok" }
}
try await app.runService()
```

One configuration drives everything: the endpoint path comes from the URL, so
there is no second string to keep in sync, and the bot plus its `setWebhook`
registration are attached as services in the right order.

With a router of your own, register and collect the services in one call:

```swift
let hbRouter = Router()
hbRouter.get("/health") { _, _ in "ok" }

let app = Application(
    router: hbRouter,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080)),
    services: hbRouter.addTeleroute(bot, webhook: webhook)
)
try await app.runService()
```

`app.addTeleroute(bot, webhook:)` covers the case where the application
already exists. The webhook handler verifies
`X-Telegram-Bot-Api-Secret-Token` in constant time and feeds decoded updates
into the same pipeline (`bot.process(_:)` is the seam for any custom server).

## Observability

- `bot.eventStream()` — an `AsyncSequence` of routing lifecycle events
  (received / handled / unmatched / duplicate / failed with timings);
- `context.logger` — a request-scoped `Logger` carrying `update_id`, `chat_id`,
  `user_id`, `route_kind`, and, inside a flow, `flow_id` / `flow_step`;
- `TelerouteMetricsSink` — protocol for custom sinks;
- `TelerouteSwiftMetricsSink` — swift-metrics adapter emitting
  `teleroute.updates.*` counters, `teleroute.handler.duration` timers, and
  `teleroute.flows.ended` / `teleroute.flow.age` for flow outcomes.

## In-Process Testing

`TelerouteTestSupport` fakes the HTTP transport under the real generated
client — no network, byte-accurate assertions:

```swift
@Test func startCommand() async throws {
    let router = Teleroute()
    router.command("start") { _ in "Welcome" }

    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
    try await bot.test { client in
        let result = await client.sendCommand("start")
        #expect(result.terminalEvent?.kind == .handled)
    }
    guard case let .sentMessage(message) = telegram.effects.first else { return }
    #expect(message.text == "Welcome")
}
```

Synthetic update factories cover commands, messages, photos, callbacks, inline
queries, reactions, member updates, join requests, pre-checkout queries, and
poll answers. `TelerouteRecordingTransport` accepts a `fallback:` to stub any
of the 185 operations, and `TelerouteTestMultipart` parses multipart bodies
for wire-level assertions.

## Example Project

`Sources/TelerouteExample` is a runnable bot showing commands, text and media
routes, reactions, join-request approval, inline mode, keyboard DSL, flows over
a custom context, and command-menu publishing:

```bash
TELEGRAM_BOT_TOKEN=<token> swift run TelerouteExample
```

## Agent Skill Installation

The repository ships a Claude Code skill for working on Teleroute at
`skills/teleroute`; symlink or copy it into `.claude/skills/` of a consuming
project to get Teleroute-aware assistance.
