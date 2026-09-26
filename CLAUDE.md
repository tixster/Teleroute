# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

Teleroute is a Swift Package Manager library: a route-style Telegram Bot API
framework modeled after Hummingbird 2. Swift 6 language mode, tools 6.4,
macOS 15+ / Linux (CI builds on `swift:6.4` Docker).

`AGENTS.md` holds the same house rules in short form, and
`skills/teleroute/references/project-map.md` is an exhaustive file-by-file map
with the routing invariants — read it before non-trivial router work.

## Commands

```bash
swift build
swift test
swift test --filter <test-name>        # focused regression check
swift test --sanitize=thread           # the router is concurrent; use this for ordering/isolation changes
swift build -c release
swift run -c release TelerouteBenchmarks
TELEGRAM_BOT_TOKEN=<token> swift run TelerouteExample
```

Generated Bot API layers (see "Code generation"):

```bash
Scripts/generate-api.sh                # regenerate offline from the committed snapshot
Scripts/generate-api.sh --refresh      # re-download core.telegram.org/bots/api first, then regenerate
Scripts/verify-generated.sh            # idempotency + "is the committed tree in sync" check
swift test --package-path Tooling/BotAPIGen   # tests for the generator itself
```

## Target graph

Five layers, deliberately stacked so the generated code has no dependencies:

- `TelegramBotAPI` — **generated**. Every documented Bot API type under a flat
  top-level name (`Message`, `Update`, `ChatMember`, `ChatId`). Imports no
  module at all; that is what keeps the flat names collision-free.
- `TelegramBotKit` — hand-written client (transport, request building,
  JSON/multipart encoding, `{ok, result}` envelope decoding, rate limiting,
  flood-wait retry, send pacing, vocabulary) **plus generated** flat wrappers
  for all 185 operations and `UpdateKind`.
- `Teleroute` — the router: route graph, contexts, middleware/guards,
  keyboards, flows, typed commands/callbacks, and the `Service` lifecycle.
- `TelerouteMacros` / `TelerouteMacroPlugin` — optional `@TelerouteCommand`
  and `@TelerouteCallback` (SwiftSyntax).
- `TelerouteHummingbird` — webhook integration; `TelerouteTestSupport` — fake
  transports and synthetic update factories.

`TelegramBotAPI`, `TelegramBotKit`, and `TelerouteHummingbird` are compiled
**without** the package's upcoming-feature flags (`ExistentialAny`,
`NonisolatedNonsendingByDefault`, `InferIsolatedConformances`) — on purpose.
Don't "fix" that by unifying `swiftSettings` in `Package.swift`.

## Code generation

`Sources/TelegramBotAPI/Generated` and `Sources/TelegramBotKit/Generated` are
committed build output. **Never edit them by hand.** They are produced by
`Tooling/BotAPIGen`, a dev-only SwiftPM package outside the main dependency
graph, from the committed HTML snapshot in `botapi/` (`snapshot.json` pins the
Bot API version and the SHA-256 of `telegram-bot-api.html`).

Generation is offline and deterministic: only `--refresh` touches the network
and only `--refresh` may rewrite the snapshot. CI (`.github/workflows/linux-ci.yml`)
regenerates and runs `git diff --exit-code` over `botapi` and both `Generated`
directories, so a change to the generator must be committed together with its
regenerated output. Details in `botapi/README.md`.

## Dispatch pipeline

Per update, in order: discussion-forward tracking/observers → replay
protection → flows → callbacks → commands → message routes → update-kind
routes → `unmatched` hook.

Key files: `Core/TelerouteRuntime.swift` owns the pipeline (events, metrics,
error handling, replay protection); `Core/TelerouteParsedUpdate.swift` does a
single-pass extraction of everything a routing pass needs;
`Core/TelerouteUpdateExecutor.swift` bounds concurrency
(`maximumConcurrentUpdates`) with suspension-based backpressure;
`Routing/TelerouteMatching.swift` holds the compiled route graph.

Invariants that are easy to break (the project map has the full list):

- Every update runs against **one immutable route-graph snapshot**;
  registration incrementally updates the command/callback/flow indexes.
- Route evaluation is **registration ordered**; the first route whose
  guard/middleware chain reaches its final handler wins.
- Middleware is **snapshotted at registration time** — middleware added after a
  route is registered does not apply to it.
- Middleware that consumes an update without calling `next` must conform to
  `TelerouteConsumingMiddleware`, or fallback routes still see it as unhandled.
- Flow sessions are scoped by `chatId + userId` and serialized per scope.
- Grouped command names join with `_` (Telegram has no slash hierarchy);
  callback paths keep `/` and `{parameter}` placeholders. Rendering and
  matching must stay symmetric (values are percent-encoded on render).
- `allowed_updates` is derived from the registered routes — new route kinds
  need to be reflected there.
- Events (received/skipped/handled/unmatched/failed) and metrics callbacks must
  describe the same outcome as the actual routing result.

## Handlers and responses

Handlers return any `TelerouteResponseGenerator`: `String`, `Reply(...)`,
`TelerouteResponse`, an array (→ `.sequence`), `Void`, or `.unhandled` to fall
through to the next candidate route. When a test closure is side-effect-only
and overload resolution goes ambiguous, annotate it
`(_: TelerouteContext) -> Void in`.

## Testing

- Swift Testing only (`import Testing`, `@Test`, `#expect`, `#require`), in
  `Tests/TelerouteTests`.
- **No network-dependent tests.** Fake `TelegramTransport` and use synthetic
  `Update` values; `TelerouteTestSupport` ships two ready-made transports plus
  `makeTelerouteBot`, `makeCommandUpdate`, `makeCallbackUpdate`, and friends.
  Public routing tests go through `try await bot.test { client in … }`.
- Requests go out as JSON unless a call actually uploads bytes, in which case
  the *whole* request becomes `multipart/form-data`. Test doubles must not
  assume a fixed wire format per method.
- Access-control regressions need non-`@testable` coverage in
  `PublicAPITests.swift`.
- Throughput belongs in `TelerouteBenchmarks`; no machine-dependent timing
  assertions in unit tests.

## Documentation contract

`README.md` is the public behavior contract — update it whenever route syntax,
matching order, typed routes, macros, flows, middleware/guard semantics,
keyboards, observability, context helpers, or setup requirements change, and
keep `Sources/TelerouteExample` running as a demonstration of what it claims.
Each library target carries a `Documentation.docc` catalog (built and deployed
by `.github/workflows/docs.yml`). Do not document behavior that source and
tests don't cover.

## Git hygiene

Do not revert unrelated local changes. Do not edit anything under `.build`.
Keep documentation changes scoped to behavior that actually changed.
