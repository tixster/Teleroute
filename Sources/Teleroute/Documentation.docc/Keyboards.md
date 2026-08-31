# Keyboards

Build inline and reply keyboards with result-builder DSLs and scope-validated typed buttons.

## Overview

Teleroute provides two keyboard DSLs: an inline-keyboard builder producing
`InlineKeyboardMarkup` (buttons under a message) and a reply-keyboard builder
producing `ReplyKeyboardMarkup` (buttons replacing the user's keyboard).

### Inline Keyboards

Render keyboards through the router (or group) so typed callback buttons are
validated against the scope that will handle them:

```swift
@TelerouteCallback("orders/{orderId}/page/{page}")
struct OrderPageCallback {
    let orderId: String
    let page: Int
}

let route = router.callback(OrderPageCallback.self) { callback, _ in
    .edit("Page \(callback.page)")
}

let markup = try router.keyboard {
    Row {
        route.button(OrderPageCallback(orderId: "7", page: 2), "Next ▶︎")
        TelerouteButton.url("Docs", "https://example.com")
    }
    TelerouteButton.switchInlineQuery("Share", query: "cats")   // its own row
}

router.command("orders") { _ in
    Reply("Your orders:").keyboard(markup)
}
```

A bare button expression becomes its own row; ``Row`` groups several buttons
horizontally. Conditionals and loops work inside the builders:

```swift
let markup = try router.keyboard {
    for order in orders {
        Row { route.button(OrderPageCallback(orderId: order.id, page: 0), order.title) }
    }
    if showHelp {
        TelerouteButton.url("Help", "https://example.com/help")
    }
}
```

### Button Factories

``TelerouteButton`` covers the non-callback button kinds:

```swift
TelerouteButton.url("Open site", "https://example.com")
TelerouteButton.webApp("Launch app", url: "https://example.com/app")
TelerouteButton.switchInlineQuery("Share", query: "cats")
TelerouteButton.switchInlineQuery("Search here", query: "cats", currentChat: true)
TelerouteButton.copyText("Copy code", copy: "PROMO-2024")
TelerouteButton.pay("Pay $5")             // first button of an invoice keyboard
TelerouteButton.raw(existingInlineKeyboardButton)
```

Typed callback buttons come from a route handle
(``TelerouteCallbackRoute/button(_:_:iconCustomEmojiId:style:)``) or directly
from the value (`callback.button("Label")`); the render step fails fast if the
callback's route is not registered in the rendering scope, so a button for an
unregistered route can never reach users.

### Pagination

``TeleroutePagination`` builds the standard previous/next row from a route
handle:

```swift
let navigation = TeleroutePagination.navigationRow(
    route,
    page: page,
    pageCount: pageCount
) { OrderPageCallback(orderId: orderId, page: $0) }

let markup = try router.keyboard {
    Row { navigation }
}
```

### Reply Keyboards

Reply keyboards use `KeyRow`/`KeyButton`; plain strings become simple buttons:

```swift
let replyKeyboard = ReplyKeyboardMarkup(resize: true) {
    KeyRow {
        KeyButton("Share contact").requestContact()
        KeyButton("Share location").requestLocation()
    }
    KeyRow {
        "Cancel"
    }
}

router.command("signup") { _ in
    Reply("How can we reach you?").keyboard(.keyboard(replyKeyboard))
}
```

The initializer also accepts `oneTime:`, `placeholder:`, and `selective:`.
The `ReplyMarkup` conveniences from the vocabulary cover the other cases —
`.inline(markup)`, `.keyboard(markup)`, `.remove()` (dismiss the reply
keyboard), and `.forceReply()`:

```swift
router.text("Cancel") { _ in
    Reply("Cancelled.").keyboard(.remove())
}
```

### Formatting Button-Adjacent Text

`TelegramText` (from the re-exported `TelegramBotKit` module) provides
`escapeHTML` / `escapeMarkdownV2` plus `bold`, `italic`, `code`, `pre`,
`link`, `mention`, and `spoiler` fragment builders — useful when the message
hosting the keyboard uses a parse mode:

```swift
Reply("Approve \(TelegramText.bold(order.title))?")
    .parseMode(.html)
    .keyboard(markup)
```

### Keyboards Inside Flows

``TelerouteFlowGroup`` exposes the same `render(_:)`/`keyboard(_:)` methods, so
flow steps can build buttons for their flow-local callback routes; see
<doc:Flows>.
