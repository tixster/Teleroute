# Migrating Teleroute 2.x → 3.0

Teleroute 3.0 generates its Bot API layer from Telegram's own documentation
instead of a third-party OpenAPI specification. The model types keep their
shape and their field names; what changes is where they live, how the
documentation's string values are typed, and the transport protocol underneath
the client.

Most of it is mechanical. If your code only calls `context.bot.sendMessage(…)`
and reads `Update`/`Message`/`ChatId`, you may have nothing to change at all.

## Type names

The prefix-free names Teleroute 2.0 re-exported (`Update`, `Message`, `User`,
`Chat`, `ChatId`, `ReplyMarkup`, …) are unchanged. Everything else loses the
namespace:

| 2.x | 3.0 |
|---|---|
| `Components.Schemas.ChatPermissions` | `ChatPermissions` |
| `Components.Schemas.InlineQuery` | `InlineQuery` |
| `Components.Schemas.MessageId` | `MessageId` |
| `import TelegramBotAPI` for `Components`/`Operations` | not needed — the names are re-exported from `TelegramBotKit` |

A find-and-replace of `Components.Schemas.` with nothing handles this.

`Operations.*` is gone entirely; see [Client](#client) below.

## `_type` is now `type`

`type` is not a Swift keyword, and the previous generator's `_type` spelling
was noise on the most-used field name in the API.

| 2.x | 3.0 |
|---|---|
| `message.entities?.first?._type` | `message.entities?.first?.type` |
| `MessageEntity(_type: "bold", offset: 0, length: 4)` | `MessageEntity(type: .bold, offset: 0, length: 4)` |
| `chat._type` | `chat.type` |

## Documented value lists are now enums

Where the documentation spells out what a `String` field accepts, that field
now has a type. 49 enums cover about 130 fields.

| 2.x | 3.0 |
|---|---|
| `chat._type == "supergroup"` | `chat.type == .supergroup` |
| `sticker._type == "mask"` | `sticker.type == .mask` |
| `poll._type == "quiz"` | `poll.type == .quiz` |
| `entity._type == "bot_command"` | `entity.type == .botCommand` |
| `maskPosition.point == "forehead"` | `maskPosition.point == .forehead` |

Every one of them carries an `unknown(String)` case, so a value Telegram
introduces after these sources were generated is surfaced rather than rejected:

```swift
switch chat.type {
case .private, .group: …
case let .unknown(raw): logger.warning("new chat type: \(raw)")
default: …
}
```

Each enum is `RawRepresentable` with a `String` raw value, and exposes
`documentedCases` — every value documented at generation time.

### `ChatType` moved from hand-written to generated

`ChatType` kept its cases, but its initializer is no longer failable, because
an unrecognised value now becomes `.unknown` instead of `nil`:

| 2.x | 3.0 |
|---|---|
| `ChatType(rawValue: raw)` → `ChatType?` | `ChatType(rawValue: raw)` → `ChatType` |
| `if let type = ChatType(rawValue: raw) { … }` | `let type = ChatType(rawValue: raw)` |
| `chat.chatType` (helper, optional) | `chat.type` (non-optional) |

`ParseMode`, `ChatAction` and `FileInput` are unchanged — their values live in
prose sections the parser does not read, so they stay hand-written.

## Union variants carry a typed discriminator

A variant's `type`/`status`/`source` field is now a `<Union>Kind` enum, and it
defaults to the case the variant always carries. Passing it is redundant:

| 2.x | 3.0 |
|---|---|
| `BotCommandScopeChat(type: "chat", chatId: id)` | `BotCommandScopeChat(chatId: id)` |
| `BotCommandScopeDefault(type: "default")` | `BotCommandScopeDefault()` |
| `ReactionTypeEmoji(type: "emoji", emoji: "👍")` | `ReactionTypeEmoji(emoji: "👍")` |
| `InlineQueryResultArticle(type: "article", id: …)` | `InlineQueryResultArticle(id: …)` |

Union enum case names are unchanged: `.creator`, `.administrator`,
`.InlineQueryResultArticle`, `.Message`, and so on.

## Client

| 2.x | 3.0 |
|---|---|
| `context.bot.api.someMethod(…)` | `try await context.bot.call("someMethod", ["chat_id": id])` |
| `TelegramBotClient(api:sendPacing:)` | removed — construct with a transport |
| — | `TelegramBotClient(token:serverURL:)` for a local Bot API server |
| — | `BotAPIVersion.version` reports the Bot API revision the types came from |

`call(_:_:as:)` covers the case `api` actually served: reaching a method
Telegram shipped before Teleroute regenerated.

`TelegramAPIError` is unchanged — same properties, same initializer.

## Transports and middleware

`swift-openapi-runtime` and `swift-openapi-async-http-client` are gone. The
client talks through Teleroute's own protocol, with `Data` bodies instead of
`HTTPBody`:

| 2.x | 3.0 |
|---|---|
| `ClientTransport` | `TelegramTransport` |
| `ClientMiddleware` | `TelegramMiddleware` |
| `body: HTTPBody?` | `body: Data?` |
| `-> (HTTPResponse, HTTPBody?)` | `-> (HTTPResponse, Data)` |
| `AsyncHTTPClientTransport(configuration:)` | `AsyncHTTPClientTelegramTransport(client:timeout:maximumResponseBytes:)` |

A custom transport shrinks in the process, because there is no stream to
collect:

```swift
// 2.x
func send(_ request: HTTPRequest, body: HTTPBody?, baseURL: URL, operationID: String)
    async throws -> (HTTPResponse, HTTPBody?) {
    let data = try await Data(collecting: body ?? .init(), upTo: 10 * 1024 * 1024)
    …
}

// 3.0
func send(_ request: HTTPRequest, body: Data?, baseURL: URL, operationID: String)
    async throws -> (HTTPResponse, Data) {
    let data = body ?? Data()
    …
}
```

`TelerouteStubTransport` and `TelerouteRecordingTransport` conform to the new
protocol; `TelerouteBot.init(…, transport:)` takes `any TelegramTransport`.

## Keyboard button style

`style` was an untyped string and is now `KeyboardButtonStyle`:

| 2.x | 3.0 |
|---|---|
| `route.button(callback, "Open", style: "primary")` | `route.button(callback, "Open", style: .primary)` |
| `.callback("Delete", Remove(), style: "danger")` | `.callback("Delete", Remove(), style: .danger)` |

## Wire format

Requests go out as JSON unless a call actually uploads bytes; only then does
the whole request become `multipart/form-data`. In 2.x the choice was fixed per
method by the specification, and 33 operations were multipart whether or not
they carried a file.

This is invisible to normal use. It matters if you have a **test double that
asserts a wire format per method**: `editMessageText`, `sendPoll`,
`answerInlineQuery` and about seventeen others now arrive as JSON. Sniff
`Content-Type` rather than keying off the operation name.

Within a multipart request, arrays and objects are still sent as a single
JSON-serialized part.

## `TelerouteError` gained new cases

`TelerouteError` is not frozen, and 3.0 adds five cases. An exhaustive `switch`
over it in your own code needs the new branches (or a `default`):

| Case | Thrown when |
|---|---|
| `callbackDataTooLong(String, bytes: Int)` | Rendered `callback_data` exceeds Telegram's 64-byte limit. Previously the value went out and the API rejected the message with a 400. |
| `keyboardScopeMissing` | `context.keyboard { … }` is called on a context built directly rather than by a running router. |
| `ambiguousCallbackRoute(String, matches: [String])` | A bare callback value matches more than one registered route, so the one to link cannot be inferred. Render it from a route handle instead. |
| `inlineActionContextMissing` | A button with an inline handler is rendered outside a request context (for example from `router.keyboard { … }` at registration time). |
| `inlineActionsDisabled` | A button with an inline handler is rendered while `TelerouteConfiguration.inlineActions` is `.disabled`. |

Note that the 64-byte limit counts **bytes**, and route parameters are
percent-encoded: one Cyrillic character becomes six bytes, so callback data
that fits in 64 characters can still be over the limit. If a route of yours was
silently producing oversized data, it now fails at render time instead of at
send time.

## New, nothing to change

These are additive; existing code keeps compiling.

| Area | What is new |
|---|---|
| Keyboards | `Reply`/`Send`/`Edit` take the keyboard builder directly (`Reply("…").keyboard { … }`), rendered against the serving router when the response executes. `context.keyboard { … }` returns a markup from inside a handler. |
| Buttons | `TelerouteButton` gained initializers (`TelerouteButton("Next") { OrderPage(…) }`, `TelerouteButton("Docs", url: …)`, `TelerouteButton("3 / 10", .disabled)`) and the chainable `style(_:)` / `icon(_:)`. A bare callback value now resolves to a route registered in any group, not only the rendering scope. |
| Edit targeting | `edit`, `editCaption`, `editReplyMarkup`, and the `Edit` response now reach inline-mode messages (`inline_message_id`) and messages the bot can no longer read, instead of throwing `messageTargetMissing`. `context.resolvedEditTarget(messageId:in:)` exposes the same resolution for operations the helpers do not wrap. |
| Inline handlers | A button can carry its handler (`TelerouteButton("Approve") { press in … }`) once `TelerouteConfiguration.inlineActions` is `.enabled(…)`. Handlers are in-memory: they expire, do not survive a restart, and do not work across replicas. `onSuccess: .removeButton` / `.removeKeyboard` clears the button after a clean return; `context.removePressedButton()` does the same by hand from any callback handler. |
| Buttons | `Array<TelerouteButton>.grid(columns:)`, `TeleroutePagination.pageStrip(…)`, `navigationRow(…, counter: true)`, `TelerouteConfirm.row(…)`; `TelerouteButton.disabled/callbackGame/switchInlineQuery(chosenChat:)`; the full `KeyButton` surface (`requestUsers`, `requestChat`, `requestPoll`, `webApp`, `requestManagedBot`, `icon`, `style`). A `for` loop now compiles inside `KeyRow { }`. |
| Responses | `Reply`/`Send` gained `removeKeyboard()` and `forceReply(placeholder:selective:)`. |
| Bootstrap | `logger:` defaults to `Logger(label: "teleroute")`; `TelerouteEnvironment.token()` reads `TELEGRAM_BOT_TOKEN`; `bot.mode` is public; `bot.runService(with:)` composes the bot with other services. |
| Hummingbird | `registerTelegramWebhook(bot:webhook:)` derives the path and secret from one `TelegramWebhookConfiguration`; `Router.addTeleroute(_:webhook:)` registers the endpoint and returns the services; `Application.addTeleroute(_:webhook:)` and `Application.teleroute(bot:webhook:…)` wire the rest. `TelegramWebhookConfiguration.randomSecret()` generates a valid secret. |

## Requirements

Swift 6.4 (was 6.3).

## Not changed

Routing, handlers, guards, middleware, flows, contexts, macros, the command
menu, the `Service` lifecycle, the existing `TelerouteHummingbird` API,
`ParseMode`, `ChatAction`, `FileInput`, `TelegramAPIError`,
`TelegramRateLimit`, `TelegramFloodWaitPolicy`, `TelegramSendPacing`, and
every one of the 185 client method signatures apart from the parameter types
noted above.
