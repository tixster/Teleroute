# AGENTS.md

## Project Overview

Teleroute is a Swift Package Manager project for a route-style layer on top of
`swift-telegram-bot`.

Main targets:

- `Teleroute`: library source in `Sources/Teleroute`
- `TelerouteExample`: runnable example in `Sources/TelerouteExample`
- `TelerouteTests`: Swift Testing test target in `Tests/TelerouteTests`

The package uses Swift 6 language mode and currently requires Swift 6.3.

## Common Commands

Run these from the repository root:

```bash
swift build
swift test
swift test --sanitize=thread
swift build -c release
```

Use `swift test --filter <test-name>` for focused regression checks.

## Development Notes

- Prefer Swift Testing (`import Testing`, `@Test`, `#expect`, `#require`) for unit tests.
- Keep public API changes covered by at least one non-`@testable` test when access control matters.
- The router handles updates asynchronously; preserve ordering and isolation assumptions in flow, queueing, replay protection, and event code.
- Middleware that intentionally consumes an update without calling `next` should conform to the internal consuming middleware marker so fallback routes do not run.
- Do not add network-dependent tests. Existing tests use fake Telegram clients and synthetic `TGUpdate` values.
- Keep examples in `Sources/TelerouteExample` aligned with README claims when changing public API behavior.

## Git Hygiene

- Do not revert unrelated local changes.
- Avoid editing generated SwiftPM build output under `.build`.
- Keep documentation changes scoped to behavior that actually changed.
