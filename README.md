# Teleroute

[![Linux CI](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml/badge.svg?branch=main)](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/tixster/Teleroute/blob/main/LICENSE)
[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-F05138?logo=swift&logoColor=white)](https://swift.org)

Teleroute is a route-style layer for [swift-telegram-bot](https://github.com/nerzh/swift-telegram-bot).

It provides:

- string and typed command routes
- string and typed callback routes
- nested route scopes
- reusable feature modules
- guards and middleware
- stateful multi-step flows
- command queues, replay protection, events, and metrics

## Requirements

- Swift 6.3
- macOS 15+
- swift-telegram-bot 10.0+

## Installation

```swift
// swift-tools-version: 6.3
import PackageDescription

let package = Package(
    name: "MyBot",
    dependencies: [
        .package(url: "https://github.com/tixster/Teleroute.git", from: "1.0.0"),
    ],
    targets: [
        .executableTarget(
            name: "MyBot",
            dependencies: [
                .product(name: "Teleroute", package: "Teleroute"),
            ]
        )
    ]
)
```

## Quick Start

```swift
import Logging
import Teleroute

let bot = try await TGBot(
    connectionType: .longpolling(),
    tgClient: TGClientDefault(),
    botId: "<token>",
    log: Logger(label: "telegram.bot")
)

let router = Teleroute(
    bot: bot,
    logger: Logger(label: "telegram.router")
)

router.command("ping") { context in
    try await context.reply("pong")
}

router.callback("orders/{id}/approve") { context in
    let id = try context.parameters.require("id")
    try await context.answerCallbackQuery("Approved \(id)")
}

try await router.attach()
_ = try await bot.start()
```

`router.attach()` registers the router with the bot passed to its initializer;
repeated calls are safe. All route registration and typed callback rendering
happens through `router` or a nested `TelerouteRoutes` scope.

## Configuration

Advanced dependencies and policies live in one configuration value:

```swift
let router = Teleroute(
    bot: bot,
    logger: logger,
    configuration: .init(
        flowStorage: DatabaseFlowStorage(),
        replayProtectionStorage: RedisReplayProtectionStorage(),
        replayProtectionTTL: .seconds(5),
        flowCancellationPolicy: .manual,
        metricsSink: MetricsSink(),
        onError: { error, context in
            try? await context.reply("Something went wrong: \(error)")
        }
    )
)
```

Every argument has a default. Pass `replayProtectionStorage: nil` to disable
replay protection.

## Routes and Scopes

Commands match Telegram messages beginning with `/`:

```swift
router.command("start", botUsername: "my_bot") { context in
    try await context.reply("hello")
}
```

`botUsername` restricts the route to commands such as `/start@my_bot`.

Callbacks use path patterns with required placeholders:

```swift
router.callback("users/{id}/ban") { context in
    let id = try context.parameters.require("id")
    try await context.answerCallbackQuery("Banned \(id)")
}
```

Create a nested scope to share prefixes, guards, and middleware:

```swift
router.group(
    "admin",
    middlewares: [TelerouteAccessLogMiddleware(label: "admin")],
    guards: [TelerouteAdminGuard()]
) { admin in
    admin.command("ban") { context in
        let userID = context.command?.arguments.first ?? "unknown"
        try await context.reply("Ban \(userID)")
    }

    admin.callback("users/{id}/ban") { context in
        let id = try context.parameters.require("id")
        try await context.answerCallbackQuery("Banned \(id)")
    }
}
```

The effective command is `/admin_ban`; callback data keeps slash hierarchy as
`admin/users/42/ban`.

## Typed Routes

Typed routes always own input decoding. Their behavior can either stay visible at
registration or opt into living on the decoded value itself:

```swift
struct BanCommand: TelerouteCommand {
    static let path = "ban"
    static let commandDescription: String? = "Ban a user"
    static let visibility: [TelerouteCommandVisibility] = [.allGroupChats]

    let userID: String
    let reason: String?

    init(command: TelerouteCommandMatch) throws {
        self.userID = try command.require("userID")
        self.reason = command.get("reason", at: 1)
    }
}

struct ApproveOrder: TelerouteCallback {
    static let path = "orders/{id}/approve"

    let id: String

    init(id: String) {
        self.id = id
    }

    init(parameters: TelerouteParameters) throws {
        self.id = try parameters.require("id")
    }

    var parameters: [String: String] {
        ["id": self.id]
    }
}

router.command(BanCommand.self) { command, context in
    try await context.reply("Ban \(command.userID)")
}

router.callback(ApproveOrder.self) { callback, context in
    try await context.answerCallbackQuery("Approved \(callback.id)")
}
```

Explicit handlers are the best default when a module/controller owns services or
coordinates several routes. For small self-contained routes, use the opt-in
self-handling protocols and register the type without a closure:

```swift
struct HelpCommand: TelerouteHandlingCommand {
    static let path = "help"

    init(command: TelerouteCommandMatch) throws {}

    func handle(context: TelerouteContext) async throws {
        try await context.reply("How can I help?")
    }
}

struct DismissCallback: TelerouteHandlingCallback {
    static let path = "notices/{id}/dismiss"

    let id: String

    init(parameters: TelerouteParameters) throws {
        self.id = try parameters.require("id")
    }

    var parameters: [String: String] { ["id": self.id] }

    func handle(context: TelerouteContext) async throws {
        try await context.answerCallbackQuery("Dismissed \(self.id)")
    }
}

router.command(HelpCommand.self)
router.callback(DismissCallback.self)
```

`TelerouteCommand` and `TelerouteCallback` remain decoding-only protocols;
self-handling is never forced on every typed route.

Typed command metadata can provide a default queue:

```swift
static let queue: TelerouteQueueScope? = .perChatAndUser
```

An explicit `queue:` passed during registration overrides the type default.

### Macros

The bundled macros synthesize decoding, callback encoding, and memberwise
initializers:

```swift
@TelerouteCommand("ban")
struct BanCommand {
    let userID: String
    let reason: String?
}

@TelerouteCallback("orders/{orderID}/approve")
struct ApproveOrder {
    let orderID: String
}
```

Macros also compose with self-handling routes:

```swift
@TelerouteCommand("hello")
struct HelloCommand: TelerouteHandlingCommand {
    let name: String

    func handle(context: TelerouteContext) async throws {
        try await context.reply("Hello, \(self.name)")
    }
}

router.command(HelloCommand.self)
```

Command properties are decoded by name, then by position. A callback placeholder
must have a stored required `String` property with the same name. Optional
callback placeholders are rejected at compile time because every generated
callback path must be renderable.

## Callback Data and Keyboards

Callback types are the single source of truth for button data. Typed
registration returns a `TelerouteCallbackRoute` handle bound to the exact scope
and router where the callback was registered:

```swift
@TelerouteCallback("users/{id}/ban")
struct BanUser {
    let id: String
}

let admin = router.group("admin")
let banUsers = admin.callback(BanUser.self) { callback, context in
    try await context.answerCallbackQuery("Banned \(callback.id)")
}

let button = try router.render(
    banUsers.button(BanUser(id: "42"), "Ban")
)
```

The button above still renders as `admin/users/42/ban` even though the root
router renders it: the handle carries its registration scope. It cannot be
rendered by a different `Teleroute` instance.

Self-handling callbacks return the same kind of handle, so registration and
keyboard construction stay connected without duplicating paths:

```swift
@TelerouteCallback("orders/{id}/reject")
struct RejectOrder: TelerouteHandlingCallback {
    let id: String

    func handle(context: TelerouteContext) async throws {
        try await context.answerCallbackQuery("Rejected \(self.id)")
        try await context.edit("Order \(self.id) rejected")
    }
}

@TelerouteCallback("orders/page/{page}")
struct OrdersPage: TelerouteHandlingCallback {
    let page: String

    func handle(context: TelerouteContext) async throws {
        try await context.answerCallbackQuery("Page \(self.page)")
        try await context.edit("Orders page \(self.page)")
    }
}

let rejectOrders = router.callback(RejectOrder.self)
let orderPages = router.callback(OrdersPage.self)

let keyboard = try router.keyboard([
    [
        rejectOrders.button(RejectOrder(id: "42"), "Reject #42", style: "danger"),
        rejectOrders.button(RejectOrder(id: "43"), "Reject #43", style: "danger"),
    ],
    TeleroutePagination.navigationRow(orderPages, page: 1, pageCount: 4) {
        OrdersPage(page: String($0))
    },
])
```

`callback.button("Title")` remains a compact option. `render` and `keyboard`
validate that its callback path was registered in that exact scope and throw
`callbackRouteNotRegistered` on mistakes. Prefer the route handle when a button
is built outside the controller that registered it or crosses group boundaries.
Creating a button description never registers a handler; registration still
belongs in startup composition.

Use `route.callbackData(for:)` when a Telegram API explicitly needs the encoded
string. `callbackData(for:)` on a router or scope remains the lower-level encoder.
Use `.raw(existingButton)` only for an already-created Telegram button that does
not participate in typed callback validation.

## Feature Modules and Controllers

`TelerouteModule` is the controller-style composition protocol. A practical
feature usually has four small parts:

- callback and command types are transport contracts;
- a controller owns dependencies, registration, and handlers;
- a screen/presenter receives route handles and builds keyboards;
- root composition chooses the feature's prefix and mounts it.

For example:

```swift
protocol InvoiceService: Sendable {
    func markPaid(id: String) async throws
}

@TelerouteCallback("invoice/{id}/pay")
struct PayInvoice {
    let id: String
}

struct BillingScreen: Sendable {
    let pay: TelerouteCallbackRoute<PayInvoice>

    func keyboard(
        invoiceID: String,
        in routes: TelerouteRoutes
    ) throws -> TGInlineKeyboardMarkup {
        try routes.keyboard([[
            self.pay.button(
                PayInvoice(id: invoiceID),
                "Mark paid",
                style: "success"
            ),
        ]])
    }
}

struct BillingController: TelerouteModule {
    let service: any InvoiceService

    func register(in routes: TelerouteRoutes) {
        let pay = routes.callback(PayInvoice.self, use: self.markPaid)
        let screen = BillingScreen(pay: pay)

        routes.command("invoice") { context in
            try await self.showInvoice(context, screen: screen, routes: routes)
        }
    }

    private func showInvoice(
        _ context: TelerouteContext,
        screen: BillingScreen,
        routes: TelerouteRoutes
    ) async throws {
        let id = context.command?.get("id") ?? "42"
        let keyboard = try screen.keyboard(invoiceID: id, in: routes)
        try await context.reply(
            "Invoice \(id)",
            replyMarkup: .inlineKeyboardMarkup(keyboard)
        )
    }

    private func markPaid(
        _ callback: PayInvoice,
        _ context: TelerouteContext
    ) async throws {
        try await self.service.markPaid(id: callback.id)
        try await context.answerCallbackQuery("Paid")
    }
}

router.group("billing").mount(
    BillingController(service: invoiceService)
)
```

This produces `/billing_invoice` and
`billing/invoice/{id}/pay`. The controller never repeats `"billing"`, so app
composition can mount the same feature under a different namespace. For a
screen with several actions, group its handles in a small `CallbackRoutes`
structure; `TelerouteExample` demonstrates that pattern for `/start`.

## Guards and Middleware

Every route and scope accepts arrays named `guards:` and `middlewares:`:

```swift
router.command(
    "start",
    guards: [TeleroutePrivateChatGuard()],
    middlewares: [TelerouteAccessLogMiddleware(label: "start")]
) { context in
    try await context.reply("Private chat only")
}
```

Built-in guards:

| Guard | Matches when |
| --- | --- |
| `TelerouteChatTypeGuard(_:)` | chat type equals the supplied value |
| `TeleroutePrivateChatGuard()` | update is from a private chat |
| `TelerouteGroupChatGuard()` | update is from a group or supergroup |
| `TelerouteUserAllowlistGuard(_:)` | sender is in the supplied user set |
| `TelerouteChatAllowlistGuard(_:)` | chat is in the supplied chat set |
| `TelerouteArgumentCountGuard(_:)` | command has the expected argument count |
| `TelerouteAdminGuard()` | sender is an administrator or owner |

Built-in middleware includes access logging, timeout, retry, error recovery,
throttle, and debounce:

```swift
router.callback(
    "orders/{id}/approve",
    middlewares: [
        TelerouteThrottleMiddleware(
            interval: .seconds(1),
            scope: .callbackData
        )
    ]
) { context in
    try await context.answerCallbackQuery("Approved")
}
```

Rate-limit scopes are `.chat`, `.user`, `.chatUser`, `.callbackData`, `.command`,
and `.custom`.

## Command Queues

Commands are concurrent unless a queue is requested:

```swift
router.command("sync", queue: .perChatAndUser) { context in
    try await context.reply("Sync started")
}
```

| Scope | Serialization key |
| --- | --- |
| `.global` | one queue for that command across the bot |
| `.perChat` | one queue per chat |
| `.perChatAndUser` | one queue per chat and user |

Flow entry commands accept the same `queue:` argument.

## Flows

Flows provide stateful routing scoped by `chatId + userId`:

```swift
@TelerouteCallback("confirm/{decision}")
struct SignupDecision {
    let decision: String
}

struct SignupFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case name
        case confirm
    }

    func boot(flow: TelerouteFlowGroup<SignupFlow>) {
        let decisions = flow.callback(
            SignupDecision.self,
            at: .confirm
        ) { callback, context in
            let name = try context.values.require("name")
            try await context.finish()
            try await context.reply("\(name): \(callback.decision)")
        }

        flow.start("signup", at: .name) { context in
            try await context.reply("Send your name")
        }

        flow.message(at: .name) { context in
            let name = context.message?.text ?? ""
            let keyboard = try flow.keyboard([[
                decisions.button(
                    SignupDecision(decision: "approve"),
                    "Approve"
                ),
            ]])

            try await context.transition(to: .confirm, merging: ["name": name])
            try await context.reply(
                "Confirm \(name)?",
                replyMarkup: .inlineKeyboardMarkup(keyboard)
            )
        }

    }
}

router.flow(SignupFlow())
```

`TelerouteFlowContext` supports `restart(at:values:)`,
`transition(to:merging:)`, `update(merging:)`, and `finish()`.

An unmatched Telegram command cancels an active flow by default. Configure
`.preserveOnUnmatchedCommand` or `.manual` when the session should remain active.
Custom storage should implement atomic `updateSession(for:_:)`; the built-in
in-memory storage already does.

## Published Commands

Route metadata can be synchronized with Telegram command menus:

```swift
router.command(
    "start",
    description: "Start the bot",
    visibility: [.allPrivateChats]
) { context in
    try await context.reply("hello")
}

try await router.syncPublishedCommands()
```

You can also publish explicit command sets:

```swift
try await router.publishCommands(
    [("profile", "Open profile"), ("logout", "Log out")],
    visibility: .allPrivateChats
)
```

Visibility supports `.default`, `.allPrivateChats`, `.allGroupChats`,
`.allChatAdministrators`, `.chat(...)`, `.chatAdministrators(...)`, and
`.chatMember(...)`.

## Events and Shutdown

Each call creates an independent, eagerly registered subscription:

```swift
let events = router.eventStream(buffering: .newest(1_000))

let observer = Task {
    for await event in events {
        switch event.kind {
        case .handled:
            print("Handled \(event.routeName ?? "unknown")")
        case .failed:
            print("Failed: \(String(describing: event.error))")
        default:
            break
        }
    }
}
```

Buffer policies are `.unbounded`, `.newest(_:)`, and `.oldest(_:)`. The default
is `.newest(512)` per subscriber.

Call `router.shutdown()` during teardown. It synchronously stops new processing,
cancels in-flight handlers and cleanup tasks, and finishes all event streams.
The operation is idempotent.

## Context Helpers

Handlers receive one `TelerouteContext`. The original update remains available as
`context.update`, alongside parsed values such as `command`, `parameters`,
`message`, `callbackQuery`, `callbackData`, `chatId`, `userId`, and `activeFlow`.

Common operations use an unlabeled text argument:

```swift
try await context.reply("hello")
try await context.send("hello", to: chatID)
try await context.edit("updated")
try await context.answerCallbackQuery("done")
```

Media and message helpers include `sendPhoto`, `sendDocument`, `sendMediaGroup`,
`sendVideo`, `sendAnimation`, `sendAudio`, `forwardMessage`, `deleteMessage`,
`editReplyMarkup`, and `sendChatAction`.

## Matching and Diagnostics

- active flow routes are checked first
- regular callbacks are checked before regular commands
- routes with the same pattern are evaluated in registration order
- the first guard/middleware chain that reaches its handler wins
- active flow updates for one `chatId + userId` are serialized
- replay protection suppresses repeated commands and callback presses for two
  seconds by default

Duplicate unguarded route registrations are available from the route root:

```swift
for duplicate in router.duplicateRouteSignatures {
    print("Duplicate route: \(duplicate.kind) \(duplicate.name)")
}
```

Guarded duplicates are allowed because the same path may intentionally select
different handlers.

## Testing

Add `TelerouteTestSupport` to a test target for a stub Telegram client, recorder,
mock flow storage, and synthetic update factories:

```swift
import Teleroute
import TelerouteTestSupport
import Testing

@Test func ping() async throws {
    let bot = try await TelerouteTestSupport.makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "tests"))

    router.command("ping") { _ in }
    await router.handle()
    await router.process([
        TelerouteTestSupport.makeCommandUpdate(text: "/ping")
    ])
}
```

The package's own tests use Swift Testing and do not require network access.

## Example Project

The repository includes a runnable reference bot covering route scopes, typed
routes, modules, guards, middleware, queues, command publishing, keyboards, and
flows:

```bash
TELEGRAM_BOT_TOKEN=123456:abc swift run TelerouteExample
```

See [the example guide](Sources/TelerouteExample/README.md) for its structure and
route inventory.

## Agent Skill Installation

This repository includes a skill for agents working on Teleroute itself.

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/teleroute"
cp -R skills/teleroute "${CODEX_HOME:-$HOME/.codex}/skills/"
```
