# Observability

Watch routing lifecycle events, export metrics, and centralize error reporting.

## Overview

Three complementary channels expose what the router is doing:

- **Events** — an `AsyncSequence` of per-update lifecycle events;
- **Metrics** — a pluggable sink, with a ready-made swift-metrics adapter;
- **Logging** — the swift-log `Logger` you pass to ``TelerouteBot``.

### Event Streams

``TelerouteBot/eventStream(buffering:)`` returns an independent
``TelerouteEventSequence``; every subscriber receives the same events through
its own iterator and buffer:

```swift
Task {
    for await event in bot.eventStream() {
        switch event.kind {
        case .handled:
            print("✅ \(event.routeName ?? "?") in \(event.duration ?? .zero)")
        case .failed:
            print("❌ \(event.routeName ?? "?"): \(event.errorDescription ?? "?")")
        case .unmatched:
            print("🤷 update \(event.updateId) matched nothing")
        case .received, .skippedDuplicate:
            break
        }
    }
}
```

Each ``TelerouteEvent`` carries the phase (`received`, `skippedDuplicate`,
`handled`, `unmatched`, `failed`), the best-effort route category
(``TelerouteEvent/RouteKind``), the matched route name, update/chat/user
identifiers, timing, and — for failures — the error.

Buffering per subscriber is controlled by ``TelerouteEventBufferingPolicy``
(default `.newest(512)`); use `.unbounded` in tests where losing events would
hide bugs.

### Metrics

Set a ``TelerouteMetricsSink`` on the configuration. The bundled
``TelerouteSwiftMetricsSink`` forwards to swift-metrics:

```swift
let configuration = TelerouteConfiguration(
    metricsSink: TelerouteSwiftMetricsSink()   // prefix: "teleroute"
)
```

Emitted instruments:

| Instrument | Type | Dimensions |
| --- | --- | --- |
| `teleroute.updates.received` | counter | `route_kind` |
| `teleroute.updates.handled` | counter | `route_kind`, `route` |
| `teleroute.updates.unmatched` | counter | `route_kind` |
| `teleroute.updates.failed` | counter | `route_kind`, `route` |
| `teleroute.updates.duplicate` | counter | `route_kind` |
| `teleroute.handler.duration` | timer | `route_kind`, `route` |

Custom backends implement the protocol directly — every method has a no-op
default, so a sink overrides only what it cares about:

```swift
struct FailureAlertSink: TelerouteMetricsSink {
    func recordFailed(
        routeKind: TelerouteEvent.RouteKind,
        routeName: String?,
        chatId: Int64?,
        userId: Int64?,
        duration: Duration,
        error: any Error
    ) async {
        await pager.alert("route \(routeName ?? "?") failed: \(error)")
    }
}
```

### Error Reporting

``TelerouteConfiguration/onError`` receives every unhandled route error, and
``TelerouteConfiguration/errorRenderer`` converts errors into a user-visible
response before the failure is reported:

```swift
let configuration = TelerouteConfiguration(
    onError: { error, context in
        logger.error("route failed", metadata: [
            "chat": "\(context.chatId ?? 0)",
            "error": "\(error)",
        ])
    },
    errorRenderer: { error, _ in
        error is TelerouteTimeoutError
            ? .reply(Reply("Took too long — try again."))
            : .reply(Reply("Something went wrong 😔"))
    }
)
```

Scoped error handling (converting or swallowing errors for one group only) is
available through ``TelerouteErrorHandlingMiddleware``; see
<doc:MiddlewareAndGuards>.

### Logging

The `Logger` passed to ``TelerouteBot`` is used by the polling connection and
runtime, and is also the basis for the per-update
``TelerouteRequestContext/logger`` every handler receives. That one arrives
pre-populated with the update's metadata — `update_id`, `chat_id`, `user_id`,
`route_kind`, plus the matched command or callback data, and `flow_id` /
`flow_step` inside a flow step:

```swift
router.command("checkout") { context in
    context.logger.info("starting checkout")
    try await process(context)
}
```

Because the metadata is already attached, handler logs correlate with the
runtime's own without threading identifiers through your call stack. Use
``TelerouteContext/logging(metadata:)`` to add more for a subtree of work.

Add per-route request logging with ``TelerouteAccessLogMiddleware``:

```swift
router.middlewares.add(core: TelerouteAccessLogMiddleware(label: "bot.access"))
```

### Flow Outcomes

``TelerouteMetricsSink/recordFlowEnded(flowID:step:outcome:age:chatId:userId:)``
reports every session that ends, tagged with a ``TelerouteFlowOutcome``:

| Outcome | Meaning |
|---|---|
| `finished` | a step called `finish()` |
| `cancelled` | `cancelFlow()`/`cancel()`, or an unmatched command cancelled it |
| `expired` | the session passed its TTL without activity |

`age` is measured from the session's `createdAt`, so it reports how long the
conversation actually lasted. Together these answer the question a wizard
always raises: do users complete it, abandon it, or simply stop replying?
``TelerouteSwiftMetricsSink`` exports them as `teleroute.flows.ended`
(dimensioned by `flow` and `outcome`) and the `teleroute.flow.age` timer.
