# Teleroute

[![Linux CI](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml/badge.svg?branch=main)](https://github.com/tixster/Teleroute/actions/workflows/linux-ci.yml)
[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/tixster/Teleroute/blob/main/LICENSE)
[![Swift 6.3](https://img.shields.io/badge/Swift-6.3-F05138?logo=swift&logoColor=white)](https://swift.org)

Teleroute is a route-style layer for [swift-telegram-bot](https://github.com/nerzh/swift-telegram-bot).

It gives Telegram bots API for:

- commands
- callback queries
- route groups
- typed command and callback specs
- collections
- guards and middleware
- stateful multi-step flows
- lifecycle events
- throttle and debounce middleware

## Requirements

- Swift 6.3
- macOS 15+
- [swift-telegram-bot](https://github.com/nerzh/swift-telegram-bot) 10.0+

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

## Agent Skill Installation

This repository includes an agent skill for working on Teleroute itself.

### Codex

Install or update the skill from the repository root:

```bash
mkdir -p "${CODEX_HOME:-$HOME/.codex}/skills"
rm -rf "${CODEX_HOME:-$HOME/.codex}/skills/teleroute"
cp -R skills/teleroute "${CODEX_HOME:-$HOME/.codex}/skills/"
```

After installation, invoke it as `$teleroute` when asking Codex to implement,
test, document, or debug Teleroute routing behavior.

### Claude Code

Install or update it as a personal Claude Code skill:

```bash
mkdir -p "$HOME/.claude/skills"
rm -rf "$HOME/.claude/skills/teleroute"
cp -R skills/teleroute "$HOME/.claude/skills/"
```

Alternatively, install it as a project-local Claude Code skill:

```bash
mkdir -p .claude/skills
rm -rf .claude/skills/teleroute
cp -R skills/teleroute .claude/skills/
```

Claude Code discovers skills automatically from `~/.claude/skills` and
`.claude/skills`. Ask Claude to use the Teleroute skill, or ask for work that
matches its description.

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

router.command("ping") { _, context in
    try await context.reply(text: "pong")
}

router.callback("orders/{id}/approve") { _, context in
    let id = try context.parameters.require("id")
    try await context.answerCallbackQuery(text: "approved \(id)")
}

try await bot.add(router: router)
try await bot.start()
```

## Example Project

The package includes a runnable example target that exercises the full feature set:

- string commands and callbacks
- typed commands and typed callbacks
- route groups
- collections and group-owned collections
- guards and middleware
- command queueing
- published command sync
- multi-step flows

Run it with a real Telegram bot token:

```bash
TELEGRAM_BOT_TOKEN=123456:abc swift run TelerouteExample
```

The executable entry point lives at [TelerouteExampleApp](Sources/TelerouteExample/App/TelerouteExampleApp.swift).
Detailed architecture and route documentation live at [TelerouteExample README](Sources/TelerouteExample/README.md).

## Core Ideas

- `command("start")` matches `/start`
- `group("admin").command("ban")` matches `/admin_ban`
- `callback("orders/{id}/approve")` matches callback data like `orders/42/approve`
- callback path parameters are encoded on generation and decoded on match
- callbacks are matched before commands
- active flow handlers are matched before regular routes

## Commands vs Callbacks

`command(...)` handles Telegram messages that start with `/`.

```swift
router.command("start") { _, context in
    try await context.reply(text: "hello")
}
```

This handler runs for a message like:

```text
/start
```

If you need to match only commands explicitly addressed to one bot in a multi-bot chat, use `botUsername`:

```swift
router.command("start", botUsername: "my_bot") { _, context in
    try await context.reply(text: "hello from my_bot")
}
```

This matches `/start@my_bot` and ignores `/start@other_bot`.

`callback(...)` handles inline keyboard button presses.

```swift
router.callback("users/{id}/ban") { _, context in
    let id = try context.parameters.require("id")
    try await context.answerCallbackQuery(text: "banned \(id)")
}
```

This handler does not run from a chat message. It runs when a user presses an inline button whose `callback_data` matches the route.

For example:

```swift
let button = try router.callbackButton(
    "Ban",
    path: "users/{id}/ban",
    parameters: ["id": "42"]
)
```

This produces callback data like:

```text
users/42/ban
```

If the route is inside a group:

```swift
router.group("admin") { admin in
    admin.callback("users/{id}/ban") { _, context in
        let id = try context.parameters.require("id")
        try await context.answerCallbackQuery(text: "banned \(id)")
    }

    let groupedButton = try admin.callbackButton(
        "Ban",
        path: "users/{id}/ban",
        parameters: ["id": "42"]
    )
}
```

then `groupedButton.callbackData` becomes:

```text
admin/users/42/ban
```

because the `admin` prefix is added by the same group that generated the button.

If you generate the button from the root `router`, you must pass the full path yourself:

```swift
let rootButton = try router.callbackButton(
    "Ban",
    path: "admin/users/{id}/ban",
    parameters: ["id": "42"]
)
```

Rule of thumb:

- if you generate the button from `router`, use the full callback path
- if you generate the button from a `group`, use the path relative to that group

## Usage Styles

### 1. String-Based Routes

Use this when you want the smallest API surface and manual parsing is enough.

```swift
router.group("admin") { admin in
    admin.command("ban") { _, context in
        let userID = context.command?.arguments.first ?? "unknown"
        try await context.reply(text: "ban \(userID)")
    }

    admin.callback("users/{id}/ban") { _, context in
        let id = try context.parameters.require("id")
        try await context.answerCallbackQuery(text: "banned \(id)")
    }
}
```

### 2. Typed Commands And Callbacks

Use this when you want parsing and route-specific logic to live in dedicated types.

```swift
struct BanCommand: TelerouteCommand {
    static let path = "ban"
    static let commandDescription: String? = "Ban a user"
    static let visibility: [TelerouteCommandVisibility] = [.allGroupChats]

    let userID: String

    init(command: TelerouteCommandMatch) throws {
        self.userID = try command.require("userID")
    }

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        try await context.reply(text: "ban \(self.userID)")
    }
}

struct ApproveOrderCallback: TelerouteCallback {
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

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        try await context.answerCallbackQuery(text: "approved \(self.id)")
    }
}

router.command(BanCommand.self)
router.callback(ApproveOrderCallback.self)
```

If you want typed parsing but prefer handlers outside the type:

```swift
router.command(BanCommand.self) { _, context, command in
    try await context.reply(text: "ban \(command.userID)")
}

router.callback(ApproveOrderCallback.self) { _, context, callback in
    try await context.answerCallbackQuery(text: "approved \(callback.id)")
}
```

Typed callbacks also work inside groups:

```swift
struct BanUserCallback: TelerouteCallback {
    static let path = "users/{id}/ban"

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

let admin = router.group("admin")
admin.callback(BanUserCallback.self)

let button = try admin.callbackButton(
    "Ban",
    callback: BanUserCallback(id: "42")
)
```

Here `button.callbackData` becomes `admin/users/42/ban` because the callback is generated from the same group.

### 3. Published Commands And Visibility

Use this when you want `Teleroute` to register Telegram command menus through `setMyCommands`.

```swift
router.command(
    "start",
    description: "Start the bot",
    visibility: [.allPrivateChats]
) { _, context in
    try await context.reply(text: "hello")
}

router.command(
    "ban",
    description: "Ban a user",
    visibility: [.allGroupChats, .allChatAdministrators]
) { _, context in
    try await context.reply(text: "ban")
}

try await router.syncPublishedCommands()
```

If you need to replace the visible command list dynamically at runtime, you can publish commands directly:

```swift
try await router.publishCommands(
    [("profile", "Open profile"), ("logout", "Log out")],
    visibility: .allPrivateChats
)
```

The same helper is available inside handlers:

```swift
router.command("start") { _, context in
    try await context.publishCommands(
        [("profile", "Open profile"), ("logout", "Log out")],
        visibility: .chat(.id(1))
    )
}
```

Typed commands are also supported:

```swift
try await router.publishCommands([StartCommand.self])

router.command("login") { _, context in
    try await context.publishCommands(
        [StartCommand.self],
        visibility: .chat(.id(1))
    )
}
```

Available visibility helpers:

- `.default` - base Telegram command scope used when no narrower scope matches
- `.allPrivateChats` - visible in all private chats with the bot
- `.allGroupChats` - visible in all group and supergroup chats
- `.allChatAdministrators` - visible to administrators in all group and supergroup chats
- `.chat(.id(123))` - visible only in one specific chat by numeric chat id
- `.chat(.username("@my_group"))` - visible only in one specific chat by public username
- `.chatAdministrators(...)` - visible only to administrators of one specific group or supergroup
- `.chatMember(..., userID: ...)` - visible only to one specific user inside one specific group or supergroup

Telegram resolves command lists from the narrowest scope to the broadest one, and falls back to `.default` when there is no more specific match.

Command sets keep registration order. If the same command is registered more than once in the same visibility scope with the same description, it is published once. If descriptions conflict, `publishedCommandSets()` throws `TelerouteError.duplicatePublishedCommand`.

Typed commands can declare the same metadata on the spec:

```swift
struct StartCommand: TelerouteCommand {
    static let path = "start"
    static let commandDescription: String? = "Start the bot"
    static let visibility: [TelerouteCommandVisibility] = [.allPrivateChats]

    init(command: TelerouteCommandMatch) throws {}
}

router.command(StartCommand.self)
try await router.syncPublishedCommands()
```

### 4. Callback Buttons From Route Definitions

Use the same callback definitions for routing and keyboard generation.

String-based:

```swift
let row = try router.callbackButtons([
    ("Approve", path: "orders/{id}/approve", parameters: ["id": "42"]),
    ("Reject", path: "orders/{id}/reject", parameters: ["id": "42"]),
])

let keyboard = router.callbackKeyboard([row])
```

Typed:

```swift
struct RejectOrderCallback: TelerouteCallback {
    static let path = "orders/{id}/reject"

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

    func handle(update: TGUpdate, context: TelerouteContext) async throws {
        try await context.answerCallbackQuery(text: "rejected \(self.id)")
    }
}

router.callback(RejectOrderCallback.self)

let row = try router.callbackButtons([
    ("Approve", ApproveOrderCallback(id: "42")),
    ("Reject", RejectOrderCallback(id: "42")),
])

let keyboard = router.callbackKeyboard([row])
```

### 5. Collections

Use collections to split large bots by feature.

#### Mount Into An Existing Group

Use `TelerouteCollection` when the group path is chosen by the caller.

```swift
struct AdminRoutes: TelerouteCollection {
    func boot(routes: TelerouteGroup) {
        routes.command("ban") { _, context in
            try await context.reply(text: "ban")
        }
    }
}

router.group("admin") { admin in
    admin.add(collection: AdminRoutes())
}
```

#### Let The Collection Own Its Prefix

Use `TelerouteGroupCollection` when the collection should be fully self-contained.

```swift
struct AdminRoutes: TelerouteGroupCollection {
    let path = "admin"

    func boot(collection: TelerouteCollectionGroup) {
        collection.command("ban") { _, context in
            try await context.reply(text: "ban")
        }
    }
}

router.group(AdminRoutes())
```

#### Use A Collection Builder API

If you want collection code to avoid exposing `TelerouteGroup`, conform to `TelerouteCollectionBuilder`.

```swift
struct ProfileRoutes: TelerouteCollectionBuilder {
    func boot(collection: TelerouteCollectionGroup) {
        collection.command("me") { _, context in
            try await context.reply(text: "profile")
        }
    }
}

router.add(collection: ProfileRoutes())
```

### 6. Guards

Use guards to select routes by context without putting `if` logic into handlers.

```swift
struct PrivateChatGuard: TelerouteGuard {
    func matches(_ context: TelerouteContext) async throws -> Bool {
        context.message?.chat.type == .private
    }
}

router.command("start", routeGuard: PrivateChatGuard()) { _, context in
    try await context.reply(text: "private only")
}
```

### 7. Middleware

Use middleware for logging, auth, metrics, or shared pre/post hooks.

```swift
struct LoggingMiddleware: TelerouteMiddleware {
    func handle(
        _ context: TelerouteContext,
        next: @escaping @Sendable (TelerouteContext) async throws -> Void
    ) async throws {
        print("before")
        try await next(context)
        print("after")
    }
}

router.command(
    "start",
    middlewares: [LoggingMiddleware()]
) { _, context in
    try await context.reply(text: "hello")
}
```

Guards and middleware can be combined:

```swift
router.callback(
    "orders/{id}/approve",
    routeGuard: PrivateChatGuard(),
    middlewares: [LoggingMiddleware()]
) { _, context in
    let id = try context.parameters.require("id")
    try await context.answerCallbackQuery(text: "approved \(id)")
}
```

Built-in rate-limiting middleware is available for high-frequency buttons and commands:

```swift
router.callback(
    "orders/{id}/approve",
    middlewares: [
        TelerouteThrottleMiddleware(
            interval: .seconds(1),
            scope: .callbackData
        )
    ]
) { _, context in
    try await context.answerCallbackQuery(text: "approved")
}
```

Use debounce when only the latest update in a burst should run:

```swift
router.command(
    "search",
    middlewares: [
        TelerouteDebounceMiddleware(
            interval: .milliseconds(300),
            scope: .chatUser
        )
    ]
) { _, context in
    try await context.reply(text: "searching \(context.command?.argumentsText ?? "")")
}
```

Available rate-limit scopes are `.chat`, `.user`, `.chatUser`, `.callbackData`, `.command`, and `.custom`.

### 8. Command Queueing

Use `queueing:` when a command must run sequentially instead of being handled in parallel.

```swift
router.command("sync_orders", queueing: .chatUser) { _, context in
    try await context.reply(text: "sync started")
    // long-running work
}
```

Available strategies:

- `.global` serializes the command across the whole bot
- `.chat` serializes per `chatId`
- `.chatUser` serializes per `chatId + userId`

| Strategy | Serializes by | Use when |
| --- | --- | --- |
| `.global` | one shared queue for the command across the whole bot | the command touches shared global state or an external job that must never overlap |
| `.chat` | one queue per Telegram chat | the command should not overlap inside the same group/private chat, but different chats may run in parallel |
| `.chatUser` | one queue per `chatId + userId` pair | only the same user should be serialized, while other users in the same chat may still run the command |

Only commands where you explicitly pass `queueing:` are queued. All other commands keep the default behavior.

Typed commands can declare their default strategy on the spec itself:

```swift
struct SyncOrdersCommand: TelerouteCommand {
    static let path = "sync_orders"
    static let queueing: TelerouteCommandQueueing? = .chatUser

    init(command: TelerouteCommandMatch) throws {}
}

router.command(SyncOrdersCommand.self)
```

If you also pass `queueing:` during registration, that explicit value overrides the one declared on the spec.

This also works for flow entry commands:

```swift
flow.start("signup", at: .name, queueing: .chatUser) { _, context in
    try await context.reply(text: "Send your name")
}
```

### 9. Flows

Use flows for multi-step stateful interactions.

Each active flow keeps one session scoped by `chatId + userId`.

```swift
struct SignupFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case name
        case confirm
    }

    func boot(flow: TelerouteFlowGroup<SignupFlow>) {
        flow.start("signup", at: .name) { _, context in
            try await context.reply(text: "Send your name")
        }

        flow.message(at: .name) { _, context in
            let name = context.message?.text ?? ""

            let buttons = try flow.callbackButtons([
                ("Approve", path: "confirm/{decision}", parameters: ["decision": "approve"]),
                ("Reject", path: "confirm/{decision}", parameters: ["decision": "reject"]),
            ])

            try await context.transition(to: .confirm, merging: ["name": name])
            try await context.reply(
                text: "Confirm signup for \(name)?",
                replyMarkup: flow.callbackKeyboard([buttons])
            )
        }

        flow.callback("confirm/{decision}", at: .confirm) { _, context in
            let name = try context.values.require("name")
            let decision = try context.parameters.require("decision")

            try await context.finish()
            try await context.reply(text: "\(name): \(decision)")
        }
    }
}

router.add(flow: SignupFlow())
```

If a user sends a Telegram command while a flow is active, Teleroute first checks flow-local command routes for the active step. If no flow command handles the update, the current flow session is cancelled and the command is then handled by regular command routes.

By default `Teleroute` uses `TelerouteInMemoryFlowStorage`, but you can inject your own storage:

```swift
actor RedisBackedFlowStorage: TelerouteFlowStorage {
    func session(for key: TelerouteFlowKey) async -> TelerouteFlowSession? {
        // load from Redis, database, etc.
        nil
    }

    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) async {
        // persist
    }

    func removeSession(for key: TelerouteFlowKey) async {
        // delete
    }
}

let router = Teleroute(
    bot: bot,
    logger: Logger(label: "telegram.router"),
    flowStorage: RedisBackedFlowStorage()
)
```

## Routing Helpers

`TelerouteContext` exposes convenience helpers:

- `reply(text:)`
- `send(text:to:)`
- `edit(text:)`
- `answerCallbackQuery(text:)`

It also exposes parsed values:

- `command`
- `parameters`
- `message`
- `callbackQuery`
- `callbackData`
- `chatId`
- `userId`
- `activeFlow`

## Matching Rules

- active flow handlers are checked first
- regular callbacks are checked before regular commands
- if several routes share the same command or callback pattern, they are evaluated in registration order
- the first route whose guard and middleware chain reaches the final handler wins
- repeated identical commands and callback presses from the same chat/user are ignored for 2 seconds by default
- active flow updates for the same `chatId + userId` are serialized so each step sees the latest flow session

For startup diagnostics, `router.duplicateRouteSignatures` reports duplicate unguarded command, callback, and flow route registrations:

```swift
for duplicate in router.duplicateRouteSignatures {
    print("Duplicate route: \(duplicate.kind) \(duplicate.name)")
}
```

Guarded routes are excluded from this diagnostic because registering the same path with different guards is a supported routing pattern.

## Design Notes

- grouped commands use `_` because Telegram commands do not support `/` hierarchy
- callback routes keep `/` hierarchy and support `{parameter}` placeholders
- collections are for feature composition
- flows are for stateful user interaction
- typed specs are for keeping parsing close to the route domain model
- route and command diagnostics use ordered collections so reports stay deterministic

## Events

`router.events` exposes an `AsyncSequence` of lifecycle events.

```swift
Task {
    for await event in router.events {
        switch event.kind {
        case .handled:
            print("handled \(event.routeKind) \(event.routeName ?? "")")
        case .failed:
            print("failed \(event.errorDescription ?? "unknown error")")
        default:
            break
        }
    }
}
```

Events are emitted for received updates, skipped duplicates, handled routes, unmatched updates, and failures.

## Replay Protection

By default `Teleroute` suppresses repeated handling of the same command or callback for the same `chatId + userId` pair during a short window.

The default configuration uses `TelerouteInMemoryReplayProtectionStorage` with a 2-second TTL. Expired in-memory keys are removed during claims and by a periodic cleanup task.

In-memory cleanup tracks expirations in a min-heap, so removing expired keys does not require scanning every stored replay key on each claim.

You can customize or disable it:

```swift
actor RedisReplayProtectionStorage: TelerouteReplayProtectionStorage {
    func claim(key: String, ttl: Duration) async -> Bool {
        true
    }
}

let router = Teleroute(
    bot: bot,
    logger: Logger(label: "telegram.router"),
    flowStorage: TelerouteInMemoryFlowStorage(),
    replayProtectionStorage: RedisReplayProtectionStorage(),
    replayProtectionTTL: .seconds(5)
)
```

To disable replay protection entirely:

```swift
let router = Teleroute(
    bot: bot,
    logger: Logger(label: "telegram.router"),
    flowStorage: TelerouteInMemoryFlowStorage(),
    replayProtectionStorage: nil
)
```
