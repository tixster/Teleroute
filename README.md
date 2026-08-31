# Teleroute

[![Linux CI](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml/badge.svg?branch=main)](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/tixster/Teleroute/blob/main/LICENSE)
[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-F05138?logo=swift&logoColor=white)](https://swift.org)

Teleroute is a route-style Swift framework for the Telegram Bot API, designed
after Hummingbird 2:

- `Teleroute` builds a bot-independent route graph over typed request contexts;
- `TelerouteBot` owns the Telegram client, lifecycle, and update runtime, and
  conforms to `Service` (swift-service-lifecycle);
- handlers return any `TelerouteResponseGenerator` — a `String`, a chainable
  `Reply(...)`, a full `TelerouteResponse`, or `.unhandled` to fall through;
- **the entire Bot API** ships as typed flat methods (185 operations) generated
  from an OpenAPI specification, plus the raw generated client underneath.

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
    token: ProcessInfo.processInfo.environment["TELEGRAM_BOT_TOKEN"]!,
    router: router,
    logger: Logger(label: "bot")
)
try await bot.runService()   // SIGTERM/SIGINT → graceful drain + shutdown
```

## Requirements

- Swift 6.3
- macOS 15+

## Installation

```swift
dependencies: [
    .package(url: "https://github.com/tixster/Teleroute.git", from: "2.0.0"),
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
- `TelegramBotAPI` — the raw OpenAPI-generated types and client;
- `TelerouteHummingbird` — webhook integration for Hummingbird 2 apps.

## The Client: the Whole Bot API

`TelegramBotClient` exposes one flat, fully typed method per Bot API operation,
generated from the OpenAPI spec (see [openapi/README.md](openapi/README.md)):

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
`retry_after`. The raw generated surface stays reachable via `context.bot.api`
(`import TelegramBotAPI` for the `Components`/`Operations` namespaces).

Built-in client policies (all configurable on `TelegramBotClient` /
`TelerouteBot` initializers):

- global 30 req/s token-bucket rate limit;
- bounded automatic retry on 429 flood-wait responses;
- optional per-chat send pacing (1 msg/s per chat, 20 msg/min per group);
- `ChatId` literals: `to: 123` and `to: "@channel"` both work.

## Routing

Every update kind is routable. Dispatch order per update:
replay-protection → flows → callbacks → commands → message routes →
update-kind routes → `unmatched` hook.

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

Every request context (including custom and flow contexts) carries the full
helper surface: `reply`, `send`, `edit`, `editCaption`, `editReplyMarkup`,
`deleteMessage`, `forwardMessage`, `copyMessage`, `react`, `pinMessage`,
`sendPhoto`/`Video`/`Audio`/`Voice`/`Sticker`/`MediaGroup`/`Location`/`Contact`/`Dice`,
`sendChatAction`/`typing()`/`withChatAction`, `banMember`/`unbanMember`/
`restrictMember`, `getChatMember`/`isAdmin`, `approveJoinRequest`,
`publishCommands`, and flow control (`start`/`cancelFlow`). Anything else:
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

```swift
let markup = try router.keyboard {
    Row {
        route.button(OrderPageCallback(orderId: "7", page: 2), "Next")
        TelerouteButton.url("Docs", "https://example.com")
    }
    TelerouteButton.switchInlineQuery("Share", query: "cats")
}

let replyKeyboard = ReplyKeyboardMarkup(resize: true) {
    KeyRow {
        KeyButton("Share contact").requestContact()
        "Cancel"
    }
}
```

Typed callback buttons are validated against the scope that renders them, so a
button for an unregistered route fails fast. `TelegramText` provides
`escapeHTML`/`escapeMarkdownV2` and `bold`/`italic`/`code`/`link`/`mention`
fragment builders.

## Flows

Multi-step conversations with per-chat/user session state:

```swift
struct SignupFlow: TelerouteFlow {
    enum Step: String { case name, confirm }

    func boot(flow: TelerouteFlowGroup<SignupFlow>) {
        flow.start("signup", at: .name) { context in
            try await context.reply("Send your name.")
        }
        flow.message(at: .name) { context in
            try await context.transition(to: .confirm, merging: ["name": context.message?.text ?? ""])
            try await context.reply("Confirm?")
        }
        flow.command("done", at: .confirm) { context in
            try await context.finish()
            try await context.reply("Welcome, \(try context.values.require("name"))!")
        }
    }
}
router.flow(SignupFlow())
```

Flow contexts conform to `TelerouteRequestContext`, so every helper (media,
admin, …) is available inside steps.

## Lifecycle and Webhooks

`TelerouteBot` is a `Service`. Long polling is the default mode; graceful
shutdown stops intake, drains in-flight handlers (bounded by
`shutdownGracePeriod`), and then cancels stragglers.

```swift
// Standalone: signals → graceful shutdown.
try await bot.runService()

// Composed with other services:
let group = ServiceGroup(
    services: [database, bot],
    gracefulShutdownSignals: [.sigterm, .sigint],
    logger: logger
)
try await group.run()
```

Webhooks via the `TelerouteHummingbird` product:

```swift
import Hummingbird
import TelerouteHummingbird

let bot = try TelerouteBot(token: token, router: router, logger: logger, mode: .webhook)
let hbRouter = Router()
hbRouter.registerTelegramWebhook(bot: bot, path: "/telegram", secretToken: secret)
let app = Application(router: hbRouter, configuration: .init(address: .hostname("0.0.0.0", port: 8080)))

let group = ServiceGroup(
    services: [
        app,
        bot,
        TelegramWebhookService(bot: bot, configuration: .init(
            url: "https://bot.example.com/telegram",
            secretToken: secret
        )),
    ],
    gracefulShutdownSignals: [.sigterm, .sigint],
    logger: logger
)
try await group.run()
```

The webhook handler verifies `X-Telegram-Bot-Api-Secret-Token` in constant
time and feeds decoded updates into the same pipeline (`bot.process(_:)` is
the seam for any custom server).

## Observability

- `bot.eventStream()` — an `AsyncSequence` of routing lifecycle events
  (received / handled / unmatched / duplicate / failed with timings);
- `TelerouteMetricsSink` — protocol for custom sinks;
- `TelerouteSwiftMetricsSink` — swift-metrics adapter emitting
  `teleroute.updates.*` counters and `teleroute.handler.duration` timers.

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

## Migrating from 1.x

See [docs/MIGRATION-2.0.md](docs/MIGRATION-2.0.md) for the 1.x → 2.0 table
(single handler style, `TG`-free naming, `ChatId` targets, Int64 identifiers,
Service lifecycle).

## Agent Skill Installation

The repository ships a Claude Code skill for working on Teleroute at
`skills/teleroute`; symlink or copy it into `.claude/skills/` of a consuming
project to get Teleroute-aware assistance.
