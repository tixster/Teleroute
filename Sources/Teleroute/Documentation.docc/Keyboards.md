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

router.command("orders") { _ in
    Reply("Your orders:").keyboard {
        Row {
            route.button(OrderPageCallback(orderId: "7", page: 2), "Next ▶︎")
            TelerouteButton.url("Docs", "https://example.com")
        }
        TelerouteButton.switchInlineQuery("Share", query: "cats")   // its own row
    }
}
```

``Reply``, ``Send``, and ``Edit`` all take the builder directly. The buttons
are rendered when the response executes, against the router serving the
update — so the markup lives in the handler that needs it, and a button for an
unregistered route surfaces through the usual error path
(``TelerouteConfiguration/errorRenderer``).

When a handler sends its own messages instead of returning a response,
`context.keyboard { … }` returns the markup:

```swift
router.command("orders") { context in
    try await context.reply(
        "Your orders:",
        replyMarkup: .inline(context.keyboard {
            Row { route.button(OrderPageCallback(orderId: "7", page: 2), "Next ▶︎") }
        })
    )
}
```

`router.keyboard { … }` still builds a markup ahead of time when the same
keyboard is reused across handlers.

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
TelerouteButton.disabled("· 3 / 10 ·")    // inert label inside a keyboard
TelerouteButton.callbackGame("Play")      // first button of the first row
TelerouteButton.switchInlineQuery("Pick a group", chosenChat: .init(query: ""))
TelerouteButton.raw(existingInlineKeyboardButton)
```

The same kinds are reachable through initializers, which is usually how a
keyboard reads best:

```swift
Row {
    TelerouteButton("Next ▶︎") { OrderPageCallback(orderId: "7", page: 2) }
    TelerouteButton("Delete") { DeleteOrder(id: "7") }.style(.danger)
    TelerouteButton("Docs", url: "https://example.com")
    TelerouteButton("3 / 10", .disabled)
}
```

`style(_:)` and `icon(_:)` chain onto any button, including the static
factories.

Typed callback buttons come from a route handle
(``TelerouteCallbackRoute/button(_:_:iconCustomEmojiId:style:)``), from the
value (`callback.button("Label")`), or from the initializer above. A button
for a route that is not registered at all fails fast, so it can never reach
users.

### Callbacks Registered in Groups

A route handle carries its full path, so it renders correctly from anywhere.
A bare callback value carries only its own type's path — the group prefix is
not part of it — so rendering resolves it by searching every registered
callback route for one ending in that path:

```swift
let admin = router.group("admin")
admin.callback(DeleteOrder.self) { callback, context in … }   // admin/orders/{id}/delete

router.command("orders") { _ in
    Reply("Order 7").keyboard {
        // Resolves to admin/orders/7/delete, even though this scope is the root.
        Row { TelerouteButton("Delete") { DeleteOrder(id: "7") } }
    }
}
```

The scope that registered the route always wins, so a group rendering its own
callbacks is unaffected. If the same callback type is registered on more than
one route, the one to link cannot be inferred and rendering throws
``TelerouteError/ambiguousCallbackRoute(_:matches:)`` — use a route handle
there.

### Callback Data Limits

Telegram accepts at most 64 **bytes** of `callback_data`. Teleroute checks the
rendered value and throws ``TelerouteError/callbackDataTooLong(_:bytes:)``
instead of letting the API reject the message with a 400. Watch for non-ASCII
parameters: percent encoding turns one Cyrillic character into six bytes, so a
value well under 64 characters can still be over the limit.

### Laying Out Rows

`grid(columns:)` slices a flat list of buttons into rows, which is how
list-style menus are usually built:

```swift
let markup = try context.keyboard {
    orders.map { route.button(OpenOrder(id: $0.id), $0.title) }.grid(columns: 2)
    Row { TelerouteButton.url("Help", "https://example.com/help") }
}
```

### Pagination

``TeleroutePagination`` builds paging controls from a route handle. The plain
previous/next row:

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

`counter: true` adds an inert `3 / 10` label between the arrows and keeps the
row three buttons wide on the first and last page, so the controls do not
shift as the user pages through:

```swift
Row {
    TeleroutePagination.navigationRow(
        route,
        page: page,
        pageCount: pageCount,
        counter: true
    ) { OrderPageCallback(orderId: orderId, page: $0) }
}
```

``TeleroutePagination/pageStrip(_:page:pageCount:window:ellipsis:callback:)``
renders numbered pages windowed around the current one
(`1 · … · 4 · [5] · 6 · … · 20`), with the current page as a disabled marker.

### Confirmation

``TelerouteConfirm`` builds a styled yes/no row from one route, or from two:

```swift
Row {
    TelerouteConfirm.row(
        route,
        confirm: DeleteOrder(id: "7", confirmed: true),
        cancel: DeleteOrder(id: "7", confirmed: false)
    )
}
```

### Handlers Written in the Button

A button can carry its handler directly, with no callback type and no route
registration. Enable it first — it is off by default, because enabling it
mounts a callback route and therefore asks Telegram for `callback_query`
updates:

```swift
let bot = try TelerouteBot(
    token: token,
    router: router,
    configuration: .init(inlineActions: .enabled())
)
```

```swift
router.command("orders") { _ in
    Reply("Order 7").keyboard {
        Row {
            TelerouteButton("Approve") { press in
                try await orders.approve(7)
                return .edit("Order 7 approved")
            }
            TelerouteButton("Cancel") { .edit("Cancelled") }
        }
    }
}
```

The press is dispatched through an ordinary callback route, so middleware,
guards, callback auto-answering, metrics, and the error pipeline all apply.

By default only the user the keyboard was rendered for may press the button —
in a group chat any member can tap it otherwise. Pass `scope:` to widen that:

```swift
TelerouteButton("👍", scope: .chat) { press in … }     // any member of this chat
TelerouteButton("Open", scope: .anyone) { press in … }
```

#### Clearing the Button Afterwards

`onSuccess:` takes the button away once its handler returns without throwing,
which covers the usual "claim this" and "confirm / cancel" shapes:

```swift
Row {
    // Only this button goes; the rest of the keyboard stays.
    TelerouteButton("Claim", onSuccess: .removeButton) { press in
        try await orders.claim(7, by: press.userId)
        return .answerCallback("Claimed")
    }
    TelerouteButton("Details", url: detailsURL)
}

Row {
    // The whole dialog closes.
    TelerouteButton("Confirm", onSuccess: .removeKeyboard) { _ in
        .answerCallback("Done")
    }
}
```

`.removeButton` drops a row left empty, and removes the keyboard entirely once
no buttons remain. The default is `.keep`.

Two things it deliberately does not do:

- **A handler that throws keeps its button.** Only a clean return counts as
  success, so a failed press can be retried.
- **A handler that edits the message keeps control.** `editMessageText` always
  decides the markup — omitting `reply_markup` clears it — so returning
  ``Edit`` means the handler has already said what the keyboard should be, and
  `onSuccess` stands aside rather than rewriting it.

If removal itself fails, it is logged as a warning and the update still counts
as handled: the user's action already went through, and reporting a failure
for the tidy-up would be the wrong outcome.

The same thing by hand, from any callback handler including typed ones:

```swift
router.callback(ClaimOrder.self) { callback, context in
    try await orders.claim(callback.id)
    try await context.removePressedButton()
    return .answerCallback("Claimed")
}
```

``TelerouteRequestContext/removePressedButton()`` matches buttons by
`callback_data` and needs a readable keyboard, so it throws for an inline-mode
message — use `editReplyMarkup(nil)` there.

> Important: the closure's parameter is the context of the **press**. A
> context captured from the surrounding handler belongs to the earlier update,
> so answering through it throws ``TelerouteError/callbackQueryMissing``.
> Reply through the parameter.

#### What Inline Handlers Cannot Do

A closure cannot be serialized, so it lives in the memory of the process that
rendered it. Three consequences, all of which surface as the configured
`expired` response rather than silence:

1. **Buttons do not survive a restart.** Every id is lost on deploy. Anything
   that must keep working across restarts needs a typed callback route.
2. **They do not work across instances.** A press routed to a different
   replica finds nothing. Use typed callbacks, or sticky routing.
3. **They expire.** ``TelerouteInlineActionPolicy`` bounds the registry by age
   (30 minutes by default) and by count (10 000), evicting oldest-first.

```swift
.init(inlineActions: .enabled(
    ttl: .seconds(3600),
    capacity: 50_000,
    expired: .answerCallback("This button has expired — reopen the menu.")
))
```

Pass `expired: .unhandled` to let a dead press fall through to
`router.unmatched` instead.

### Reply Keyboards

Reply keyboards use `KeyRow`/`KeyButton`; plain strings become simple buttons:

```swift
let replyKeyboard = ReplyKeyboardMarkup(resize: true) {
    KeyRow {
        KeyButton("Share contact").requestContact()
        KeyButton("Share location").requestLocation()
    }
    KeyRow {
        for label in savedAddresses {      // loops work inside a row
            KeyButton(label)
        }
    }
    KeyRow {
        "Cancel"
    }
}

router.command("signup") { _ in
    Reply("How can we reach you?").keyboard(.keyboard(replyKeyboard))
}
```

``KeyButton`` covers the whole `KeyboardButton` surface: `requestContact`,
`requestLocation`, `requestUsers`, `requestChat`, `requestManagedBot`,
`requestPoll`, `webApp`, plus `icon` and `style`.

```swift
KeyButton("Invite friends").requestUsers(id: 1, maxQuantity: 5)
KeyButton("Pick a channel").requestChat(id: 2, isChannel: true)
KeyButton("Start a quiz").requestPoll("quiz")
KeyButton("Open app").webApp(url: "https://example.com/app")
```

The initializer also accepts `oneTime:`, `placeholder:`, and `selective:`.
The `ReplyMarkup` conveniences from the vocabulary cover the other cases —
`.inline(markup)`, `.keyboard(markup)`, `.remove()` (dismiss the reply
keyboard), and `.forceReply()`. ``Reply`` and ``Send`` spell the last two out
so a handler needs no vocabulary detour:

```swift
router.text("Cancel") { _ in
    Reply("Cancelled.").removeKeyboard()
}
router.command("name") { _ in
    Reply("What is your name?").forceReply(placeholder: "Name")
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
