# Typed Commands and Callbacks

Decode command arguments and callback data into structs — validated before your handler runs.

## Overview

String parsing in every handler gets old fast. Typed routes describe a
command's arguments or a callback's path parameters as a struct; Teleroute
decodes, validates, and hands your handler a ready value. The
`@TelerouteCommand` and `@TelerouteCallback` macros (from the separate
`TelerouteMacros` product) synthesize the conformances.

```swift
// Package.swift — add the macros product:
.product(name: "TelerouteMacros", package: "Teleroute")
```

### Typed Commands

```swift
import TelerouteMacros

@TelerouteCommand("transfer")
struct TransferCommand {
    let userId: Int64          // required, decoded & validated
    var amount: Double = 1.0   // optional with default
    let comment: String?       // optional
}

router.command(TransferCommand.self) { command, context in
    "Sending \(command.amount) to \(command.userId)"
}
```

`/transfer 42 2.5 lunch` decodes into
`TransferCommand(userId: 42, amount: 2.5, comment: "lunch")`. Arguments bind
to stored `let`/`var` properties in declaration order; supported types are
`String`, `Int`, `Int64`, `Double`, and `Bool`. Malformed input throws
``TelerouteError/invalidParameter(name:value:)`` **before** the handler runs,
so handlers never see half-decoded values.

Publishing metadata can live on the type itself:

```swift
@TelerouteCommand("transfer")
struct TransferCommand {
    static let commandDescription: String? = "Send money"
    static let visibility: [TelerouteCommandVisibility] = [.allPrivateChats]

    let userId: Int64
}
```

### Typed Callbacks

Callback types mirror path patterns; `{parameter}` segments bind to properties
of the same name and round-trip through non-`String` types:

```swift
@TelerouteCallback("orders/{orderId}/page/{page}")
struct OrderPageCallback {
    let orderId: String
    let page: Int
}

let route = router.callback(OrderPageCallback.self) { callback, _ in
    .edit("Page \(callback.page)")
}
```

Registration returns a ``TelerouteCallbackRoute`` handle — the type-safe way
to build buttons and callback data for that exact route:

```swift
let next = route.button(OrderPageCallback(orderId: "7", page: 2), "Next ▶︎")
let data = try route.callbackData(for: OrderPageCallback(orderId: "7", page: 2))
// data == "orders/7/page/2"
```

See <doc:Keyboards> for composing buttons into keyboards, including the
``TeleroutePagination`` helper built on top of route handles.

### Self-Handling Types

For small, self-contained features, the type can carry its own handler.
Conform to ``TelerouteHandlingCommand`` or ``TelerouteHandlingCallback``,
declare the context you expect, and register just the type:

```swift
@TelerouteCommand("version")
struct VersionCommand {}

extension VersionCommand: TelerouteHandlingCommand {
    func handle(context: TelerouteContext) async throws -> TelerouteResponse {
        .reply(Reply("MyBot 2.0"))
    }
}

router.command(VersionCommand.self)
```

Prefer explicit handlers registered from a ``TelerouteRouteCollection`` when
the logic owns injected dependencies or coordinates multiple routes.

### Without Macros

The macros only synthesize conformances — hand-written types work the same
way, which is also what the macro expands to:

```swift
struct BanCommand: TelerouteCommand {
    static let path = "ban"
    let userId: Int64
    let reason: String?

    init(command: TelerouteCommandMatch) throws {
        self.userId = try command.require("userId", as: Int64.self)
        self.reason = command.get("reason", at: 1)
    }
}
```

``TelerouteCommandMatch`` and ``TelerouteParameters`` provide `get`/`require`
accessors with `LosslessStringConvertible` decoding for manual parsing
anywhere else.

### Publishing Command Menus

Commands registered with a description are collected into per-scope menus:

```swift
router.command("start", description: "Begin") { _ in "hi" }
router.command("stats", description: "Admin stats",
               visibility: [.allChatAdministrators]) { _ in "..." }
```

Publish them on startup by setting
``TelerouteConfiguration/syncPublishedCommandsOnStart``, or on demand:

```swift
try await bot.syncPublishedCommands()

// Explicit values also work:
try await bot.publishCommands(
    [(command: "start", description: "Begin")],
    visibility: .allPrivateChats
)
```

``TelerouteCommandVisibility`` combines a ``TelerouteCommandScope`` (default,
all private chats, all groups, one chat, one chat's admins, one member) with
an optional ISO 639-1 language code for localized menus. Inspect what would be
published with ``TelerouteBot/publishedCommandSets()``.
