# ``Teleroute``

A route-style Swift framework for the Telegram Bot API, designed after Hummingbird 2.

## Overview

Teleroute lets you describe a Telegram bot the way you describe an HTTP server:
you register routes on a router, compose middleware and guards around them, and
hand the finished route graph to a runtime that owns the connection and
lifecycle.

- ``Teleroute/Teleroute`` builds a bot-independent route graph over typed
  request contexts.
- ``TelerouteBot`` owns the Telegram client, lifecycle, and update runtime, and
  conforms to `Service` (swift-service-lifecycle).
- Handlers return any ``TelerouteResponseGenerator`` — a `String`, a chainable
  ``Reply``, a full ``TelerouteResponse``, or `.unhandled` to fall through.
- The entire Bot API ships as typed flat methods (185 operations) on
  `TelegramBotClient`, generated from Telegram's own documentation.

A complete bot fits on one screen:

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

Start with <doc:GettingStarted>, then explore <doc:Routing> and
<doc:Responses> — together they cover most day-to-day bot code.

> Note: Importing `Teleroute` re-exports the `TelegramBotKit` vocabulary
> (`Update`, `Message`, `ChatId`, `InlineKeyboardMarkup`, …) and `Logging`,
> so a single `import Teleroute` is enough for typical bot code.

## Topics

### Essentials

- <doc:GettingStarted>
- <doc:Routing>
- <doc:Responses>
- ``Teleroute/Teleroute``
- ``TelerouteBot``
- ``TelerouteConfiguration``

### Route Registration

- ``TelerouteRouterGroup``
- ``TelerouteMessageFilter``
- ``TelerouteMessageSource``
- ``TelerouteRouteCollection``
- ``TelerouteRouteSignature``
- ``TelerouteQueueScope``

### Contexts

- <doc:ContextsAndHelpers>
- ``TelerouteRequestContext``
- ``TelerouteInitializableRequestContext``
- ``TelerouteChildRequestContext``
- ``TelerouteContext``
- ``TelerouteContextSource``
- ``TelerouteParameters``
- ``TelerouteCommandMatch``
- ``TelerouteResponderState``
- ``TelerouteEditTarget``

### Response Types

- ``TelerouteResponse``
- ``TelerouteResponseGenerator``
- ``Reply``
- ``Send``
- ``Edit``
- ``AnswerCallback``
- ``Delete``
- ``React``
- ``TelerouteUnhandled``
- ``TelerouteSendOptions``

### Middleware and Guards

- <doc:MiddlewareAndGuards>
- ``TelerouteMiddleware``
- ``TelerouteGuard``
- ``TelerouteGuardResult``
- ``TelerouteAbort``
- ``TelerouteRouterMiddlewareCollection``
- ``TelerouteRouterGuardCollection``

### Built-In Middleware

- ``TelerouteAccessLogMiddleware``
- ``TelerouteTimeoutMiddleware``
- ``TelerouteTimeoutError``
- ``TelerouteRetryMiddleware``
- ``TelerouteErrorHandlingMiddleware``
- ``TelerouteThrottleMiddleware``
- ``TelerouteDebounceMiddleware``
- ``TelerouteRateLimitScope``
- ``TelerouteRateLimitKey``

### Built-In Guards

- ``TelerouteChatTypeGuard``
- ``TeleroutePrivateChatGuard``
- ``TelerouteGroupChatGuard``
- ``TelerouteUserAllowlistGuard``
- ``TelerouteChatAllowlistGuard``
- ``TelerouteArgumentCountGuard``
- ``TelerouteAdminGuard``

### Typed Commands and Callbacks

- <doc:TypedRoutesAndMacros>
- ``TelerouteCommand``
- ``TelerouteHandlingCommand``
- ``TelerouteCallback``
- ``TelerouteHandlingCallback``
- ``TelerouteCallbackRoute``

### Published Command Menus

- ``TelerouteCommandScope``
- ``TelerouteCommandChat``
- ``TelerouteCommandVisibility``
- ``TeleroutePublishedCommandSet``

### Keyboard Building

- <doc:Keyboards>
- ``TelerouteButton``
- ``Row``
- ``TelerouteRowBuilder``
- ``TelerouteKeyboardBuilder``
- ``KeyButton``
- ``KeyRow``
- ``TelerouteKeyRowBuilder``
- ``TelerouteReplyKeyboardBuilder``
- ``TeleroutePagination``
- ``TelerouteConfirm``
- ``TelerouteInlineActionScope``
- ``TelerouteInlineActionPolicy``
- ``TelerouteButtonCompletion``

### Flow Sessions

- <doc:Flows>
- ``TelerouteFlow``
- ``TelerouteFlowGroup``
- ``TelerouteFlowContext``
- ``TelerouteFlowHandler``
- ``TelerouteFlowSession``
- ``TelerouteFlowValues``
- ``TelerouteFlowKey``
- ``TelerouteFlowStorage``
- ``TelerouteFlowSessionMutation``
- ``TelerouteInMemoryFlowStorage``
- ``TelerouteFlowCancellationPolicy``

### Lifecycle and Delivery

- <doc:LifecycleAndWebhooks>
- ``TelerouteBotMode``
- ``TelerouteBotError``
- ``TelerouteEnvironment``
- ``TelegramPollingConfiguration``
- ``TelerouteAllowedUpdates``

### Channel Discussion Forwards

- ``TelerouteDiscussionForwardPolicy``
- ``TelerouteDiscussionForward``
- ``TelerouteDiscussionForwardError``
- ``TelerouteDiscussionPostError``

### Replay Protection

- ``TelerouteReplayProtectionStorage``
- ``TelerouteReplayProtectionCleanupStorage``
- ``TelerouteInMemoryReplayProtectionStorage``

### Events and Metrics

- <doc:Observability>
- ``TelerouteEvent``
- ``TelerouteEventSequence``
- ``TelerouteEventBufferingPolicy``
- ``TelerouteMetricsSink``
- ``TelerouteSwiftMetricsSink``
- ``TelerouteNoOpMetricsSink``

### Error Handling

- ``TelerouteError``
- ``TelerouteErrorHandler``
- ``TelerouteErrorRenderer``

### In-Process Testing

- <doc:Testing>
- ``TelerouteBotTestClient``
- ``TelerouteBotTestResult``

### Migration

- <doc:MigratingFrom1x>
