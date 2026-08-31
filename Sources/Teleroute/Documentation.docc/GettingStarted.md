# Getting Started

Add Teleroute to a package, register your first routes, and run the bot.

## Overview

This article walks through everything needed to go from an empty package to a
running bot: installation, the anatomy of a minimal bot, and where each part of
the framework fits.

### Add the Package

Teleroute requires Swift 6.3. Add the dependency and pick the products you
need:

```swift
// Package.swift
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

The package ships several products:

| Product | What it contains |
| --- | --- |
| `Teleroute` | The router, runtime, flows, keyboards — this module. |
| `TelerouteMacros` | The `@TelerouteCommand` / `@TelerouteCallback` macros. |
| `TelerouteTestSupport` | In-process test transports and synthetic update factories. |
| `TelerouteHummingbird` | Webhook serving for Hummingbird 2 applications. |
| `TelegramBotKit` | The standalone Telegram client without the router. |
| `TelegramBotAPI` | The raw OpenAPI-generated types and client. |

### Write Your First Bot

A bot is two objects: a router that describes *what* the bot does, and a
``TelerouteBot`` that owns *how* it talks to Telegram.

```swift
import Teleroute

// 1. Build a bot-independent route graph.
let router = Teleroute()

// 2. Register routes. A String return value becomes a reply.
router.command("start", description: "Begin") { _ in
    "Welcome! Try /ping or send me a photo."
}

router.command("ping") { _ in "pong" }

// Plain-message routes filter by content.
router.message(.photo) { context in
    "Nice photo, \(context.message?.from?.firstName ?? "friend")!"
}

// A final hook for anything unmatched.
router.unmatched { context in
    context.updateKind == .message ? .reply("I don't understand") : .unhandled
}

// 3. Create the runtime over the route graph and run it.
let bot = try TelerouteBot(
    token: ProcessInfo.processInfo.environment["TELEGRAM_BOT_TOKEN"]!,
    router: router,
    logger: Logger(label: "bot")
)
try await bot.runService()
```

What each step does:

1. ``Teleroute/Teleroute`` is a plain object — creating it makes no network
   calls, so the same router can be reused in tests and production.
2. Registration methods on ``TelerouteRouterGroup`` — `command`, `message`,
   `text`, `callback`, and friends —
   accept a handler returning any ``TelerouteResponseGenerator``. Returning a
   `String` replies; returning `Void` finishes silently; see <doc:Responses>.
3. ``TelerouteBot/runService(gracefulShutdownSignals:)`` starts long polling
   and converts `SIGTERM`/`SIGINT` into a graceful drain-and-shutdown. For
   composing with other services (databases, HTTP servers) see
   <doc:LifecycleAndWebhooks>.

### Talk to the Whole Bot API

Every handler receives a context that exposes the full typed Telegram client
via `context.bot`:

```swift
router.command("poll") { context in
    try await context.bot.sendPoll(
        chatId: .id(context.chatId!),
        question: "Best color?",
        options: [.init(text: "Red"), .init(text: "Blue")]
    )
}
```

`TelegramBotClient` has one flat, fully typed method per Bot API operation —
`sendVideo`, `banChatMember`, `answerPreCheckoutQuery`, and 180 more. Failures
throw `TelegramAPIError` with the decoded `error_code`, `description`, and
`retry_after`. The most common actions also exist as one-line context helpers
(`context.reply`, `context.sendPhoto`, `context.banMember`, …); see
<doc:ContextsAndHelpers>.

### Run the Example Project

The repository contains a runnable bot demonstrating commands, media routes,
reactions, join-request approval, inline mode, the keyboard DSL, flows over a
custom context, and command-menu publishing:

```bash
TELEGRAM_BOT_TOKEN=<token> swift run TelerouteExample
```

### Where to Go Next

- <doc:Routing> — every route kind and the dispatch order.
- <doc:Responses> — everything a handler can return.
- <doc:MiddlewareAndGuards> — cross-cutting behavior and access control.
- <doc:Flows> — multi-step conversations with session state.
- <doc:Testing> — in-process tests without a network connection.
