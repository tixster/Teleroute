# ``TelerouteHummingbird``

Serve Telegram webhooks from a Hummingbird 2 application.

## Overview

`TelerouteHummingbird` connects a `TelerouteBot` to a Hummingbird 2 server for
webhook delivery: one extension method registers the endpoint, and one service
registers the webhook with Telegram.

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

### The Endpoint

`registerTelegramWebhook(bot:path:secretToken:maxBodySize:)` — an extension on
Hummingbird's `RouterMethods` — registers a `POST` handler that:

1. verifies `X-Telegram-Bot-Api-Secret-Token` in **constant time** when a
   secret is configured (rejecting mismatches with 401);
2. decodes the `Update` (400 on malformed bodies);
3. feeds it into the bot's routing pipeline via `TelerouteBot.process(_:)`.

The default path is `/telegram-webhook` and the default body limit is 1 MiB.
Because the endpoint is a plain Hummingbird route, it composes with your
app's other routes, middleware, and TLS termination as usual.

### Webhook Registration

``TelegramWebhookService`` is a `swift-service-lifecycle` `Service` that calls
`setWebhook` on startup — with the `allowed_updates` derived from the bot's
registered routes — then parks until graceful shutdown.
``TelegramWebhookConfiguration`` controls the details:

```swift
TelegramWebhookConfiguration(
    url: "https://bot.example.com/telegram",
    secretToken: secret,            // strongly recommended
    dropPendingUpdates: true,       // discard the backlog on deploy
    allowedUpdates: .automatic,     // or .all / .explicit([...])
    deleteWebhookOnShutdown: false  // keep the webhook across restarts
)
```

> Important: Run the bot in `.webhook` mode (`TelerouteBot(mode: .webhook)`)
> so it does not also start a long-polling loop — Telegram rejects
> `getUpdates` while a webhook is registered.

### Custom Servers

Nothing in the pipeline requires Hummingbird: any server that can verify the
secret header, decode an `Update`, and call `TelerouteBot.process(_:)` works.
This module is a thin, reusable implementation of exactly those steps.

## Topics

### Webhook Serving

- ``TelegramWebhookConfiguration``
- ``TelegramWebhookService``
