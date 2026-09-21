# Migrating Teleroute 1.x → 2.0

Teleroute 2.0 is a breaking release: one handler style, the whole Bot API as
typed methods, routing for every update kind, and a Service-based lifecycle.

## Handler registration

| 1.x | 2.0 |
|---|---|
| `router.onCommand("x") { ctx in ... }` | `router.command("x") { ctx in ... }` (Void closure) |
| `router.command("x") { _ in .reply("hi") }` | unchanged — or `{ _ in "hi" }`, `{ _ in Reply("hi").silent() }` |
| `router.onCallback(...)` | `router.callback(...)` with a Void closure |
| guard returns `false` | guard returns `.skip` (or `.deny(.reply("No"))`) |
| `TelerouteMiddleware` (Void) + `TelerouteRouterMiddleware` | one `TelerouteMiddleware<Context>` returning `TelerouteResponse` |
| `bot.attach()` | removed — `bot.process(_:)`/`bot.test(_:)` need no attach step |

Handlers may now return `String`, `Reply`/`Send`/`Edit`/`AnswerCallback`/
`Delete`/`React` builders, `TelerouteResponse`, `Optional`, arrays (sequence),
or `.unhandled` to fall through to the next candidate route.

## Client and naming

- All `TG`-prefixed types are gone: `Update`, `Message`, `ChatId`, … (from the
  bundled `TelegramBotKit` vocabulary over the generated `TelegramBotAPI`).
- `updateId`, `messageId`, and friends are `Int64`.
- Chat targets are `ChatId` everywhere: `to: 123`, `to: "@channel"`,
  `.id(x)`, `.username("@x")` — no more `Int64?` chat parameters.
- `TelegramBotClient` has a typed flat method for **every** operation;
  `context.bot.call(_:_:as:)` reaches anything newer than the generated surface.
- `TGFileInfo` → `FileInput` (`.fileID` / `.url` / `.upload(filename:data:)`).
- `answerCallbackQuery(cacheTime:)` takes `Int64`.

## Behavior changes

- `context.reply` performs a real reply (`reply_parameters`); use
  `context.send` for an unlinked message.
- Handled callback queries are auto-answered unless the handler answered or
  called `context.skipCallbackAutoAnswer()`
  (`autoAnswerCallbackQueries: false` disables globally).
- `TelerouteConfiguration.defaultParseMode` applies to all text helpers.
- 429 responses are retried automatically (`floodWaitPolicy`), and
  `sendPacing: .telegramDefaults` opts into per-chat pacing.
- `allowed_updates` is derived from registered routes (`.automatic`).

## Lifecycle

- `TelerouteBot` conforms to `Service`; `bot.run()` participates in graceful
  shutdown, and `bot.runService()` wires SIGTERM/SIGINT.
- Shutdown drains in-flight handlers up to
  `TelerouteConfiguration.shutdownGracePeriod` (default 15 s) before
  cancelling.
- `TelerouteBot(mode:)` selects `.polling` (default), `.webhook`, or
  `.manual`; webhook serving lives in the `TelerouteHummingbird` product.

## Contexts

- Every helper (media, chat admin, publishing, flows) is available on any
  `TelerouteRequestContext` — `context.coreContext.sendPhoto(...)` becomes
  `context.sendPhoto(...)`; flow contexts included.
- `TelerouteHandlingCommand`/`TelerouteHandlingCallback` declare an
  `associatedtype Context` and return a `TelerouteResponse`.

## Macros

- `@TelerouteCommand` / `@TelerouteCallback` support `Int`, `Int64`, `Double`,
  `Bool`, and `String` properties; `var x: T = default` decodes with a
  default; malformed input throws `TelerouteError.invalidParameter`.

## Tests

- Fakes moved to the transport seam: `TelerouteRecordingTransport` (with a
  `fallback:` hook for any operation) and `TelerouteStubTransport`;
  `TelerouteTestSupport.makeClient`/`makeTelerouteBot` build clients and bots.
- New synthetic factories: `makeInlineQueryUpdate`, `makeReactionUpdate`,
  `makeChatMemberUpdate`, `makePreCheckoutUpdate`, `makeJoinRequestUpdate`,
  `makePollAnswerUpdate`, `makePhotoMessageUpdate`, `makeEditedMessageUpdate`.
