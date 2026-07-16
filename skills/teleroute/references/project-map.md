# Teleroute Project Map

## Targets And Commands

- Package: SwiftPM, Swift 6 language mode, Swift tools 6.3, macOS 15+.
- Library target: `Sources/Teleroute`.
- Optional macro declaration target: `Sources/TelerouteMacros`; compiler plugin: `Sources/TelerouteMacroPlugin`.
- Example executable: `Sources/TelerouteExample`.
- Benchmark executable: `Sources/TelerouteBenchmarks` (`swift run -c release TelerouteBenchmarks`).
- Tests: `Tests/TelerouteTests`, using Swift Testing.
- Common checks: `swift build`, `swift test`, `swift test --filter <test-name>`, `swift test --sanitize=thread`, `swift build -c release`.

## Source Areas

- `Core/Teleroute.swift`: lifecycle/configuration facade, `TGDefaultDispatcherPrtcl` integration, update processing order, event emission, error handling, metrics sink callbacks, and replay protection setup.
- `Core/TelerouteParsedUpdate.swift`: one-pass extraction of command, callback, message, identity, flow key, and route-kind metadata for one routing pass.
- `Core/TelerouteUpdateExecutor.swift`: bounded update execution, backpressure, cancellation, and synchronous shutdown state.
- `Routing/Teleroute+Routes.swift`: root command/callback registration and callback-data/button forwarding on `Teleroute`.
- `Routing/TelerouteRoutes.swift`: scoped/module registration contexts and the shared command/callback implementation.
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
- `Composition/TelerouteModule.swift`: the single reusable feature-module protocol and mounting API.
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
- Replay protection deduplicates repeated commands and callbacks for the same chat/user scope within the configured TTL.
- Route evaluation is registration ordered; the first route whose guard/middleware chain reaches its final handler wins.
- Every update uses one immutable route-graph snapshot; route registration incrementally updates command, callback, and flow indexes.
- Update processing is bounded by `Configuration.maximumConcurrentUpdates` and applies suspension-based backpressure when full.
- Consuming middleware that does not call `next` must conform to `TelerouteConsumingMiddleware`; otherwise fallback routes can still be considered unhandled.
- Flow sessions are scoped by `chatId + userId`. Active flow updates for one scope should be serialized.
- A Telegram command during an active flow first checks flow-local command routes. What happens next is controlled by `TelerouteFlowCancellationPolicy`; the default still cancels and then continues normal command routing.
- Observability side effects should stay coherent: received/skipped/handled/unmatched/failed events and metrics callbacks should describe the same routing outcome.

## Public API Surfaces

- Lifecycle and integration: `Teleroute`, its single `Configuration`-based initializer (including `maximumConcurrentUpdates`), idempotent `attach()`, `eventStream(buffering:)`, published-command helpers, and `shutdown()`.
- Registration: `Teleroute` exposes root raw/typed commands and callbacks, groups, modules, flows, typed callback-data rendering, buttons, and keyboards. `TelerouteRoutes` exposes the same operations for nested scopes but is not available through a public root property.
- Typed callback routes: typed registration returns `TelerouteCallbackRoute<Callback>`, whose buttons retain the registered scope and router identity.
- Typed specs: `TelerouteCommand` and `TelerouteCallback` decode values. Registrations may use explicit handlers, while `TelerouteHandlingCommand` and `TelerouteHandlingCallback` opt small routes into closure-free registration.
- Modules: `TelerouteModule.register(in:)` may return typed `Exports`; `mount(_:)` returns those exports to parent composition.
- Macros: the optional `TelerouteMacros` product provides `@TelerouteCommand` and `@TelerouteCallback`; runtime-only targets depend on `Teleroute` alone.
- Flows: `TelerouteFlow`, `TelerouteFlowGroup`, `TelerouteFlowContext`, `TelerouteFlowCancellationPolicy`, and flow storage abstractions cover flow starts, messages, commands, callbacks, transitions, values, cancellation, and finish behavior.
- Context helpers: `reply`, `send`, `edit`, `answerCallbackQuery`, media sends, message forwarding/deletion/editing, chat actions, parsed `command`, `parameters`, `message`, `callbackQuery`, `callbackData`, `chatId`, `userId`, `activeFlow`.
- Observability and recovery: `router.eventStream(buffering:)`, `Teleroute.Configuration.onError`, and `TelerouteMetricsSink`.
- Published commands: visibility helpers include `.default`, `.allPrivateChats`, `.allGroupChats`, `.allChatAdministrators`, `.chat`, `.chatAdministrators`, and `.chatMember`.

## Test Patterns

- Keep tests in `Tests/TelerouteTests` and prefer Swift Testing.
- Shared fixtures live in `TelerouteTestSupport`; reuse `makeBot`, `makeCommandUpdate`, `makeMessageUpdate`, `makeCallbackUpdate`, `TelerouteTestRecorder`, mock flow storage, fake `TGClientPrtcl` implementations, and command publishing recorders.
- `TelerouteStageBTests.swift` covers guards and built-in middleware.
- `TelerouteStageETests.swift` covers keyboard descriptions, pagination, metrics, and route scopes.
- `TelerouteMacroTests.swift` covers public macros.
- For public API access-control regressions, add non-`@testable` coverage in `PublicAPITests.swift`.
- Avoid real Telegram/network calls. Synthetic updates and fake clients are the expected test surface.
- Async routing tests typically call `await router.handle()`, then `await router.process([...])`, then wait through `Recorder.waitForCount`.
- For timing-sensitive middleware or queue tests, keep durations short but leave enough retry budget to reduce flakiness.
- Keep throughput checks in `TelerouteBenchmarks`; do not add machine-dependent timing assertions to unit tests.

## Documentation And Example Alignment

- README is the public behavior contract. Update it when changing route syntax, matching order, callbacks, typed routes, macros, flows, flow cancellation, command publishing, middleware/guard semantics, keyboard helpers, observability, context helpers, or setup requirements.
- `Sources/TelerouteExample` should remain a runnable demonstration of README claims.
- Do not document behavior that is not covered by source and tests.
