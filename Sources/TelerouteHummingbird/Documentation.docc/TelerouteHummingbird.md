# ``TelerouteHummingbird``

Serve Telegram webhooks from a Hummingbird 2 application.

## Overview

`TelerouteHummingbird` connects a `TelerouteBot` to a Hummingbird 2 server for
webhook delivery. One ``TelegramWebhookConfiguration`` drives the whole wiring:
the endpoint path comes from the URL, the secret is shared between the endpoint
and `setWebhook`, and the bot plus its registration are attached as services in
the right order.

### Building the Application

``Hummingbird/Application/teleroute(bot:webhook:configuration:logger:maxBodySize:routes:)``
builds the router, registers the endpoint, and attaches both services:

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

The result is an ordinary `Application`, so `addServices(_:)`,
`beforeServerStarts(perform:)`, and `test(_:)` all remain available.

### Using Your Own Router

`Application(router:)` builds its responder during initialization, so the
endpoint has to be registered before the application exists.
``Hummingbird/Router/addTeleroute(_:webhook:path:maxBodySize:)`` does both
halves in one expression — it registers the endpoint and returns the services
to hand to the application:

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

When the application already exists and the endpoint is registered,
``Hummingbird/Application/addTeleroute(_:webhook:)`` appends the same services.
Passing `nil` for `webhook` adds only the bot, for deployments where
`setWebhook` is run by a deploy script.

### The Endpoint

`registerTelegramWebhook(bot:webhook:path:maxBodySize:)` — an extension on
Hummingbird's `RouterMethods` — registers a `POST` handler that:

1. verifies `X-Telegram-Bot-Api-Secret-Token` in **constant time** when a
   secret is configured (rejecting mismatches with 401);
2. decodes the `Update` (400 on malformed bodies);
3. feeds it into the bot's routing pipeline via `TelerouteBot.process(_:)`.

The path comes from ``TelegramWebhookConfiguration/derivedPath``, falling back
to `/telegram-webhook` when the URL carries none; pass `path:` to override it
for deployments where a reverse proxy rewrites the path. The default body
limit is 1 MiB. Because the endpoint is a plain Hummingbird route, it composes
with your app's other routes, middleware, and TLS termination as usual.

`process(_:)` submits the update to the bot's bounded executor and returns as
soon as a slot is reserved, so Telegram is acknowledged without waiting for
the handler; the only backpressure is the bot's `maximumConcurrentUpdates`
being exhausted.

The lower-level `registerTelegramWebhook(bot:path:secretToken:maxBodySize:)`
remains available for mounting the endpoint into a route group.

### Webhook Registration

``TelegramWebhookService`` is a `swift-service-lifecycle` `Service` that calls
`setWebhook` on startup — with the `allowed_updates` derived from the bot's
registered routes — then parks until graceful shutdown.
``TelegramWebhookConfiguration`` controls the details:

```swift
TelegramWebhookConfiguration(
    url: "https://bot.example.com/telegram",
    secretToken: .randomSecret(),   // strongly recommended
    dropPendingUpdates: true,       // discard the backlog on deploy
    allowedUpdates: .automatic,     // or .all / .explicit([...])
    deleteWebhookOnShutdown: false  // keep the webhook across restarts
)
```

``TelegramWebhookConfiguration/randomSecret(length:)`` generates a secret from
the alphabet Telegram accepts (`A-Z`, `a-z`, `0-9`, `_`, `-`).

> Important: Run the bot in `.webhook` mode (`TelerouteBot(mode: .webhook)`)
> so it does not also start a long-polling loop — Telegram rejects
> `getUpdates` while a webhook is registered. All three entry points log a
> warning when a webhook is wired to a bot still in polling mode.

### Custom Servers

Nothing in the pipeline requires Hummingbird: any server that can verify the
secret header, decode an `Update`, and call `TelerouteBot.process(_:)` works.
This module is a thin, reusable implementation of exactly those steps.

## Topics

### Webhook Serving

- ``TelegramWebhookConfiguration``
- ``TelegramWebhookService``
