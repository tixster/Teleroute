# Lifecycle and Webhooks

Run the bot as a service with graceful shutdown, via long polling or webhooks.

## Overview

``TelerouteBot`` conforms to `Service` from swift-service-lifecycle. Long
polling is the default delivery mode; graceful shutdown stops intake, drains
in-flight handlers (bounded by
``TelerouteConfiguration/shutdownGracePeriod``), and then cancels stragglers.

### Standalone

``TelerouteBot/runService(gracefulShutdownSignals:)`` wraps the bot in its own
`ServiceGroup` and converts `SIGTERM`/`SIGINT` into a graceful shutdown:

```swift
let bot = try TelerouteBot(token: token, router: router, logger: logger)
try await bot.runService()
```

### Composed with Other Services

In a real deployment the bot usually runs next to a database, an HTTP server,
or background workers — compose them in one `ServiceGroup`:

```swift
let group = ServiceGroup(
    services: [database, bot],
    gracefulShutdownSignals: [.sigterm, .sigint],
    logger: logger
)
try await group.run()
```

`run()` is the `Service` entry point; `start()` and `shutdown()` are available
for manual lifecycles. Repeated `start()` calls are idempotent, and a bot that
was shut down cannot be started again (``TelerouteBotError/stopped``).

### Long Polling Configuration

Polling behavior lives in ``TelegramPollingConfiguration``:

```swift
let configuration = TelerouteConfiguration(
    polling: .init(
        limit: 100,                    // updates per getUpdates call
        timeout: 30,                   // long-poll wait in seconds
        allowedUpdates: .automatic,    // derived from routes (see Routing)
        deleteWebhookOnStart: true,    // Telegram rejects polling while a webhook is set
        initialBackoff: .seconds(1),
        maximumBackoff: .seconds(30)
    )
)
```

Polling failures never abort the loop — they are logged and retried with
jittered exponential backoff.

### Webhooks

For webhook delivery, run the bot in ``TelerouteBotMode/webhook`` mode and
serve the endpoint with the `TelerouteHummingbird` product:

```swift
import Hummingbird
import TelerouteHummingbird

let bot = try TelerouteBot(token: token, router: router, logger: logger, mode: .webhook)

let hbRouter = Router()
hbRouter.registerTelegramWebhook(bot: bot, path: "/telegram", secretToken: secret)
let app = Application(
    router: hbRouter,
    configuration: .init(address: .hostname("0.0.0.0", port: 8080))
)

let group = ServiceGroup(
    services: [
        app,                                     // serves the endpoint
        bot,                                     // routes the updates
        TelegramWebhookService(bot: bot, configuration: .init(
            url: "https://bot.example.com/telegram",
            secretToken: secret
        )),                                      // registers the webhook with Telegram
    ],
    gracefulShutdownSignals: [.sigterm, .sigint],
    logger: logger
)
try await group.run()
```

The webhook handler verifies `X-Telegram-Bot-Api-Secret-Token` in constant
time, decodes the update, and feeds it into the same routing pipeline that
long polling uses. `TelegramWebhookService` calls `setWebhook` on startup with
the route-derived `allowed_updates`.

### Custom Servers and Manual Delivery

``TelerouteBot/process(_:)`` is the seam for any server or transport — Vapor,
raw NIO, a queue consumer, or tests:

```swift
let bot = try TelerouteBot(token: token, router: router, logger: logger, mode: .manual)
try await bot.start()

// Wherever your updates come from:
await bot.process(decodedUpdates)
```

Use ``TelerouteBot/resolvedAllowedUpdates(_:)`` to obtain the wire strings for
your own `setWebhook` call.

### Graceful Shutdown Semantics

On shutdown the bot:

1. stops accepting new updates,
2. cancels the polling connection (if any),
3. waits up to `shutdownGracePeriod` (default 15 s) for in-flight handlers,
4. cancels the stragglers and finishes all event streams.

```swift
let configuration = TelerouteConfiguration(shutdownGracePeriod: .seconds(30))
```

### Concurrency Limits

``TelerouteConfiguration/maximumConcurrentUpdates`` (default 64) bounds how
many handlers execute simultaneously; additional updates queue. Per-command
serialization is available via `queue:` scopes (``TelerouteQueueScope``); see
<doc:Routing>.
