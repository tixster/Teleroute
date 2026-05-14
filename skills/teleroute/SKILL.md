---
name: teleroute
description: >-
  Use when working in or against the Teleroute Swift package: route-style APIs
  for swift-telegram-bot, commands, callbacks, route groups, typed routes,
  collections, guards, middleware, rate limiting, command queueing, stateful
  flows, lifecycle events, replay protection, published command menus,
  README/example alignment, Swift Testing coverage, and debugging Teleroute
  router behavior or public API compatibility.
---

# Teleroute

## Overview

Use this skill to modify, test, document, or consume the Teleroute library. Teleroute is a Swift 6.3 SwiftPM package that layers route-style command, callback, middleware, flow, and command-menu APIs on top of `swift-telegram-bot`.

## First Steps

1. Work from the repository root and read `AGENTS.md` before editing.
2. Read the relevant source and tests before changing behavior. Use `references/project-map.md` for the API map, invariants, and test fixture locations.
3. Keep changes scoped to `Sources/Teleroute`, `Sources/TelerouteExample`, `Tests/TelerouteTests`, README/example docs, or this skill.
4. Preserve Swift 6 language mode and the package's Swift 6.3 requirement unless the user explicitly asks for a toolchain migration.
5. Do not add network-dependent tests. Use fake Telegram clients and synthetic `TGUpdate` values like the existing tests.

## Implementation Guidance

- Treat `Teleroute` and `TelerouteGroup` as the main public registration surfaces. Keep root and group APIs behaviorally aligned.
- Commands use Telegram-compatible `_`-joined names under groups, for example `group("admin").command("ban")` matches `/admin_ban`.
- Callback routes keep slash-separated paths and support `{parameter}` placeholders. Generated callback data must encode parameter values and match the same route definition.
- Active flow routes run before regular callbacks and commands. Regular callbacks run before regular commands.
- Middleware that intentionally consumes an update without calling `next` must conform to the internal `TelerouteConsumingMiddleware` marker so fallback routes do not run.
- Preserve queueing and flow isolation. Command queueing serializes by the selected strategy; active flow updates for the same `chatId + userId` must observe the latest session.
- Public API changes should have at least one non-`@testable` test when access control or consumer visibility matters.
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

## Common Tasks

- Adding a route API: update the root `Teleroute` API, the matching `TelerouteGroup` or typed-route extension, tests, README, and example code when applicable.
- Adding typed support: keep protocol defaults, root/group registration overloads, callback-data/button helpers, and self-handling variants consistent.
- Changing flow behavior: inspect `TelerouteFlow.swift`, `TelerouteFlowState.swift`, `TelerouteFlowStorage.swift`, and tests around flow session serialization and command cancellation.
- Changing middleware behavior: inspect `TelerouteMiddleware.swift`, `TelerouteMiddlewareRunner.swift`, rate-limit middleware, and fallback-route tests.
- Changing published commands: inspect `TeleroutePublishedCommands.swift` and tests that assert visibility grouping, duplicate detection, and fake-client publishing.
- Changing matching: inspect `TelerouteMatching.swift`, route signatures, command extraction, callback patterns, percent encoding, and duplicate diagnostics.

## Reference

Read `references/project-map.md` when you need a quick map of files, invariants, and test helper patterns.
