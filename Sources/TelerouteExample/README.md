# TelerouteExample

`TelerouteExample` is a runnable reference application bundled with the package.
Its purpose is not to be a production bot, but to demonstrate every major Teleroute
capability in one executable target with enough structure to use as a starting point.

## Goals

- show string-based commands and callbacks
- show typed commands and typed callbacks
- show route groups
- show collections and group-owned collections
- show guards and middleware
- show queueing
- show published command sync
- show stateful multi-step flows
- show router-level debug logging and error diagnostics

## Run

```bash
TELEGRAM_BOT_TOKEN=123456:abc swift run TelerouteExample
```

The bot starts in long-polling mode and keeps the process alive after startup.

## Folder Layout

```text
Sources/TelerouteExample
├── App
│   ├── ExampleBootstrap.swift
│   └── TelerouteExampleApp.swift
├── Features
│   ├── Callbacks
│   │   └── ExampleCallbacks.swift
│   ├── Collections
│   │   ├── BillingCollection.swift
│   │   ├── DiagnosticsCollection.swift
│   │   └── ModerationCollection.swift
│   ├── Commands
│   │   └── ExampleCommands.swift
│   ├── Flows
│   │   └── SignupFlow.swift
│   └── Root
│       ├── ExampleRouterConfiguration.swift
│       └── ExampleStartScreen.swift
├── Support
│   ├── ExampleEnvironment.swift
│   ├── ExampleError.swift
│   ├── ExampleLoggerFactory.swift
│   └── ExampleRoutingSupport.swift
└── README.md
```

## Architecture

### App

- `TelerouteExampleApp.swift` is the executable entry point.
- `ExampleBootstrap.swift` owns process startup, command publishing, and bot lifetime.

### Support

- `ExampleEnvironment.swift` loads the bot token.
- `ExampleError.swift` defines startup errors.
- `ExampleLoggerFactory.swift` centralizes logger creation and log levels.
- `ExampleRoutingSupport.swift` holds generic route infrastructure shared across features.

### Features

- `Commands/ExampleCommands.swift` contains typed command specs.
- `Callbacks/ExampleCallbacks.swift` contains typed callback specs.
- `Collections/*` contains reusable route bundles that demonstrate both collection styles.
- `Flows/SignupFlow.swift` contains the multi-step flow example.
- `Root/*` composes the top-level router and the `/start` screen.

This structure is intentional:

- infrastructure concerns stay out of feature files
- route composition stays out of the executable entry point
- each Teleroute concept is isolated enough to be copied independently

## Capability Matrix

| Capability | Example file |
| --- | --- |
| Router startup | `App/ExampleBootstrap.swift` |
| String command | `Features/Root/ExampleRouterConfiguration.swift` |
| Typed command | `Features/Commands/ExampleCommands.swift` |
| String callback | `Features/Root/ExampleRouterConfiguration.swift` |
| Typed callback | `Features/Callbacks/ExampleCallbacks.swift` |
| Grouped routes | `Features/Root/ExampleRouterConfiguration.swift` |
| Collection | `Features/Collections/DiagnosticsCollection.swift` |
| Collection builder | `Features/Collections/BillingCollection.swift` |
| Group-owned collection | `Features/Collections/ModerationCollection.swift` |
| Guard | `Support/ExampleRoutingSupport.swift` |
| Middleware | `Support/ExampleRoutingSupport.swift` |
| Queueing | `Features/Commands/ExampleCommands.swift`, `Features/Flows/SignupFlow.swift` |
| Published commands | `App/ExampleBootstrap.swift` |
| Flow | `Features/Flows/SignupFlow.swift` |
| Debug logging | `Support/ExampleLoggerFactory.swift`, `Sources/Teleroute/Core/Teleroute.swift` |

## Route Inventory

### Top-level Commands

- `/start`: sends a menu containing examples of path-based and typed callbacks.
- `/resume_signup`: force-starts the signup flow at the first step.
- `/cancel_signup`: cancels any active flow session for the current chat/user.
- `/refresh_menu`: deletes stale chat-scoped commands and republishes the expected private-chat menu.
- `/profile <name>`: typed command argument parsing example.
- `/sync_catalog`: typed command with queueing example.

### Grouped Commands

- `/admin_ban <userID> [reason]`: typed command mounted inside `router.group("admin")`.
- `/billing_invoice <id>`: string command mounted by `BillingCollection`.
- `/moderation_audit`: command owned by `ModerationCollection`.
- `/diag_ping`: command mounted by `DiagnosticsCollection`.

### Top-level Callbacks

- `support/{topic}`: string callback with parameter decoding.
- `orders/{orderID}/approve`: typed callback handled by the router closure.
- `tickets/{ticketID}/archive`: typed callback handled by the callback type itself.

### Grouped Callbacks

- `admin/users/{userID}/ban`: callback generated from the `admin` group.
- `billing/invoice/{invoiceID}/pay`: collection-owned callback.
- `billing/invoice/{invoiceID}/fail`: collection-owned callback.

### Flow Routes

- `/signup`: starts the flow and stores a session.
- message at step `name`: captures the user name.
- callback `confirm/{decision}` at step `confirm`: confirms or restarts the flow.
- `/cancel` during step `confirm`: exits the flow.

## Manual Test Script

Run these in order against the example bot:

1. Send `/start`.
2. Tap `Billing FAQ`, `Approve order #42`, and `Archive ticket #42`.
3. Send `/refresh_menu` if the private-chat command menu looks stale or incomplete.
4. Send `/profile name`.
5. Send `/sync_catalog`.
6. Send `/billing_invoice 123`.
7. Send `/signup`, then send a name, then tap `Approve`.
8. Repeat `/signup`, then tap `Restart`.
9. Send `/signup`, then after entering a name send `/cancel_signup`.
10. In a suitable admin/group context, test `/admin_ban` and `/moderation_audit`.

## Logging

The example enables `debug` logging for both the bot and the router.

Router debug logs show:

- every received update
- when replay protection skips a duplicate update
- whether the update matched a flow, callback, command, or nothing
- structured metadata such as `chat_id`, `user_id`, `command`, and `callback_data`

Router error logs additionally include:

- `flow_id`
- `flow_step`
- `error_type`

This makes the example useful as a diagnostic harness when changing Teleroute itself.
