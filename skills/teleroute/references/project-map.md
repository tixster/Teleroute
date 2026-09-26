# Teleroute Project Map

## Targets And Commands

- Package: SwiftPM, Swift 6 language mode, Swift tools 6.4, macOS 15+.
- Library target: `Sources/Teleroute`.
- Optional macro declaration target: `Sources/TelerouteMacros`; compiler plugin: `Sources/TelerouteMacroPlugin`.
- Example executable: `Sources/TelerouteExample`.
- Benchmark executable: `Sources/TelerouteBenchmarks` (`swift run -c release TelerouteBenchmarks`).
- Tests: `Tests/TelerouteTests`, using Swift Testing.
- Common checks: `swift build`, `swift test`, `swift test --filter <test-name>`, `swift test --sanitize=thread`, `swift build -c release`.

## Source Areas

- `Sources/TelegramBotAPI/Generated`: every documented Bot API type under a flat top-level name, one file per type, foldered by documentation section (`AvailableTypes/`, `RichMessages/`, …; `Values/` holds enums recovered from field descriptions, `Shared/` the unions Telegram only spells out inline). Generated from `botapi/telegram-bot-api.html` by `Tooling/BotAPIGen`, a dev-only package outside the main graph (`swift test --package-path Tooling/BotAPIGen`). Regenerate with `Scripts/generate-api.sh`; never edit by hand.
- `Sources/TelegramBotKit/Generated`: the 185 flat client methods plus `UpdateKind`, from the same snapshot.
- `Sources/TelegramBotKit/TelegramVocabulary.swift`: re-exports `TelegramBotAPI` and adds Teleroute-owned `ParseMode`, `ChatType`, `ChatAction`, `FileInput`, plus ergonomics extensions (`ChatId.id/.username`, `ReplyMarkup.inline`, `MaybeInaccessibleMessage.accessibleMessage`).
- `Sources/TelegramBotKit/TelegramBotClient.swift`: transport and middleware chaining, envelope unwrapping, the `call(_:_:as:)` escape hatch for methods newer than the snapshot.
- `Sources/TelegramBotKit/TelegramRequest.swift`, `TelegramRequestEncoder.swift`, `TelegramResponse.swift`: request building, JSON/multipart encoding (multipart only when a call uploads bytes), and `{ok, result}` envelope decoding.
- `Sources/TelegramBotKit/TelegramAPIError.swift`: error decoded from Telegram's `ok: false` envelope.
- `Sources/Teleroute/Telegram/TelegramLongPollingConnection.swift`: owned `getUpdates` loop with offset tracking, jittered backoff, webhook cleanup, cancellation.
- `Sources/TelegramBotKit/TelegramTransport.swift`: the `TelegramTransport` / `TelegramMiddleware` protocols (HTTPTypes request, `Data` body); `AsyncHTTPClientTelegramTransport.swift` is the default implementation.
- `Sources/TelegramBotKit/TelegramRateLimit.swift`: token-bucket `TelegramMiddleware` (default 30 req/s, `getUpdates` exempt).
- `Core/TelerouteBot.swift`: public routed-bot lifecycle, command publishing delegation, event streams, in-process test client, and graceful shutdown.
- `Core/TelerouteConfiguration.swift`: public runtime dependencies and policies.
- `Core/TelerouteRuntime.swift`: test-SPI runtime owning the update pipeline: processing order, event emission, error handling, metrics, and replay protection.
- `Core/TelerouteParsedUpdate.swift`: one-pass extraction of command, callback, message, identity, flow key, and route-kind metadata for one routing pass.
- `Core/TelerouteUpdateExecutor.swift`: bounded update execution, backpressure, cancellation, and synchronous shutdown state.
- `Core/TelerouteDiscussionForwards.swift`: discussion-forward policy, forward/error types, and the tracker that buffers automatic channel forwards, resolves linked chats via `getChat`, and resumes continuation-based waiters.
- `Routing/Teleroute.swift`: public generic router/group APIs, middleware collections, custom/child context execution, response and side-effect registration.
- `Routing/TelerouteRoutes.swift`: low-level test-SPI registration scope used by the runtime and public router adapter.
- `Routing/TelerouteRuntime+Routes.swift`: test-SPI compatibility used by low-level invariant tests only.
- `Routing/TelerouteCallbackRoute.swift`: scope-bound typed callback registration handles used to build buttons and callback data safely.
- `Routing/TelerouteMatching.swift`: synchronized storage, compiled route graph/indexes, registered callback-path validation, route signatures, matching, rendering, and percent encoding.
- `Routing/TelerouteMiddlewareRunner.swift`: registration-time middleware pipeline compilation and consuming middleware semantics.
- `Routing/TelerouteRateLimitMiddleware.swift`: throttle/debounce middleware and consuming fallback behavior.
- `Routing/TelerouteCommandQueue.swift`: command queue strategies and flow session queueing.
- `Routing/TeleroutePublishedCommands.swift`: Telegram command visibility scopes, command-set generation, publishing helpers.
- `Routing/TelerouteEvents.swift`: lifecycle event payloads and async event sequence.
- `Routing/TelerouteReplayProtection.swift`: replay claim storage and in-memory cleanup.
- `Composition/TelerouteBuiltInMiddleware.swift`: access-log, timeout, retry, and error-handling middleware.
- `Composition/TelerouteGuards.swift`: built-in chat-type, allowlist, argument-count, and admin guards.
- `Composition/TelerouteKeyboard.swift`: validated `TelerouteButton` descriptions, route-bound button construction, raw-button escape hatch, and pagination helpers.
- `Typed/TelerouteCommand.swift`, `Typed/TelerouteCallback.swift`, `Typed/TelerouteTypedRoutes.swift`: typed command/callback contracts, opt-in self-handling protocols, and registration overloads.
- `Sources/TelerouteMacros/TelerouteMacros.swift`: optional-product declarations for `@TelerouteCommand` and `@TelerouteCallback`.
- `Sources/TelerouteMacroPlugin/*`: SwiftSyntax macro implementations and compiler plugin entry point.
- `Flow/TelerouteFlow.swift`, `Flow/TelerouteFlowState.swift`, `Flow/TelerouteFlowStorage.swift`: multi-step flow APIs, flow context, storage, transitions, finish/cancel behavior.
- `Flow/TelerouteFlowCoordinator.swift`: flow fast path, per-session serialization, active-session lookup, and indexed step matching.
- `Flow/TelerouteFlowCancellationPolicy.swift`: policies for unmatched commands during active flows.
- `Composition/TelerouteRouteCollection.swift`: public typed route-collection composition and test-SPI legacy module support.
- `Composition/TelerouteMiddleware.swift`: `TelerouteGuard`, `TelerouteMiddleware`, internal consuming marker, guard composition.
- `Context/TelerouteContext.swift`, `Context/TelerouteContext+Media.swift`: handler context plus media, forwarding, editing, delete, and chat-action helpers.
- `Context/TelerouteMetricsSink.swift`: observability sink protocol and default no-op implementation.
- `Context/*`: command matches, route parameters, errors, and error-handling hooks.

## Routing Invariants

- `Teleroute` processes active flow routes first, then regular callbacks, then regular commands.
- Grouped command names use `_` because Telegram commands do not support slash hierarchy.
- Callback routes keep slash hierarchy and use `{parameter}` placeholders.
- Callback data generation and matching should stay symmetric; parameter values are percent-encoded when rendered and decoded on match.
- Unbound typed buttons render only when their full callback path is registered in that exact scope; route-bound buttons may cross scopes within the same router but not router instances.
- Duplicate route diagnostics intentionally ignore guarded routes because same path plus different guards is supported.
- Automatic channel forwards into a linked discussion chat are recorded and passed to `onDiscussionForward` observers before replay protection and routing; observers never change the routing outcome or emit terminal events.
- Replay protection deduplicates repeated commands and callbacks for the same chat/user scope within the configured TTL.
- Route evaluation is registration ordered; the first route whose guard/middleware chain reaches its final handler wins.
- Every update uses one immutable route-graph snapshot; route registration incrementally updates command, callback, and flow indexes.
- Update processing is bounded by `Configuration.maximumConcurrentUpdates` and applies suspension-based backpressure when full.
- Consuming middleware that does not call `next` must conform to `TelerouteConsumingMiddleware`; otherwise fallback routes can still be considered unhandled.
- Flow sessions are scoped by `chatId + userId`. Active flow updates for one scope should be serialized.
- A Telegram command during an active flow first checks flow-local command routes. What happens next is controlled by `TelerouteFlowCancellationPolicy`; the default still cancels and then continues normal command routing.
- Observability side effects should stay coherent: received/skipped/handled/unmatched/failed events and metrics callbacks should describe the same routing outcome.

## Public API Surfaces

- Lifecycle and integration: `TelerouteBot`, `TelerouteConfiguration`, idempotent `attach()`/`start()`, blocking `run()`, `eventStream(buffering:)`, published-command helpers, in-process `test`, and async `shutdown()`.
- Registration: `Teleroute<Context>` and `TelerouteRouterGroup<Context>` expose raw/typed commands and callbacks, `onCommand`/`onCallback`, groups, route collections, flows, typed callback rendering, buttons, keyboards, and middleware/guard collections.
- Contexts and responses: `TelerouteRequestContext`, `TelerouteInitializableRequestContext`, `TelerouteChildRequestContext`, `TelerouteRouterMiddleware`, and `TelerouteResponse`.
- Typed callback routes: typed registration returns `TelerouteCallbackRoute<Callback>`, whose buttons retain the registered scope and router identity.
- Typed specs: `TelerouteCommand` and `TelerouteCallback` decode values. Registrations may use explicit handlers, while `TelerouteHandlingCommand` and `TelerouteHandlingCallback` opt small routes into closure-free registration.
- Route collections: `TelerouteRouteCollection.addRoutes(to:)` may return typed `Exports`; `addRoutes(_:)` returns those exports to parent composition.
- Macros: the optional `TelerouteMacros` product provides `@TelerouteCommand` and `@TelerouteCallback`; runtime-only targets depend on `Teleroute` alone.
- Flows: `TelerouteFlow`, `TelerouteFlowGroup`, `TelerouteFlowContext`, `TelerouteFlowCancellationPolicy`, and flow storage abstractions cover flow starts, messages, commands, callbacks, transitions, values, cancellation, and finish behavior.
- Context helpers: `reply`, `send`, `edit`, `answerCallbackQuery`, media sends, message forwarding/deletion/editing, chat actions, parsed `command`, `parameters`, `message`, `callbackQuery`, `callbackData`, `chatId`, `userId`, `activeFlow`.
- Observability and recovery: `bot.eventStream(buffering:)`, `TelerouteBot.Configuration.onError`, and `TelerouteMetricsSink`.
- Published commands: visibility helpers include `.default`, `.allPrivateChats`, `.allGroupChats`, `.allChatAdministrators`, `.chat`, `.chatAdministrators`, and `.chatMember`.

## Test Patterns

- Keep tests in `Tests/TelerouteTests` and prefer Swift Testing.
- Shared fixtures live in `TelerouteTestSupport`; reuse `makeClient`, `makeTelerouteBot`, `makeCommandUpdate`, `makeMessageUpdate`, `makeCallbackUpdate`, `TelerouteTestRecorder`, mock flow storage, fake `TelegramTransport` implementations, and command publishing recorders.
- `TelerouteStageBTests.swift` covers guards and built-in middleware.
- `TelerouteStageETests.swift` covers keyboard descriptions, pagination, metrics, and route scopes.
- `TelerouteMacroTests.swift` covers public macros.
- For public API access-control regressions, add non-`@testable` coverage in `PublicAPITests.swift`.
- Avoid real Telegram/network calls. Synthetic updates and fake clients are the expected test surface.
- Public async routing tests should use `try await bot.test { client in ... }` and the recording Telegram client from `TelerouteTestSupport`. Low-level invariant tests may use the test-SPI runtime and `Recorder.waitForCount` when they need direct executor accounting.
- For timing-sensitive middleware or queue tests, keep durations short but leave enough retry budget to reduce flakiness.
- Keep throughput checks in `TelerouteBenchmarks`; do not add machine-dependent timing assertions to unit tests.

## Documentation And Example Alignment

- README is the public behavior contract. Update it when changing route syntax, matching order, callbacks, typed routes, macros, flows, flow cancellation, command publishing, middleware/guard semantics, keyboard helpers, observability, context helpers, or setup requirements.
- `Sources/TelerouteExample` should remain a runnable demonstration of README claims.
- Do not document behavior that is not covered by source and tests.
