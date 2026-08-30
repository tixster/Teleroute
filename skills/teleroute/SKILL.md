---
name: teleroute
description: >-
  Use when working in or against the Teleroute Swift package: route-style APIs
  for the Telegram Bot API, commands, callbacks, route scopes, typed routes,
  modules, guards, middleware, rate limiting, command queues, stateful
  flows, flow cancellation policy, lifecycle events, metrics sinks, replay
  protection, published command menus, callback keyboards, macros, context
  media helpers, README/example alignment, Swift Testing
  coverage, code review, and debugging Teleroute router behavior, concurrency
  assumptions, or public API compatibility.
---

# Teleroute

## Overview

Use this skill to modify, test, document, review, or consume the Teleroute library. Teleroute is a Swift 6.3 SwiftPM package that layers route-style command, callback, middleware, flow, command-menu, observability, and keyboard APIs on top of the `TelegramBotAPI` module — Telegram Bot API types and client generated from the OpenAPI spec in `openapi/` with swift-openapi-generator (regenerate with `Scripts/generate-api.sh`; never edit `Sources/TelegramBotAPI/Generated` by hand).

## First Steps

1. Work from the repository root and read `AGENTS.md` before editing.
2. Read the relevant source and tests before changing behavior. Use `references/project-map.md` for the API map, invariants, and test fixture locations.
3. Map the affected symbols with `rg` before editing when the change touches routing, flows, middleware, or published commands in more than one file.
4. Keep changes scoped to `Sources/Teleroute`, `Sources/TelerouteExample`, `Tests/TelerouteTests`, README/example docs, or this skill.
5. Preserve Swift 6 language mode and the package's Swift 6.3 requirement unless the user explicitly asks for a toolchain migration.
6. Do not add network-dependent tests. Use fake `ClientTransport` implementations and synthetic `Update` values like the existing tests.

## Implementation Guidance

- `Teleroute<Context>` is bot-independent and owns registration. `TelerouteBot` owns the bot, runtime configuration, lifecycle, events, command publishing, and update processing. Do not reintroduce a combined public facade.
- Configure routes before constructing `TelerouteBot`. `bot.run()` optionally synchronizes commands, starts the owned `getUpdates` long-polling loop, waits for cancellation, and shuts down. `bot.process(_:)` feeds updates directly for embedding, webhook servers, and in-process tests.
- Advanced dependencies and policies belong in `TelerouteBot.Configuration` / `TelerouteConfiguration`; avoid adding parallel bot initializers.
- `TelerouteRouterGroup<Context>` is the public nested scope. The low-level `TelerouteRoutes` and `TelerouteRuntime` types are test SPI, not consumer API.
- `command` and `callback` handlers return `TelerouteResponse`. Direct side-effect handlers use `onCommand` and `onCallback`; do not add same-name `Void` overloads because they make `.reply(...)` closure inference ambiguous.
- Add shared low-level or typed middleware with `router.middlewares.add(...)`; add shared guards with `router.guards.add(...)`. These collections are snapshotted at registration.
- Custom contexts conform to `TelerouteRequestContext`; source-constructible contexts use `TelerouteInitializableRequestContext`, and nested refinements use `TelerouteChildRequestContext`.
- `maximumConcurrentUpdates` bounds in-flight update handlers. Preserve suspension-based backpressure, cancellation-aware waiting, and synchronous shutdown accounting.
- Commands use Telegram-compatible `_`-joined names under groups, for example `group("admin").command("ban")` matches `/admin_ban`.
- Callback routes keep slash-separated paths and support `{parameter}` placeholders. Generated callback data must encode parameter values and match the same route definition.
- Active flow routes run before regular callbacks and commands. Regular callbacks run before regular commands.
- Keep one `TelerouteParsedUpdate` and one route-graph snapshot per routing pass. Command, callback, and flow indexes must preserve registration-order fallback semantics.
- Flow cancellation behavior is configurable. Preserve the semantics of `TelerouteFlowCancellationPolicy` when unmatched commands arrive during an active flow.
- Middleware that intentionally consumes an update without calling `next` must conform to the internal `TelerouteConsumingMiddleware` marker so fallback routes do not run.
- Middleware pipelines are compiled at registration. Preserve support for middleware that invokes `next` repeatedly (for example retry) without adding a per-match actor.
- Built-in middleware includes access logging, throttle/debounce, timeout, retry, and error-handling flows. Preserve cancellation and error propagation semantics when changing them.
- Built-in guards include chat-type, allowlist, argument-count, and admin checks. Remember that `TelerouteAdminGuard` performs a Telegram API lookup and should not be treated like a pure local predicate in docs or tests.
- Preserve command-queue and flow isolation. `TelerouteQueueScope` serializes by `.global`, `.perChat`, or `.perChatAndUser`; active flow updates for the same `chatId + userId` must observe the latest session.
- Keep event emission, `onError`, and `TelerouteMetricsSink` callbacks behaviorally aligned. Observability changes usually touch `Core/TelerouteRuntime.swift`, `Core/TelerouteBot.swift`, `Routing/TelerouteEvents.swift`, and `Context/TelerouteMetricsSink.swift` together.
- Treat `TelerouteButton`, `TelerouteCallbackRoute`, pagination helpers, typed routes, and macros as first-class public APIs. Typed callback registration returns a scope-bound route handle; prefer `route.button(callback, ...)`, while `callback.button(...)` is validated against the rendering scope. Route scopes render descriptions with `render(_:)` or `keyboard(_:)`. Keep pagination route-bound and typed, keep `callbackData(for:)` as the encoded-string escape hatch, and do not reintroduce public path/parameter button factories, a result-builder DSL, or batch button overloads.
- `TelerouteCommand` and `TelerouteCallback` decode data only. Keep explicit handlers as the dependency-friendly default; `TelerouteHandlingCommand` and `TelerouteHandlingCallback` are opt-in conveniences for small self-contained routes and must never become requirements of the base protocols.
- `TelerouteRouteCollection` may return a typed `Exports` value, and `addRoutes(_:)` forwards it. Use exports for selected cross-feature route handles instead of duplicating callback paths.
- Callback macro placeholders must map one-to-one to required stored `String` properties so `parameters` remains nonthrowing and every value is renderable.
- Macro declarations live in the optional `TelerouteMacros` product and implementations in `TelerouteMacroPlugin`; runtime-only consumers must not need the compiler plugin target.
- `TelerouteContext` includes media/message/chat-action helpers in addition to basic text replies. Preserve fallback target resolution for `chatId` and `messageId`.
- Public API changes should have at least one non-`@testable` test when access control or consumer visibility matters.
- Review changes against registration-order behavior: active flow routes first, then regular callbacks, then regular commands, with first-match wins once guards and middleware reach the final handler.
- Keep README and `Sources/TelerouteExample` aligned when public behavior, examples, or recommended usage changes.

## Testing

Use Swift Testing (`import Testing`, `@Test`, `#expect`, `#require`) for unit tests.

Useful checks from the repository root:

```bash
swift build
swift test
swift test --filter <test-name>
swift test --sanitize=thread
swift build -c release
swift run -c release TelerouteBenchmarks
```

Prefer focused `swift test --filter ...` while iterating. Run `swift test --sanitize=thread` for changes involving flow ordering, middleware execution, queues, replay protection, event emission, or shared mutable state.

For public API or consumer-facing behavior changes, finish with the smallest focused tests that prove the change and then run the broader relevant suite before handing work back.

Use targeted suites when they fit the change:

- `TelerouteStageBTests` for guards and built-in middleware behavior
- `TelerouteStageETests` for metrics, route scopes, keyboard descriptions, and pagination
- `TelerouteMacroTests` for `@TelerouteCommand` / `@TelerouteCallback`
- `PublicAPITests` for non-`@testable` visibility regressions

## Common Tasks

- Adding a route API: implement it on `TelerouteRouterGroup`, keep root behavior inherited by `Teleroute`, and update typed/flow adapters, tests, README, and example code when applicable. Touch the low-level SPI scope only when runtime registration requires it.
- Adding typed support: keep explicit and self-handling overloads, route-scope callback generation, macros, and public API tests consistent.
- Changing flow behavior: inspect `TelerouteFlow.swift`, `TelerouteFlowCoordinator.swift`, `TelerouteFlowState.swift`, `TelerouteFlowStorage.swift`, and tests around flow session serialization and command cancellation.
- Changing flow cancellation behavior: inspect `TelerouteFlowCancellationPolicy.swift`, `Core/TelerouteRuntime.swift`, README flow docs, and tests covering unmatched commands during active flows.
- Changing middleware behavior: inspect `TelerouteMiddleware.swift`, `TelerouteMiddlewareRunner.swift`, rate-limit middleware, and fallback-route tests.
- Changing built-in middleware or guards: inspect `Composition/TelerouteBuiltInMiddleware.swift`, `Composition/TelerouteGuards.swift`, and `TelerouteStageBTests.swift`.
- Changing published commands: inspect `TeleroutePublishedCommands.swift` and tests that assert visibility grouping, duplicate detection, and fake-client publishing.
- Changing matching: inspect `TelerouteParsedUpdate.swift`, `TelerouteMatching.swift`, compiled indexes, route signatures, command extraction, callback patterns, percent encoding, and duplicate diagnostics; compare the release benchmark for hot-path changes.
- Changing observability or failures: inspect `Routing/TelerouteEvents.swift`, `Context/TelerouteMetricsSink.swift`, `Context/TelerouteErrorHandler.swift`, and README sections for events, metrics, and error handling.
- Changing keyboards or pagination: inspect `Composition/TelerouteKeyboard.swift`, route-scope callback button/data helpers, and `TelerouteStageETests.swift`.
- Changing route collections: inspect `Composition/TelerouteRouteCollection.swift`, example route collections, and public composition tests.
- Changing macros: inspect the `TelerouteMacros` declaration target, `TelerouteMacroPlugin` implementation target, README imports/dependencies, and macro tests.
- Changing update concurrency: inspect `TelerouteUpdateExecutor.swift`, `Configuration.maximumConcurrentUpdates`, shutdown tests, backpressure tests, TSan, and the release benchmark.
- Changing context helpers: inspect `Context/TelerouteContext.swift`, `Context/TelerouteContext+Media.swift`, related `TelerouteError` cases, and README helper examples.
- Reviewing a change: prioritize routing-order regressions, consuming-middleware correctness, flow cancellation semantics, queue serialization, replay protection scope, and README/example drift.

## Reference

Read `references/project-map.md` when you need a quick map of files, invariants, and test helper patterns.
