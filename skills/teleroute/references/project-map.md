# Teleroute Project Map

## Targets And Commands

- Package: SwiftPM, Swift 6 language mode, Swift tools 6.3, macOS 15+.
- Library target: `Sources/Teleroute`.
- Example executable: `Sources/TelerouteExample`.
- Tests: `Tests/TelerouteTests`, using Swift Testing.
- Common checks: `swift build`, `swift test`, `swift test --filter <test-name>`, `swift test --sanitize=thread`, `swift build -c release`.

## Source Areas

- `Core/Teleroute.swift`: root router facade, `TGDefaultDispatcherPrtcl` integration, update processing order, event emission, replay protection setup, root API forwarding.
- `Routing/TelerouteGroup.swift`: grouped command/callback registration and callback keyboard helpers.
- `Routing/TelerouteMatching.swift`: storage, route signatures, command extraction, callback pattern matching, callback data rendering, percent encoding.
- `Routing/TelerouteMiddlewareRunner.swift`: middleware chain execution and consuming middleware semantics.
- `Routing/TelerouteRateLimitMiddleware.swift`: throttle/debounce middleware and consuming fallback behavior.
- `Routing/TelerouteCommandQueue.swift`: command queue strategies and flow session queueing.
- `Routing/TeleroutePublishedCommands.swift`: Telegram command visibility scopes, command-set generation, publishing helpers.
- `Routing/TelerouteEvents.swift`: lifecycle event payloads and async event sequence.
- `Routing/TelerouteReplayProtection.swift`: replay claim storage and in-memory cleanup.
- `Typed/TelerouteCommand.swift`, `Typed/TelerouteCallback.swift`, `Typed/TelerouteTypedRoutes.swift`: typed command/callback protocols, registration overloads, callback generation helpers.
- `Flow/TelerouteFlow.swift`, `Flow/TelerouteFlowState.swift`, `Flow/TelerouteFlowStorage.swift`: multi-step flow APIs, flow context, storage, transitions, finish/cancel behavior.
- `Composition/TelerouteCollections.swift`: feature collection protocols and collection mounting APIs.
- `Composition/TelerouteMiddleware.swift`: `TelerouteGuard`, `TelerouteMiddleware`, internal consuming marker, guard composition.
- `Context/*`: handler context, command matches, route parameters, errors.

## Routing Invariants

- `Teleroute` processes active flow routes first, then regular callbacks, then regular commands.
- Grouped command names use `_` because Telegram commands do not support slash hierarchy.
- Callback routes keep slash hierarchy and use `{parameter}` placeholders.
- Callback data generation and matching should stay symmetric; parameter values are percent-encoded when rendered and decoded on match.
- Duplicate route diagnostics intentionally ignore guarded routes because same path plus different guards is supported.
- Replay protection deduplicates repeated commands and callbacks for the same chat/user scope within the configured TTL.
- Route evaluation is registration ordered; the first route whose guard/middleware chain reaches its final handler wins.
- Consuming middleware that does not call `next` must conform to `TelerouteConsumingMiddleware`; otherwise fallback routes can still be considered unhandled.
- Flow sessions are scoped by `chatId + userId`. Active flow updates for one scope should be serialized.
- A Telegram command during an active flow first checks flow-local command routes. If no flow command handles it, the active flow is cancelled and normal command routing continues.

## Public API Surfaces

- Root registration: `Teleroute.command`, `Teleroute.callback`, `Teleroute.group`, `Teleroute.add(flow:)`, collection APIs, typed route overloads, callback keyboard/data helpers, published command helpers.
- Group registration: `TelerouteGroup.command`, `TelerouteGroup.callback`, nested groups, collection APIs, typed route overloads, callback keyboard/data helpers.
- Typed specs: `TelerouteCommand` and `TelerouteCallback` support self-handling and handler-in-registration styles.
- Flows: `TelerouteFlow`, `TelerouteFlowGroup`, and `TelerouteFlowContext` handle flow starts, messages, commands, callbacks, transitions, values, cancellation, and finish.
- Context helpers: `reply`, `send`, `edit`, `answerCallbackQuery`, parsed `command`, `parameters`, `message`, `callbackQuery`, `callbackData`, `chatId`, `userId`, `activeFlow`.
- Published commands: visibility helpers include `.default`, `.allPrivateChats`, `.allGroupChats`, `.allChatAdministrators`, `.chat`, `.chatAdministrators`, and `.chatMember`.

## Test Patterns

- Keep tests in `Tests/TelerouteTests` and prefer Swift Testing.
- Use existing helpers in `TelerouteTests.swift`: `makeBot`, `makeCommandUpdate`, `makeMessageUpdate`, `makeCallbackUpdate`, `Recorder`, fake `TGClientPrtcl` implementations, and command publishing recorders.
- For public API access-control regressions, add non-`@testable` coverage in `PublicAPITests.swift`.
- Avoid real Telegram/network calls. Synthetic updates and fake clients are the expected test surface.
- Async routing tests typically call `await router.handle()`, then `await router.process([...])`, then wait through `Recorder.waitForCount`.
- For timing-sensitive middleware or queue tests, keep durations short but leave enough retry budget to reduce flakiness.

## Documentation And Example Alignment

- README is the public behavior contract. Update it when changing route syntax, matching order, callbacks, typed routes, flows, command publishing, middleware semantics, or setup requirements.
- `Sources/TelerouteExample` should remain a runnable demonstration of README claims.
- Do not document behavior that is not covered by source and tests.
