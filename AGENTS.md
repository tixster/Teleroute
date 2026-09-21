# AGENTS.md

## Project Overview

Teleroute is a Swift Package Manager project for a route-style Telegram bot
framework designed after Hummingbird 2. Both generated layers come from the
committed documentation snapshot in `botapi/` via `Tooling/BotAPIGen`, a
dev-only package outside the main graph (never edit generated code by hand;
regenerate with `Scripts/generate-api.sh`, verify with
`Scripts/verify-generated.sh`, see `botapi/README.md`):

- `Sources/TelegramBotAPI/Generated` — every documented Bot API type under a
  flat top-level name (`Message`, `ChatMember`, `ChatId`, …), one file per type
  in a folder named after its documentation section;
- `Sources/TelegramBotKit/Generated` — flat convenience wrappers for all 185
  operations plus `UpdateKind`.

`TelegramBotKit` also holds the hand-written client layer (request building and
encoding, response envelope decoding, vocabulary, rate limiting, flood-wait
retry, send pacing). `Teleroute` holds routing,
contexts, flows, and the Service lifecycle; `TelerouteHummingbird` holds the
webhook integration.

Main targets:

- `Teleroute`: library source in `Sources/Teleroute`
- `TelegramBotKit`/`TelegramBotAPI`: client layers (see above)
- `TelerouteHummingbird`: Hummingbird 2 webhook integration
- `TelerouteExample`: runnable example in `Sources/TelerouteExample`
- `TelerouteTests`: Swift Testing test target in `Tests/TelerouteTests`

The package uses Swift 6 language mode and currently requires Swift 6.4.

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
- Middleware that intentionally consumes an update returns a response (e.g. `.none`) without calling `next`; returning `.unhandled` falls through to the next candidate route.
- Do not add network-dependent tests. Existing tests fake `TelegramTransport` and use synthetic `Update` values; that seam is deliberate, and `TelerouteTestSupport` ships two ready-made transports.
- Requests go out as JSON unless a call actually uploads bytes, in which case the whole request becomes `multipart/form-data`. Test doubles must not assume a fixed wire format per method.
- Handlers return `TelerouteResponseGenerator` values; `.unhandled` falls through to the next candidate route. When a test closure is side-effect-only and overload resolution is ambiguous, annotate it `(_: TelerouteContext) -> Void in`.
- Keep examples in `Sources/TelerouteExample` aligned with README claims when changing public API behavior.

## Git Hygiene

- Do not revert unrelated local changes.
- Avoid editing generated SwiftPM build output under `.build`.
- Keep documentation changes scoped to behavior that actually changed.
