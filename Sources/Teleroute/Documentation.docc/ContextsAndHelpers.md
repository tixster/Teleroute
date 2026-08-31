# Contexts and Helpers

Access update data and the Telegram API through request contexts, and define your own typed contexts.

## Overview

Every handler receives a *request context* — a value conforming to
``TelerouteRequestContext``. The default is ``TelerouteContext``, and custom
contexts wrap it to carry your own request-scoped state. All contexts (custom
and flow contexts included) share the same data accessors and Telegram
helpers.

### Update Data

```swift
router.command("whoami") { context in
    """
    chat: \(context.chatId ?? 0) (\(context.chatType?.rawValue ?? "?"))
    user: \(context.userId ?? 0)
    kind: \(context.updateKind?.rawValue ?? "?")
    """
}
```

Available on every context: `update` (the raw `Update`), `message`
(best-effort resolved from regular, edited, business, and callback-carried
messages), `chatId`, `chatType`, `userId`, `updateKind`, `messageSource`,
`callbackQuery`, `callbackData`, `command` (``TelerouteCommandMatch``),
`parameters` (``TelerouteParameters``), plus typed payload accessors such as
`inlineQuery`, `preCheckoutQuery`, `chatJoinRequest`, and `messageReaction`.

### Messaging Helpers

The most common Telegram actions are one-liners:

```swift
try await context.reply("Linked reply", quote: "original passage")
try await context.send("Unlinked message", to: "@channel", silent: true)
try await context.edit("New text", replyMarkup: keyboard)
try await context.editCaption("New caption")
try await context.editReplyMarkup(nil)          // remove the keyboard
try await context.deleteMessage()
try await context.forwardMessage(from: .id(source), messageId: 42)
try await context.copyMessage(from: .id(source), messageId: 42, caption: "FYI")
try await context.react("🔥")
try await context.pinMessage(silent: true)
try await context.typing()
try await context.withChatAction(.uploadPhoto) {
    try await renderAndSendChart(context)
}
```

Media helpers accept a `FileInput` (`.fileID`, `.url`, or
`.upload(filename:data:)`):

```swift
try await context.sendPhoto(.upload(filename: "chart.png", data: png),
                            caption: "Daily stats")
try await context.sendDocument(.url("https://example.com/report.pdf"))
try await context.sendVideo(.fileID(existingFileId))
try await context.sendMediaGroup([...])
try await context.sendLocation(latitude: 52.51, longitude: 13.37)
try await context.sendDice()
```

Moderation and chat management:

```swift
if try await context.isAdmin() {
    try await context.banMember(offenderId, revokeMessages: true)
    try await context.restrictMember(otherId, permissions: .init(canSendMessages: false))
}
try await context.approveJoinRequest()
try await context.declineJoinRequest()
let member = try await context.getChatMember(userId: 42)
```

Helpers resolve their target from the update — an explicit `to:`/`in:`
argument always wins. Anything not covered by a helper is one call away on
the full typed client: `context.bot.<operation>(...)` (185 operations).

### Custom Contexts

Define a context type to carry request-scoped state — an authenticated user,
a database handle, a locale. Conform to
``TelerouteInitializableRequestContext`` and give the router your type:

```swift
struct AppContext: TelerouteInitializableRequestContext {
    let coreContext: TelerouteContext
    var user: User?

    init(source: TelerouteContextSource) {
        self.coreContext = source.coreContext
    }
}

let router = Teleroute(context: AppContext.self)

router.command("me") { context in
    "You are \(context.user?.firstName ?? "unknown")"
}
```

The only requirement is exposing ``TelerouteRequestContext/coreContext`` — all
helpers come for free. When construction needs asynchronous work or injected
services, use the factory initializer instead:

```swift
let router = Teleroute(context: AppContext.self) { source in
    var context = AppContext(source: source)
    context.user = await userService.lookup(source.coreContext.userId)
    return context
}
```

Middleware over your context can also populate fields per-request; see
<doc:MiddlewareAndGuards>.

### Child Contexts

Nested groups can *refine* the context — for example turning an optional
authenticated user into a guaranteed admin. Conform to
``TelerouteChildRequestContext`` and throw when the refinement fails:

```swift
struct AdminContext: TelerouteChildRequestContext {
    let coreContext: TelerouteContext
    let adminName: String

    static let admins: Set<Int64> = [42]

    init(context: AppContext) async throws {
        guard let user = context.user, Self.admins.contains(user.id) else {
            throw TelerouteAbort("Admins only")
        }
        self.coreContext = context.coreContext
        self.adminName = user.firstName
    }
}

router.group("admin", context: AdminContext.self) { admin in
    admin.command("ban") { context in "Banned by \(context.adminName)" }
}
```

Handlers inside the group get compile-time access to the refined fields —
no optional unwrapping in every handler.

### Flow Control from Any Context

Contexts can start and cancel flow sessions
(``TelerouteRequestContext/start(_:at:values:)`` and
``TelerouteRequestContext/cancelFlow()``); see <doc:Flows>.
