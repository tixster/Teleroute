# TelerouteExample

`TelerouteExample` is a runnable reference application bundled with the package.
Its purpose is not to be a production bot, but to demonstrate every major Teleroute
capability in one executable target with enough structure to use as a starting point.

## Goals

- show string commands and typed callbacks
- show explicit and self-handling typed routes
- show route groups
- show controller-style modules with handler methods
- show scope-bound callback route handles and validated keyboards
- show guards and middleware
- show command queues
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
│   ├── Modules
│   │   ├── BillingModule.swift
│   │   ├── DiagnosticsModule.swift
│   │   └── ModerationModule.swift
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

- `Commands/ExampleCommands.swift` contains self-handling typed commands.
- `Callbacks/ExampleCallbacks.swift` contains self-handling and controller-handled typed callbacks.
- `Modules/*` contains controller-style features using `TelerouteModule`; app
  composition owns their route prefixes.
- `Flows/SignupFlow.swift` contains the multi-step flow example.
- `Root/ExampleRouterConfiguration.swift` is the root module/controller and owns
  scopes, route registration, and ordinary handlers with dependencies.
- `Root/ExampleStartScreen.swift` receives registered callback route handles and
  builds the `/start` response without knowing callback paths or handlers.

This structure is intentional:

- infrastructure concerns stay out of feature files
- route composition stays out of the executable entry point
- handlers with dependencies can stay on their module/controller structure
- small stateless typed routes can own behavior and register without closures
- callback registration and button construction stay connected by
  `TelerouteCallbackRoute<Callback>`
- each Teleroute concept is isolated enough to be copied independently

The `/start` feature shows the full composition path:

1. `ExampleRouterConfiguration` creates root and `admin` scopes.
2. Typed callback registration returns route handles for those exact scopes.
3. The handles are grouped in `ExampleStartScreen.CallbackRoutes`.
4. `ExampleStartScreen` builds one keyboard containing both root and admin
   callbacks; no path strings or manual nested-scope rendering are needed.

`BillingModule` shows the same pattern inside a reusable feature: root
composition mounts it into `billing`, the module registers callbacks before its
command, and the command captures those handles for keyboard construction.

## Capability Matrix

| Capability | Example file |
| --- | --- |
| Router startup | `App/ExampleBootstrap.swift` |
| String command | `Features/Root/ExampleRouterConfiguration.swift` |
| Self-handling typed command | `Features/Commands/ExampleCommands.swift` |
| Controller-handled typed callback | `Features/Root/ExampleRouterConfiguration.swift` |
| Self-handling typed callback | `Features/Callbacks/ExampleCallbacks.swift` |
| Scope-bound callback buttons | `Features/Root/ExampleStartScreen.swift` |
| Grouped routes | `Features/Root/ExampleRouterConfiguration.swift` |
| Reusable modules | `Features/Modules/*Module.swift` |
| Guard | `Support/ExampleRoutingSupport.swift` |
| Middleware | `Support/ExampleRoutingSupport.swift` |
| Command queues | `Features/Commands/ExampleCommands.swift`, `Features/Flows/SignupFlow.swift` |
| Published commands | `App/ExampleBootstrap.swift` |
| Flow | `Features/Flows/SignupFlow.swift` |
| Debug logging | `Support/ExampleLoggerFactory.swift`, `Sources/Teleroute/Core/Teleroute.swift` |

## Route Inventory

### Top-level Commands

- `/start`: sends a validated menu built entirely from registered typed callback handles.
- `/resume_signup`: force-starts the signup flow at the first step.
- `/cancel_signup`: cancels any active flow session for the current chat/user.
- `/refresh_menu`: deletes stale chat-scoped commands and republishes the expected private-chat menu.
- `/profile <name>`: typed command argument parsing example.
- `/sync_catalog`: typed command with a per-chat-and-user queue.

### Grouped Commands

- `/admin_ban <userID> [reason]`: typed command mounted inside `router.group("admin")`.
- `/billing_invoice <id>`: string command mounted by `BillingModule`.
- `/moderation_audit`: command owned by `ModerationModule`.
- `/diag_ping`: command mounted by `DiagnosticsModule`.

### Top-level Callbacks

- `support/{topic}`: typed callback decoded for a controller handler.
- `orders/{orderID}/approve`: self-handling typed callback.
- `tickets/{ticketID}/archive`: self-handling typed callback.

### Grouped Callbacks

- `admin/users/{userID}/ban`: typed callback rendered in the `admin` group.
- `billing/invoice/{invoiceID}/pay`: module-owned typed callback.
- `billing/invoice/{invoiceID}/fail`: module-owned typed callback.

### Flow Routes

- `/signup`: starts the flow and stores a session.
- message at step `name`: captures the user name.
- typed callback `confirm/{decision}` at step `confirm`: confirms or restarts the flow.
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
