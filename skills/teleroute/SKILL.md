---
name: teleroute
description: >-
  Use when working in or against the Teleroute Swift package: route-style APIs
  for swift-telegram-bot, commands, callbacks, route groups, typed routes,
  collections, guards, middleware, rate limiting, command queueing, stateful
  flows, flow cancellation policy, lifecycle events, metrics sinks, replay
  protection, published command menus, keyboard builders, route-builder DSL,
  macros, context media helpers, README/example alignment, Swift Testing
  coverage, code review, and debugging Teleroute router behavior, concurrency
  assumptions, or public API compatibility.
---

# Teleroute

## Overview

Use this skill to modify, test, document, review, or consume the Teleroute library. Teleroute is a Swift 6.3 SwiftPM package that layers route-style command, callback, middleware, flow, command-menu, observability, and declarative route/keyboard APIs on top of `swift-telegram-bot`.

## First Steps

1. Work from the repository root and read `AGENTS.md` before editing.
2. Read the relevant source and tests before changing behavior. Use `references/project-map.md` for the API map, invariants, and test fixture locations.
3. Map the affected symbols with `rg` before editing when the change touches routing, flows, middleware, or published commands in more than one file.
4. Keep changes scoped to `Sources/Teleroute`, `Sources/TelerouteExample`, `Tests/TelerouteTests`, README/example docs, or this skill.
5. Preserve Swift 6 language mode and the package's Swift 6.3 requirement unless the user explicitly asks for a toolchain migration.
6. Do not add network-dependent tests. Use fake Telegram clients and synthetic `TGUpdate` values like the existing tests.

## Implementation Guidance

- Treat `Teleroute` and `TelerouteGroup` as the main public registration surfaces. Keep root and group APIs behaviorally aligned.
- Commands use Telegram-compatible `_`-joined names under groups, for example `group("admin").command("ban")` matches `/admin_ban`.
- Callback routes keep slash-separated paths and support `{parameter}` placeholders. Generated callback data must encode parameter values and match the same route definition.
- Active flow routes run before regular callbacks and commands. Regular callbacks run before regular commands.
- Flow cancellation behavior is configurable. Preserve the semantics of `TelerouteFlowCancellationPolicy` when unmatched commands arrive during an active flow.
- Middleware that intentionally consumes an update without calling `next` must conform to the internal `TelerouteConsumingMiddleware` marker so fallback routes do not run.
- Built-in middleware includes access logging, throttle/debounce, timeout, retry, and error-handling flows. Preserve cancellation and error propagation semantics when changing them.
- Built-in guards include chat-type, allowlist, argument-count, and admin checks. Remember that `TelerouteAdminGuard` performs a Telegram API lookup and should not be treated like a pure local predicate in docs or tests.
- Preserve queueing and flow isolation. Command queueing serializes by the selected strategy; active flow updates for the same `chatId + userId` must observe the latest session.
- Keep event emission, `onError`, and `TelerouteMetricsSink` callbacks behaviorally aligned. Observability changes usually touch `Core/Teleroute.swift`, `Routing/TelerouteEvents.swift`, and `Context/TelerouteMetricsSink.swift` together.
- Treat route-builder DSL, keyboard-builder helpers, pagination helpers, typed routes, and macros as first-class public APIs, not convenience internals.
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
```

Prefer focused `swift test --filter ...` while iterating. Run `swift test --sanitize=thread` for changes involving flow ordering, middleware execution, queues, replay protection, event emission, or shared mutable state.

For public API or consumer-facing behavior changes, finish with the smallest focused tests that prove the change and then run the broader relevant suite before handing work back.

Use targeted suites when they fit the change:

- `TelerouteStageBTests` for guards and built-in middleware behavior
- `TelerouteStageETests` for metrics, keyboard builders, pagination, and route-builder DSL
- `TelerouteMacroTests` for `@TelerouteCommand` / `@TelerouteCallback`
- `PublicAPITests` for non-`@testable` visibility regressions

## Common Tasks

- Adding a route API: update the root `Teleroute` API, the matching `TelerouteGroup` or typed-route extension, tests, README, and example code when applicable.
- Adding typed support: keep protocol defaults, root/group registration overloads, callback-data/button helpers, and self-handling variants consistent.
- Changing flow behavior: inspect `TelerouteFlow.swift`, `TelerouteFlowState.swift`, `TelerouteFlowStorage.swift`, and tests around flow session serialization and command cancellation.
- Changing flow cancellation behavior: inspect `TelerouteFlowCancellationPolicy.swift`, `Core/Teleroute.swift`, README flow docs, and tests covering unmatched commands during active flows.
- Changing middleware behavior: inspect `TelerouteMiddleware.swift`, `TelerouteMiddlewareRunner.swift`, rate-limit middleware, and fallback-route tests.
- Changing built-in middleware or guards: inspect `Composition/TelerouteBuiltInMiddleware.swift`, `Composition/TelerouteGuards.swift`, and `TelerouteStageBTests.swift`.
- Changing published commands: inspect `TeleroutePublishedCommands.swift` and tests that assert visibility grouping, duplicate detection, and fake-client publishing.
- Changing matching: inspect `TelerouteMatching.swift`, route signatures, command extraction, callback patterns, percent encoding, and duplicate diagnostics.
- Changing observability or failures: inspect `Routing/TelerouteEvents.swift`, `Context/TelerouteMetricsSink.swift`, `Context/TelerouteErrorHandler.swift`, and README sections for events, metrics, and error handling.
- Changing keyboards or pagination: inspect `Composition/TelerouteKeyboardBuilder.swift`, callback button/data helpers, and `TelerouteStageETests.swift`.
- Changing declarative registration or macros: inspect `Composition/TelerouteRouteBuilder.swift`, `Macros/TelerouteMacros.swift`, README DSL examples, and macro tests.
- Changing context helpers: inspect `Context/TelerouteContext.swift`, `Context/TelerouteContext+Media.swift`, related `TelerouteError` cases, and README helper examples.
- Reviewing a change: prioritize routing-order regressions, consuming-middleware correctness, flow cancellation semantics, queue serialization, replay protection scope, and README/example drift.

## Reference

Read `references/project-map.md` when you need a quick map of files, invariants, and test helper patterns.
