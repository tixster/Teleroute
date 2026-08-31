# Client Policies

Rate limiting, flood-wait retries, and per-chat pacing that keep the bot inside Telegram's limits.

## Overview

Telegram enforces several rate limits: roughly 30 requests per second overall,
about one message per second per chat, and about twenty messages per minute
per group. Exceeding them yields HTTP 429 responses with a `retry_after`
interval. ``TelegramBotClient`` ships policies for all three, enabled through
the convenience initializer:

```swift
let client = try TelegramBotClient(
    token: token,
    rateLimit: .default,                 // 30 req/s token bucket
    floodWaitPolicy: .default,           // bounded 429 retry
    sendPacing: .telegramDefaults        // per-chat pacing (opt-in)
)
```

Pass `nil` for any policy to disable it.

### Global Rate Limit

``TelegramRateLimit`` is a continuously refilling token bucket applied to
every operation **except** `getUpdates`, so long polling is never starved by
outbound sends:

```swift
TelegramRateLimit(requestsPerSecond: 30)             // Telegram's documented limit
TelegramRateLimit(requestsPerSecond: 20, burst: 40)  // custom sustained + burst
```

The policy is implemented as ``TelegramRateLimitMiddleware``, an OpenAPI
client middleware — reuse it when constructing a client over a custom
transport.

### Flood-Wait Retry

``TelegramFloodWaitPolicy`` retries 429 responses after Telegram's
`retry_after` interval, bounded in both count and wait:

```swift
TelegramFloodWaitPolicy(maxRetries: 2, maxWait: .seconds(30))  // the default
```

Waits longer than `maxWait` surface the error immediately instead of blocking
the caller; the failure arrives as ``TelegramAPIError`` with `retryAfter`
populated. Retries are skipped for `getUpdates` and for requests whose body
cannot be replayed.

### Per-Chat Send Pacing

``TelegramSendPacing`` serializes outbound sends per chat so bursts to one
chat are spread out instead of triggering 429s:

```swift
TelegramSendPacing(
    perChatInterval: .seconds(1),   // private chats
    perGroupInterval: .seconds(3)   // groups/channels (negative ids, @usernames)
)
// or simply:
TelegramSendPacing.telegramDefaults
```

Pacing is applied by the generated wrappers for every operation that carries a
`chat_id`. It is off by default — enable it for bots that fan out messages.

### Custom Transports and Middlewares

The designated initializer accepts any OpenAPI `ClientTransport` and
middleware stack — the seam used by proxies, custom HTTP clients, and the
in-process test transports:

```swift
let client = try TelegramBotClient(
    token: token,
    transport: myTransport,
    middlewares: [TelegramRateLimitMiddleware(limit: .default)],
    sendPacing: nil
)
```

### Chat Targets

``ChatId`` is accepted everywhere a chat is addressed, with literal
conveniences:

```swift
try await client.sendMessage(chatId: 123, text: "hi")          // numeric literal
try await client.sendMessage(chatId: "@channel", text: "hi")   // username literal
try await client.sendMessage(chatId: .id(userId), text: "hi")
```
