# Teleroute

[![Linux CI](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml/badge.svg?branch=main)](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/tixster/Teleroute/blob/main/LICENSE)
[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-F05138?logo=swift&logoColor=white)](https://swift.org)

Teleroute is a route-style application layer for
[swift-telegram-bot](https://github.com/nerzh/swift-telegram-bot). Its
architecture follows the same useful separation as Hummingbird:

- `Teleroute` builds a bot-independent route graph;
- `TelerouteBot` owns the bot, configuration, lifecycle, and update runtime;
- `TelerouteRouterGroup` composes route namespaces, middleware, guards, and contexts;
- `TelerouteRouteCollection` packages controllers/features for reuse;
- `TelerouteResponse` describes common Telegram actions declaratively.

Teleroute also provides typed commands and callbacks, scope-bound keyboards,
flows, command queues, replay protection, events, metrics, and in-process tests.

> The `Teleroute`/`TelerouteBot` API is intentionally breaking. The former combined
> `Teleroute(bot:logger:)`, public `TelerouteRoutes`, and `TelerouteModule` API
> are not compatibility aliases.

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

                // Add only when this target uses @TelerouteCommand or
                // @TelerouteCallback.
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
)
```

The core runtime does not load the macro compiler plugin. Import
`TelerouteMacros` only in targets that declare macro-annotated route types.

## Quick Start

```swift
import Logging
import Teleroute

let router = Teleroute()

router.command("ping", description: "Check bot health") { _ in
    .reply("pong")
}

router.callback("orders/{id}/approve") { context in
    let id = try context.parameters.require("id")
    return .sequence([
        .answerCallback("Approved \(id)"),
        .edit("Order \(id) approved"),
    ])
}

let telegramBot = try await TGBot(
    connectionType: .longpolling(),
    tgClient: TGClientDefault(),
    botId: "<token>",
    log: Logger(label: "telegram.bot")
)

let bot = TelerouteBot(
    bot: telegramBot,
    router: router,
    logger: Logger(label: "telegram.teleroute"),
    configuration: .init(syncPublishedCommandsOnStart: true)
)

try await bot.run()
```

`bot.run()` attaches the internal dispatcher, optionally synchronizes command
menus, starts the bot, waits until cancellation, and then shuts down gracefully.
There is no separate `bot.add(router:)` or public `router.attach()` step.

For handlers that need arbitrary Telegram operations, use the explicitly named
side-effect API:

```swift
router.onCommand("report") { context in
    try await context.bot.sendDocument(/* ... */)
    try await context.reply("Report sent")
}
```

`command` and `callback` return `TelerouteResponse`; `onCommand` and
`onCallback` return `Void`. Keeping the two forms separate avoids ambiguous
Swift overload resolution.

## Bot Configuration

All runtime dependencies and policies live in one value:

```swift
let bot = TelerouteBot(
    bot: telegramBot,
    router: router,
    logger: logger,
    configuration: .init(
        flowStorage: DatabaseFlowStorage(),
        replayProtectionStorage: RedisReplayProtectionStorage(),
        replayProtectionTTL: .seconds(5),
        maximumConcurrentUpdates: 64,
        flowCancellationPolicy: .manual,
        metricsSink: MetricsSink(),
        onError: { error, context in
            try? await context.reply("Something went wrong")
        },
        syncPublishedCommandsOnStart: true
    )
)
```

Pass `replayProtectionStorage: nil` to disable replay protection.
`maximumConcurrentUpdates` defaults to `64`; producers suspend when all slots
are occupied instead of creating an unbounded number of tasks.

For embedding and tests, the lifecycle can also be controlled explicitly:

```swift
try await bot.attach()       // no polling/webhook start
await bot.process(updates)   // synthetic or externally supplied updates
try await bot.start()        // idempotent
await bot.shutdown()         // idempotent
```

A `TelerouteBot` cannot be restarted after shutdown.

## Routes, Groups, and Middleware Collections

Commands use Telegram-compatible `_`-joined group names. Callbacks retain `/`
hierarchy:

```swift
let admin = router.group("admin")

admin.command("status") { _ in
    .reply("ok")
}

admin.callback("users/{id}/ban") { context in
    .answerCallback("Banned \(try context.parameters.require("id"))")
}
```

These match `/admin_status` and `admin/users/42/ban`.

Middleware and guards can be attached once to a router or group:

```swift
router.middlewares.add(TelerouteAccessLogMiddleware(label: "telegram.routes"))

let admin = router.group("admin")
admin.middlewares.add(TelerouteTimeoutMiddleware(.seconds(3)))
admin.guards.add(TelerouteAdminGuard())

admin.command("status") { _ in .reply("ok") }
```

They are snapshotted and compiled when a route or child group is registered, so
add them before the routes they should affect. Route-local low-level middleware
and guards remain available:

```swift
router.command(
    "slow",
    guards: [TeleroutePrivateChatGuard()],
    middlewares: [TelerouteRetryMiddleware(retries: 2)]
) { _ in
    .reply("done")
}
```

## Typed Commands

Typed commands decode command arguments and keep parsing out of handlers.

### Without Macros

```swift
struct BanCommand: TelerouteCommand {
    static let path = "ban"
    static let commandDescription = "Ban a user"
    static let visibility: [TelerouteCommandVisibility] = [.allChatAdministrators]

    let userID: String
    let reason: String?

    init(command: TelerouteCommandMatch) throws {
        self.userID = try command.require("userID", at: 0)
        self.reason = command.get("reason", at: 1)
    }
}

router.command(BanCommand.self) { command, _ in
    .reply("Ban \(command.userID): \(command.reason ?? "no reason")")
}
```

`/ban 42 spam` produces `BanCommand(userID: "42", reason: "spam")`.

For a side-effect controller method:

```swift
router.onCommand(BanCommand.self, use: moderationController.ban)
```

### With Macros

```swift
import Teleroute
import TelerouteMacros

@TelerouteCommand("ban")
struct BanCommand {
    let userID: String
    let reason: String?
}
```

The macro synthesizes `TelerouteCommand`, `path`, positional decoding in stored
property order, and a memberwise initializer. Required properties throw when
missing; optional properties decode as `nil`.

Registration is identical:

```swift
router.command(BanCommand.self) { command, _ in
    .reply("Ban \(command.userID)")
}
```

### Self-Handling Commands

Data-only commands plus explicit controllers are the dependency-friendly
default. Small commands may opt into `TelerouteHandlingCommand`:

```swift
struct HealthCommand: TelerouteHandlingCommand {
    static let path = "health"

    init(command: TelerouteCommandMatch) throws {}

    func handle(context: TelerouteContext) async throws {
        try await context.reply("ok")
    }
}

router.command(HealthCommand.self)
```

Self-handling routes always receive the core `TelerouteContext`, including when
the router uses a custom request context.

## Typed Callbacks and Keyboards

Typed callback registration returns a scope-bound route handle. The same handle
registers the handler, builds callback data, and creates buttons, so callback
path strings do not spread through the project.

### Without Macros

```swift
struct RejectOrder: TelerouteCallback {
    static let path = "orders/{orderID}/reject"

    let orderID: String

    init(orderID: String) {
        self.orderID = orderID
    }

    init(parameters: TelerouteParameters) throws {
        self.orderID = try parameters.require("orderID")
    }

    var parameters: [String: String] {
        ["orderID": self.orderID]
    }
}

let rejectOrder = router.callback(RejectOrder.self) { callback, _ in
    .sequence([
        .answerCallback("Rejected \(callback.orderID)"),
        .edit("Order \(callback.orderID) rejected"),
    ])
}
```

### With Macros

```swift
import TelerouteMacros

@TelerouteCallback("orders/{orderID}/reject")
struct RejectOrder {
    let orderID: String
}

let rejectOrder = router.callback(RejectOrder.self) { callback, _ in
    .answerCallback("Rejected \(callback.orderID)")
}
```

Every `{placeholder}` must map one-to-one to a required stored `String`
property. The macro synthesizes decoding, `parameters`, and a memberwise
initializer.

### Buttons

```swift
let keyboard = try router.keyboard([[
    rejectOrder.button(
        RejectOrder(orderID: "42"),
        "Reject #42",
        style: "danger"
    )
]])

router.command("orders") { _ in
    .reply(
        "Orders",
        replyMarkup: .inlineKeyboardMarkup(keyboard)
    )
}
```

Use `rejectOrder.callbackData(for:)` when an encoded string is required by an
external Telegram API. `callback.button(...)` is also available, but is
validated against the scope that renders it. Route-bound buttons are safer for
cross-feature composition.

Pagination keeps the same route binding:

```swift
let row = TeleroutePagination.navigationRow(
    pageRoute,
    page: page,
    pageCount: pageCount
) { PageCallback(page: $0) }
```

## Route Collections and Controllers

`TelerouteRouteCollection` is the feature-composition boundary. A collection
can own dependencies and return only the callback handles needed by its parent:

```swift
struct OrderRoutes: TelerouteRouteCollection {
    struct Exports: Sendable {
        let reject: TelerouteCallbackRoute<RejectOrder>
    }

    let controller: OrderController

    func addRoutes(
        to routes: TelerouteRouterGroup<TelerouteContext>
    ) -> Exports {
        routes.onCommand("orders", use: controller.list)
        let reject = routes.onCallback(
            RejectOrder.self,
            use: controller.reject
        )
        return .init(reject: reject)
    }
}

let orders = router.group("shop").addRoutes(
    OrderRoutes(controller: orderController)
)

let button = orders.reject.button(
    RejectOrder(orderID: "42"),
    "Reject"
)
```

This produces `/shop_orders` and `shop/orders/42/reject` while the parent never
duplicates either route path.

## Custom Request Contexts

The default router uses `TelerouteContext`:

```swift
let router = Teleroute()
```

A custom context can carry request-scoped state and application services:

```swift
struct AppContext: TelerouteInitializableRequestContext {
    let coreContext: TelerouteContext
    var requestID: String?

    init(source: TelerouteContextSource) {
        self.coreContext = source.coreContext
    }
}

let router = Teleroute(context: AppContext.self)
```

If construction needs captured dependencies, provide a factory:

```swift
struct AppContext: TelerouteRequestContext {
    let coreContext: TelerouteContext
    let orders: OrderService
}

let router = Teleroute(context: AppContext.self) { source in
    AppContext(coreContext: source.coreContext, orders: orderService)
}
```

Common Telegram properties and methods (`update`, `bot`, `parameters`,
`command`, `message`, `chatId`, `userId`, `reply`, `send`, `edit`, flow
helpers, and others) are forwarded from `coreContext`.

### Typed Context Middleware

`TelerouteRouterMiddleware` can transform a custom context and return a
response, including a short-circuit response:

```swift
struct RequestIDMiddleware: TelerouteRouterMiddleware {
    typealias Context = AppContext

    func handle(
        _ context: AppContext,
        next: @escaping @Sendable (AppContext) async throws -> TelerouteResponse
    ) async throws -> TelerouteResponse {
        var context = context
        context.requestID = UUID().uuidString
        return try await next(context)
    }
}

router.middlewares.add(RequestIDMiddleware())
```

Low-level `TelerouteMiddleware` continues to wrap `TelerouteContext` and powers
the built-in timeout, retry, logging, throttle, debounce, queue, and
error-handling middleware.

### Child Contexts

A child context narrows guarantees for a nested group:

```swift
struct AuthenticatedContext: TelerouteChildRequestContext {
    typealias ParentContext = AppContext

    let coreContext: TelerouteContext
    let userID: Int64

    init(context: AppContext) throws {
        guard let userID = context.userId else {
            throw AuthenticationError.userMissing
        }
        self.coreContext = context.coreContext
        self.userID = userID
    }
}

router.group("account", context: AuthenticatedContext.self) { account in
    account.command("me") { context in
        .reply("User \(context.userID)")
    }
}
```

Parent typed middleware runs before the child context is constructed. Child
contexts and middleware may be chained through multiple nested groups.

## Responses

`TelerouteResponse` supports:

```swift
.none
.reply("text", parseMode: nil, replyMarkup: nil)
.send("text", to: chatID)
.edit("new text", replyMarkup: keyboard)
.answerCallback("done", showAlert: false)
.sequence([.answerCallback(), .edit("done")])
```

Responses run in sequence and use the matched core context. Use `onCommand` or
`onCallback` when a handler needs operations not represented by this enum.

## Guards and Built-In Middleware

Built-in guards:

- `TeleroutePrivateChatGuard`
- `TelerouteGroupChatGuard`
- `TelerouteChatTypeGuard`
- `TelerouteUserAllowlistGuard`
- `TelerouteChatAllowlistGuard`
- `TelerouteArgumentCountGuard`
- `TelerouteAdminGuard`

`TelerouteAdminGuard` calls Telegram `getChatMember`; it is not a local-only
predicate.

Built-in middleware:

- `TelerouteAccessLogMiddleware`
- `TelerouteTimeoutMiddleware`
- `TelerouteRetryMiddleware`
- `TelerouteErrorHandlingMiddleware`
- `TelerouteThrottleMiddleware`
- `TelerouteDebounceMiddleware`

Low-level middleware intentionally consuming an update without calling `next`
is handled by Teleroute's internal consuming semantics, so fallback routes do
not run for throttled or superseded updates.

## Command Queues

Commands can serialize work by scope:

```swift
router.command("rebuild", queue: .global) { _ in .reply("done") }
router.command("export", queue: .perChat) { _ in .reply("done") }
router.command("profile", queue: .perChatAndUser) { _ in .reply("done") }
```

Typed commands may declare a default queue through `TelerouteCommand.queue`.

## Flows

Flows route messages, commands, and callbacks according to one active session
per `chatId + userId`:

```swift
struct SignupFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case name
        case confirm
    }

    func boot(flow: TelerouteFlowGroup<Self>) {
        flow.start(
            "signup",
            at: .name,
            description: "Start signup"
        ) { context in
            try await context.reply("What is your name?")
        }

        flow.message(at: .name) { context in
            let name = context.message?.text ?? ""
            try await context.transition(to: .confirm, merging: ["name": name])
            try await context.reply("Confirm \(name)?")
        }

        flow.command("cancel", at: .confirm) { context in
            try await context.finish()
            try await context.reply("Cancelled")
        }
    }
}

router.flow(SignupFlow())
```

Active flow routes run before regular callbacks and commands. Regular callbacks
run before regular commands. Flow step handlers use `TelerouteFlowContext`;
feature dependencies can be captured by the flow value itself.

Unmatched-command behavior is controlled by:

- `.cancelOnAnyUnmatchedCommand` (default)
- `.preserveOnUnmatchedCommand`
- `.manual`

## Published Commands

Descriptions registered on routes are grouped by Telegram visibility:

```swift
router.command(
    "help",
    description: "Show help",
    visibility: [.allPrivateChats]
) { _ in .reply("Help") }

for commandSet in try router.publishedCommandSets() {
    print(commandSet.visibility, commandSet.commands)
}
```

Set `syncPublishedCommandsOnStart: true` to publish registered menus from
`bot.start()`/`bot.run()`, or control them explicitly:

```swift
try await bot.syncPublishedCommands()
try await bot.publishCommands(
    [("health", "Check health")],
    visibility: .allChatAdministrators
)
try await bot.publishCommands([BanCommand.self])
```

Handlers may update a chat/member-specific menu through
`context.coreContext.publishCommands(...)`.

## Events, Errors, and Shutdown

Every subscriber gets an independent event stream:

```swift
let events = bot.eventStream(buffering: .newest(256))

Task {
    for await event in events {
        print(event.kind, event.routeKind, event.routeName ?? "-")
    }
}
```

Events are emitted for `received`, `skippedDuplicate`, `handled`, `unmatched`,
and `failed`. Failed events retain the typed error and a stable description.
`onError`, logging, events, and `TelerouteMetricsSink` observe the same routing
outcome.

`await bot.shutdown()` stops accepting updates, cancels in-flight handlers,
finishes event streams, and stops a started Telegram connection.

## Context Helpers

`TelerouteContext` and custom request contexts expose text, callback, message,
flow, and identity helpers. `TelerouteContext` additionally includes media,
forwarding, deletion, editing, and chat-action helpers.

```swift
router.onCommand("photo") { context in
    try await context.coreContext.sendPhoto(/* ... */)
    try await context.reply("Photo sent")
}
```

The raw `TGUpdate` remains available as `context.update`, and the bot escape
hatch remains available as `context.bot`.

## Matching and Performance

For every update, Teleroute creates one internal parsed update and takes one
immutable route-graph snapshot. Command routes use a name index, callback
routes use a compiled component index, and flow routes use a flow/step index.

Order is deterministic:

1. active flow routes;
2. regular callbacks;
3. regular commands;
4. first registered route whose guards/middleware reach the handler wins.

Callback generation and matching share the same percent-encoding rules.
Duplicate unguarded route signatures are exposed through
`router.duplicateRouteSignatures`; guarded duplicates are allowed because they
can intentionally select different handlers.

Run the release benchmark with:

```bash
swift run -c release TelerouteBenchmarks
```

## In-Process Testing

`TelerouteTestSupport` creates a `TelerouteBot` backed by a recording Telegram
client. No polling, webhook server, or network request is started:

```swift
import Testing
import Teleroute
import TelerouteTestSupport

@Test
func startCommand() async throws {
    let router = Teleroute()
    router.command("start") { _ in .reply("Welcome") }

    let (bot, telegram) = try await TelerouteTestSupport.makeTelerouteBot(
        router: router
    )

    try await bot.test { client in
        let result = await client.sendCommand("start")
        #expect(result.terminalEvent?.kind == .handled)
    }

    guard case let .some(.sentMessage(message)) = telegram.effects.first else {
        Issue.record("Expected a message")
        return
    }
    #expect(message.text == "Welcome")
}
```

The recording client captures sent text and reply markup, message edits,
callback answers, and command-menu updates. The test client also provides
`sendMessage`, `pressCallback`, and raw `execute(TGUpdate)` methods.

## Example Project

`Sources/TelerouteExample` is a runnable bot showing:

- `Teleroute`/`TelerouteBot` bootstrap and automatic command synchronization;
- custom and child request contexts;
- typed context middleware and group middleware/guards;
- route collections with exported callback handles;
- commands/callbacks with and without macros;
- declarative responses and direct side effects;
- typed keyboards, flows, and scoped command menus.

Run it with:

```bash
TELEGRAM_BOT_TOKEN=<token> swift run TelerouteExample
```

## Agent Skill Installation

The repository includes a Teleroute Codex skill under `skills/teleroute`.

```bash
pfw install ./skills/teleroute
```
