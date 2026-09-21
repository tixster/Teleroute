# Responses

Return values from handlers describe the bot's Telegram effect declaratively.

## Overview

Route handlers return any ``TelerouteResponseGenerator``. The framework turns
the returned value into one or more Telegram API calls after the handler (and
its middleware chain) completes:

```swift
router.command("hi") { _ in "hello" }                       // String → reply
router.command("fancy") { _ in
    Reply("<b>Done</b>").parseMode(.html).silent().quoting("summary")
}
router.command("classic") { _ in .send("Posted", to: "@channel") }
router.command("chain") { _ in
    [TelerouteResponse.answerCallback("Ok"), .edit("Done")]  // array → sequence
}
router.command("quiet") { context in                        // Void → done
    try await context.sendChatAction(.typing)
}
```

Conforming types:

| Returned value | Effect |
| --- | --- |
| `String` | Plain-text reply to the current message. |
| ``Reply``, ``Send``, ``Edit``, ``AnswerCallback``, ``Delete``, ``React`` | The corresponding chainable action. |
| ``TelerouteResponse`` | Any response case, including `.sequence`. |
| `Optional` | `nil` means "done, no action". |
| `Array` | Runs its elements in order (a `.sequence`). |
| `Void` handler overloads | Completes with no action. |
| ``TelerouteUnhandled`` / `.unhandled` | Falls through to the next candidate route. |

### Chainable Action Builders

``Reply`` and ``Send`` share send-style options
(``TelerouteSendOptions``) and support fluent modifiers:

```swift
Reply("Saved ✅")
    .parseMode(.html)          // or rely on defaultParseMode
    .quoting("exact passage")  // quote part of the original message
    .silent()                  // disable the notification
    .protected()               // forbid forwarding/saving
    .withoutLinkPreview()
    .removeKeyboard()          // or .forceReply(placeholder: "Name")

Send("Deploy finished", to: "@releases")
    .thread(42)                // post into a forum topic
    .effect("5104841245755180586")

Edit("Page 2 of 5")
    .keyboard(markup)          // swap the inline keyboard
    .message(1234, in: 5678)   // edit an explicit message

AnswerCallback(text: "No access").alert()

Delete()                       // delete the update's message
React("👍", big: true)
```

`.reply` attaches `reply_parameters`, so replies are visibly linked to the
incoming message. `.send` posts an unlinked message and accepts an explicit
target chat; without one it uses the chat resolved from the update.

### Sequences

Combine several actions in order — the idiomatic response to an inline-button
press is answer-then-edit:

```swift
router.callback("orders/{id}/approve") { context in
    .sequence([
        .answerCallback("Approved"),
        .edit("Order \(context.parameters["id"] ?? "?") approved ✅"),
    ])
}
```

### Keyboards Inside a Response

``Reply``, ``Send``, and ``Edit`` also take the keyboard result builder, so the
markup is written where the response is:

```swift
router.command("orders") { _ in
    Reply("Your orders:").keyboard {
        Row { route.button(OrderPage(id: "7", page: 1), "Next ▶︎") }
    }
}
```

The buttons are rendered when the response executes, against the router serving
the update — typed callbacks are validated exactly as they are by
`router.keyboard { … }`, and a button for an unregistered route (or one whose
`callback_data` exceeds Telegram's 64-byte limit) surfaces through
``TelerouteConfiguration/errorRenderer`` like any other handler error. See
<doc:Keyboards>.

Arrays of any generator work too, so `[Reply("one"), Reply("two")]` sends two
replies.

### Default Parse Mode

A configured ``TelerouteConfiguration/defaultParseMode`` applies to every text
helper and response builder that doesn't set its own:

```swift
let configuration = TelerouteConfiguration(defaultParseMode: .html)
// Now `Reply("<b>bold</b>")` and `context.reply("<i>hi</i>")` render as HTML.
```

### Callback Auto-Answering

Telegram keeps an inline button's spinner running until the callback query is
answered. Teleroute answers handled callback queries automatically (with an
empty answer) whenever the handler did not answer it itself:

```swift
// Automatically answered after the edit:
router.callback("noop") { _ in .edit("Done") }

// Answered explicitly — no auto-answer happens:
router.callback("save") { context in
    try await context.answerCallbackQuery("Saved!", showAlert: false)
}

// Deliberately leave the query unanswered:
router.callback("later") { context in
    context.skipCallbackAutoAnswer()
}
```

Disable the behavior globally with
``TelerouteConfiguration/autoAnswerCallbackQueries``.

### Falling Through

Return `.unhandled` when a route inspected the update and decided it is not
responsible. Matching continues with the next candidate and finally the
`unmatched` hook:

```swift
router.message(.text) { context in
    guard context.message?.text?.contains("teleroute") == true else {
        return TelerouteResponse.unhandled
    }
    return .reply("Someone said Teleroute?")
}
```

### Responses vs. Imperative Helpers

Declarative responses and imperative context helpers compose freely — do the
side effects inside the handler and return the final visible action:

```swift
router.command("report") { context in
    try await context.typing()
    let url = try await uploadReport()
    return Reply("Your report: \(url)").withoutLinkPreview()
}
```

Middleware sees (and may replace) the returned response before it executes,
which is what makes the declarative style testable and composable; see
<doc:MiddlewareAndGuards>.
