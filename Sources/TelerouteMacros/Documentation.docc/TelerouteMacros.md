# ``TelerouteMacros``

Macros that synthesize typed command and callback conformances from a path.

## Overview

`TelerouteMacros` provides two attached macros that remove the boilerplate of
conforming to Teleroute's `TelerouteCommand` and `TelerouteCallback`
protocols. Add the product next to `Teleroute`:

```swift
.product(name: "TelerouteMacros", package: "Teleroute")
```

### @TelerouteCommand

Synthesizes `TelerouteCommand` conformance for a struct. Stored properties are
decoded from the command's whitespace-split arguments in declaration order —
by name and then by position:

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

Supported property types: `String`, `Int`, `Int64`, `Double`, and `Bool`.
A `var` with a default value decodes with that default when the argument is
absent; optionals decode to `nil`. Malformed input throws
`TelerouteError.invalidParameter` before the handler runs.

The macro generates `path`, `init(command:)`, and a memberwise initializer.

### @TelerouteCallback

Synthesizes `TelerouteCallback` conformance from a path pattern. `{param}`
segments are matched to stored `let` properties of the same name, and
non-`String` values round-trip through the callback data:

```swift
@TelerouteCallback("orders/{orderId}/page/{page}")
struct OrderPageCallback {
    let orderId: String
    let page: Int
}

let route = router.callback(OrderPageCallback.self) { callback, _ in
    .edit("Page \(callback.page)")
}

// Type-safe buttons and callback data from the route handle:
let button = route.button(OrderPageCallback(orderId: "7", page: 2), "Next ▶︎")
```

The macro generates `path`, `init(parameters:)`, the `parameters` encode
property, and a memberwise initializer.

### When Not to Use the Macros

The macros only write what you could write by hand — a manual conformance is
equally valid and sometimes clearer for commands with custom parsing rules.
The `Teleroute` module documentation's *Typed Commands and Callbacks* article
covers manual conformances, self-handling types, and command-menu publishing
in depth.

## Topics

### Macros

- ``TelerouteCommand(_:)``
- ``TelerouteCallback(_:)``
