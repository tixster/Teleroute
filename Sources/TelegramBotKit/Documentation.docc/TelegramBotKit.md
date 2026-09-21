# ``TelegramBotKit``

A standalone, fully typed Telegram Bot API client with production-grade rate limiting.

## Overview

`TelegramBotKit` is the client layer underneath the Teleroute router — and a
complete Telegram client on its own for projects that don't need routing.

``TelegramBotClient`` exposes one flat, fully typed method per Bot API
operation (185 operations), generated from Telegram's own documentation:

```swift
import TelegramBotKit

let client = try TelegramBotClient(token: token)

try await client.sendMessage(chatId: .id(chatId), text: "Hello!")
try await client.sendPoll(
    chatId: .id(chatId),
    question: "Best color?",
    options: [.init(text: "Red"), .init(text: "Blue")]
)
try await client.banChatMember(chatId: "@group", userId: 42)
try await client.sendVideo(
    chatId: .id(chatId),
    video: .upload(filename: "clip.mp4", data: data)   // or .fileID / .url
)
```

Every method unwraps Telegram's `{ok, result}` envelope; failures throw
``TelegramAPIError`` with the decoded `error_code`, `description`, and
`retry_after`:

```swift
do {
    try await client.sendMessage(chatId: .id(chatId), text: text)
} catch let error as TelegramAPIError {
    if let retryAfter = error.retryAfter {
        // flood-limited; the built-in policy usually handles this for you
    }
}
```

Anything Telegram ships before Teleroute regenerates is still reachable
through ``TelegramBotClient/call(_:_:as:)``:

```swift
let result: SomeNewType = try await client.call(
    "someNewMethod",
    ["chat_id": chatId]
)
```

### Built-In Policies

The default client configuration applies Telegram-aware policies, each
configurable or removable; see <doc:ClientPolicies>:

- a global 30 req/s token-bucket rate limit (``TelegramRateLimit``);
- bounded automatic retry on 429 flood-wait responses
  (``TelegramFloodWaitPolicy``);
- optional per-chat send pacing (``TelegramSendPacing``).

### Vocabulary

The Bot API model types carry their own names — `Update`, `Message`, `User`,
`Chat`, `ChatId`, and the rest — generated into `TelegramBotAPI` and re-exported
from here, so importing this module is enough. Alongside them are hand-written
enums for the strings the documentation leaves untyped (``ParseMode``,
``ChatType``, ``ChatAction``) and ergonomic helpers:

```swift
let a: ChatId = 123            // integer literal → numeric id
let b: ChatId = "@channel"     // string literal → username
let c: ChatId = .id(456)

let markup: ReplyMarkup = .inline(InlineKeyboardMarkup(rows: [[button]]))
```

``UpdateKind`` enumerates every update payload kind, and ``FileInput``
describes file arguments (`.fileID` / `.url` / `.upload(filename:data:)`).
`BotAPIVersion.version` reports which Bot API revision the model types were
generated from.

## Topics

### Client

- <doc:ClientPolicies>
- ``TelegramBotClient``
- ``TelegramAPIError``

### Policies

- ``TelegramRateLimit``
- ``TelegramRateLimitMiddleware``
- ``TelegramFloodWaitPolicy``
- ``TelegramSendPacing``

### Text Utilities

- ``TelegramText``

### Vocabulary

- ``Update``
- ``UpdateKind``
- ``Message``
- ``User``
- ``Chat``
- ``ChatId``
- ``ChatType``
- ``ChatAction``
- ``ChatMember``
- ``CallbackQuery``
- ``MaybeInaccessibleMessage``
- ``MessageEntity``
- ``BotCommand``
- ``BotCommandScope``
- ``ParseMode``
- ``FileInput``

### Keyboard Types

- ``ReplyMarkup``
- ``InlineKeyboardMarkup``
- ``InlineKeyboardButton``
- ``ReplyKeyboardMarkup``
- ``ReplyKeyboardRemove``
- ``ForceReply``

### Media Types

- ``InputMedia``
- ``MediaGroupInputMedia``
