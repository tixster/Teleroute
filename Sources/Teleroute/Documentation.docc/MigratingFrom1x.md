# Migrating from 1.x

Move a Teleroute 1.x bot to the 2.0 handler style, vocabulary, and lifecycle.

## Overview

Teleroute 2.0 is a breaking release: one handler style, the whole Bot API as
typed methods, routing for every update kind, and a `Service`-based lifecycle.
This article maps 1.x constructs to their 2.0 equivalents.

### Handler Registration

| 1.x | 2.0 |
| --- | --- |
| `router.onCommand("x") { ctx in ... }` | `router.command("x") { ctx in ... }` (Void closure) |
| `router.command("x") { _ in .reply("hi") }` | unchanged — or `{ _ in "hi" }`, `{ _ in Reply("hi").silent() }` |
| `router.onCallback(...)` | `router.callback(...)` with a Void closure |
| guard returns `false` | guard returns `.skip` (or `.deny(.reply("No"))`) |
| `TelerouteMiddleware` (Void) + `TelerouteRouterMiddleware` | one ``TelerouteMiddleware`` returning ``TelerouteResponse`` |
| `bot.attach()` | removed — ``TelerouteBot/process(_:)`` / ``TelerouteBot/test(_:)`` need no attach step |

Handlers may now return `String`, the ``Reply`` / ``Send`` / ``Edit`` /
``AnswerCallback`` / ``Delete`` / ``React`` builders, ``TelerouteResponse``,
`Optional`, arrays (a sequence), or `.unhandled` to fall through to the next
candidate route; see <doc:Responses>.

### Client and Naming

- All `TG`-prefixed types are gone: `Update`, `Message`, `ChatId`, … come from
  the bundled `TelegramBotKit` vocabulary over the generated `TelegramBotAPI`.
- `updateId`, `messageId`, and friends are `Int64`.
- Chat targets are `ChatId` everywhere: `to: 123`, `to: "@channel"`,
  `.id(x)`, `.username("@x")` — no more `Int64?` chat parameters.
- `TelegramBotClient` has a typed flat method for **every** operation;
  `context.bot.call(_:_:as:)` reaches anything newer than the snapshot.
- `TGFileInfo` → `FileInput` (`.fileID` / `.url` / `.upload(filename:data:)`).
- `answerCallbackQuery(cacheTime:)` takes `Int64`.

### Behavior Changes

- `context.reply` performs a real reply (`reply_parameters`); use
  `context.send` for an unlinked message.
- Handled callback queries are auto-answered unless the handler answered or
  called `context.skipCallbackAutoAnswer()`
  (``TelerouteConfiguration/autoAnswerCallbackQueries`` disables globally).
- ``TelerouteConfiguration/defaultParseMode`` applies to all text helpers.
- 429 responses are retried automatically (`floodWaitPolicy` on the client),
  and `sendPacing: .telegramDefaults` opts into per-chat pacing.
- `allowed_updates` is derived from registered routes
  (``TelerouteAllowedUpdates/automatic``).

### Lifecycle

- ``TelerouteBot`` conforms to `Service`; ``TelerouteBot/run()`` participates
  in graceful shutdown, and
  ``TelerouteBot/runService(gracefulShutdownSignals:)`` wires
  `SIGTERM`/`SIGINT`.
- Shutdown drains in-flight handlers up to
  ``TelerouteConfiguration/shutdownGracePeriod`` (default 15 s) before
  cancelling.
- ``TelerouteBotMode`` selects `.polling` (default), `.webhook`, or `.manual`;
  webhook serving lives in the `TelerouteHummingbird` product
  (<doc:LifecycleAndWebhooks>).

### Contexts

- Every helper (media, chat admin, publishing, flows) is available on any
  ``TelerouteRequestContext`` — `context.coreContext.sendPhoto(...)` becomes
  `context.sendPhoto(...)`; flow contexts included.
- ``TelerouteHandlingCommand`` / ``TelerouteHandlingCallback`` declare an
  `associatedtype Context` and return a ``TelerouteResponse``.

### Macros

`@TelerouteCommand` / `@TelerouteCallback` support `Int`, `Int64`, `Double`,
`Bool`, and `String` properties; `var x: T = default` decodes with a default;
malformed input throws ``TelerouteError/invalidParameter(name:value:)``. See
<doc:TypedRoutesAndMacros>.

### Tests

- Fakes moved to the transport seam: `TelerouteRecordingTransport` (with a
  `fallback:` hook for any operation) and `TelerouteStubTransport`;
  `TelerouteTestSupport.makeClient` / `makeTelerouteBot` build clients and
  bots.
- New synthetic factories: `makeInlineQueryUpdate`, `makeReactionUpdate`,
  `makeChatMemberUpdate`, `makePreCheckoutUpdate`, `makeJoinRequestUpdate`,
  `makePollAnswerUpdate`, `makePhotoMessageUpdate`, `makeEditedMessageUpdate`.

See <doc:Testing> for the full in-process testing model.
