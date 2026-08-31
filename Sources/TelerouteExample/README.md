# TelerouteExample

The executable demonstrates the recommended `Teleroute`/`TelerouteBot`
architecture in a realistic feature layout. It deliberately includes both
compact convenience APIs and dependency-friendly controllers.

## Run

```bash
TELEGRAM_BOT_TOKEN=<token> swift run TelerouteExample
```

The routed bot uses long polling. `TelerouteBot.run()` keeps the process alive
and performs graceful shutdown when its task is cancelled.

## Startup Flow

```swift
let router = ExampleBootstrap.makeRouter()
let bot = try ExampleBootstrap.makeTelerouteBot(
    environment: environment,
    router: router
)

try await ExampleBootstrap.run(bot: bot, router: router)
```

`makeRouter()` has no bot parameter. It:

1. creates `Teleroute<ExampleRequestContext>`;
2. adds `ExampleRequestIDMiddleware` through `router.middlewares.add`;
3. adds `ExampleRouterConfiguration` as a route collection.

`makeTelerouteBot()` passes the bot token — `TelerouteBot` builds the Telegram
client itself — plus the logger, flow/replay configuration, update concurrency
limit, and automatic command-menu synchronization.

## Folder Layout

```text
TelerouteExample/
├── App/
│   ├── TelerouteExampleApp.swift
│   └── ExampleBootstrap.swift
├── Features/
│   ├── Root/
│   │   ├── ExampleRouterConfiguration.swift
│   │   └── ExampleStartScreen.swift
│   ├── Commands/
│   │   └── ExampleCommands.swift
│   ├── Callbacks/
│   │   └── ExampleCallbacks.swift
│   ├── Routes/
│   │   ├── BillingRoutes.swift
│   │   ├── DiagnosticsRoutes.swift
│   │   └── ModerationRoutes.swift
│   └── Flows/
│       └── SignupFlow.swift
└── Support/
    ├── ExampleRoutingSupport.swift
    ├── ExampleCommandMenus.swift
    ├── ExampleEnvironment.swift
    ├── ExampleError.swift
    └── ExampleLoggerFactory.swift
```

## Architecture

### Request Contexts

`ExampleRequestContext` wraps the framework context and carries a request ID.
`ExampleRequestIDMiddleware` transforms it before handlers run:

```swift
struct ExampleRequestContext: TelerouteInitializableRequestContext {
    let coreContext: TelerouteContext
    var requestID: String
}

router.middlewares.add(ExampleRequestIDMiddleware())
```

The `admin` group refines that context into `ExampleUserContext`, which
guarantees a non-optional Telegram user ID:

```swift
let admin = routes.group("admin", context: ExampleUserContext.self)
admin.middlewares.add(TelerouteAccessLogMiddleware(label: "admin"))
admin.guards.add(TelerouteAdminGuard())
```

The parent request-ID middleware runs before the child context is created.

### Route Collections

`ExampleRouterConfiguration` is the root `TelerouteRouteCollection`.
`BillingRoutes`, `DiagnosticsRoutes`, and `ModerationRoutes` are reusable feature
collections.

`BillingRoutes` exports typed callback handles:

```swift
let billing = routes.group("billing").addRoutes(BillingRoutes())

let button = billing.pay.button(
    PayInvoiceCallback(invoiceID: "42"),
    "Pay invoice #42"
)
```

The start-screen composer depends on these handles, not callback path strings or
controller implementation details.

### Responses and Side Effects

Most handlers return `TelerouteResponse`:

```swift
private func markInvoicePaid(
    _ callback: PayInvoiceCallback,
    _ context: ExampleRequestContext
) async throws -> TelerouteResponse {
    .sequence([
        .answerCallback("Invoice \(callback.invoiceID) paid"),
        .edit("Invoice \(callback.invoiceID) paid"),
    ])
}
```

Handlers that manipulate flow state or issue APIs outside the response model use
a side-effect `command` closure (returning `Void`) and call context methods directly.

### Typed Routes With and Without Macros

`ExampleCommands.swift` and `ExampleCallbacks.swift` contain manual protocol
conformances and macro-generated types. Both register through the same router
methods.

- `ProfileCommand`, `ApproveOrderCallback`, and `ArchiveTicketCallback` show
  self-handling routes.
- `SupportCallback` and `AdminBanCallback` are data-only values handled by the
  root controller.
- `PayInvoiceCallback` and `FailInvoiceCallback` use `@TelerouteCallback` from
  the optional `TelerouteMacros` product.

### Flows

`SignupFlow` demonstrates:

- `/signup` starting a session;
- message steps storing and merging values;
- callback and flow-local command routes;
- explicit transition, finish, restart, and cancellation;
- `.manual` flow cancellation policy.

## Route Inventory

Top-level commands:

- `/start`
- `/profile <name>`
- `/signup`
- `/sync_catalog`
- `/resume_signup`
- `/cancel_signup`
- `/refresh_menu`

Grouped commands:

- `/admin_ban <userID> [reason]`
- `/billing_invoice <invoiceID>`
- `/moderation_audit`
- `/diag_ping`

Callbacks include support topics, order approval, ticket archival, admin bans,
and invoice success/failure actions. All keyboard callback data is generated
from registered typed route handles.

## Manual Check

1. Run `/start` and inspect the generated keyboard.
2. Press support, order, ticket, and invoice buttons.
3. Run `/signup`, send a name, and confirm or cancel.
4. Run `/resume_signup` and `/cancel_signup` to exercise direct side effects.
5. In a group where the bot can inspect members, exercise `/admin_ban`.
6. Inspect logs for request IDs, inherited admin access logs, route names, and
   lifecycle events.
