# Testing

Exercise routes, middleware, and flows in-process — no network, byte-accurate assertions.

## Overview

The `TelerouteTestSupport` product fakes the HTTP transport *underneath* the
real generated client, so tests run the production code path end to end:
routing, middleware, guards, response execution, and request encoding — with
zero network access.

```swift
// Package.swift test target:
.product(name: "TelerouteTestSupport", package: "Teleroute")
```

### A Complete Test

```swift
import Teleroute
import TelerouteTestSupport
import Testing

@Test func startCommand() async throws {
    let router = Teleroute()
    router.command("start") { _ in "Welcome" }

    let (bot, telegram) = try TelerouteTestSupport.makeTelerouteBot(router: router)
    try await bot.test { client in
        let result = await client.sendCommand("start")
        #expect(result.terminalEvent?.kind == .handled)
    }

    guard case let .sentMessage(message) = telegram.effects.first else {
        Issue.record("expected a sent message")
        return
    }
    #expect(message.text == "Welcome")
}
```

The pieces:

- `TelerouteTestSupport.makeTelerouteBot(router:)` builds a real
  ``TelerouteBot`` over a `TelerouteRecordingTransport` (with replay
  protection disabled so repeated synthetic updates aren't dropped).
- ``TelerouteBot/test(_:)`` runs the body without starting long polling and
  waits for all in-flight handlers before returning.
- ``TelerouteBotTestClient`` injects synthetic updates — `sendCommand`,
  `sendMessage`, `pressCallback`, or `execute(_:)` with any `Update` — and
  returns a ``TelerouteBotTestResult`` with the routing events for that
  update.
- The recording transport captures Telegram side effects (`sentMessage`,
  `editedMessage`, `answeredCallback`, `commandMenuUpdated`) for assertions.

### Asserting on Routing Outcomes

``TelerouteBotTestResult/terminalEvent`` is the last terminal event for the
update — `handled`, `unmatched`, `skippedDuplicate`, or `failed`:

```swift
try await bot.test { client in
    #expect(await client.sendCommand("start").terminalEvent?.kind == .handled)
    #expect(await client.sendMessage("gibberish").terminalEvent?.kind == .unmatched)
    #expect(await client.pressCallback("orders/7/approve").terminalEvent?.kind == .handled)
}
```

### Synthetic Update Factories

`TelerouteTestSupport` builds updates for every routable kind: commands,
plain/edited/photo messages, callback queries, inline queries, reactions,
chat-member updates, join requests, pre-checkout queries, and poll answers:

```swift
let update = TelerouteTestSupport.makeReactionUpdate(emoji: "🔥", chatId: 7)
let result = await client.execute(update)
```

All factories accept explicit `chatType:`, `userId:`, `chatId:`, and
`updateId:` so guard and scope behavior is easy to pin down.

### Stubbing Any of the 185 Operations

The recording transport has built-in fakes for the common operations. For
anything else, supply a `fallback:` that returns the raw response:

```swift
let telegram = TelerouteRecordingTransport { operationID, body in
    guard operationID == "getChatMember" else {
        throw TelerouteTestNetworkError.unsupportedMethod(operationID)
    }
    let json = #"{"ok":true,"result":{"status":"administrator","user":{"id":1,"is_bot":false,"first_name":"A"}}}"#
    var response = HTTPResponse(status: .ok)
    response.headerFields[.contentType] = "application/json"
    return (response, HTTPBody(json))
}
```

For routing-only tests that must never reach the API, use
`TelerouteStubTransport` — it throws on any call. Build a standalone client
over either transport with `TelerouteTestSupport.makeClient(transport:)`.

### Wire-Level Assertions

`TelerouteTestMultipart` parses `multipart/form-data` bodies so tests can
assert on exactly what would hit the wire — field values, JSON-encoded
keyboards, upload filenames:

```swift
let parts = try TelerouteTestMultipart.parts(from: body, contentType: contentType)
#expect(String(decoding: parts["chat_id"]!.body, as: UTF8.self) == "7")
#expect(parts["photo"]?.filename == "chart.png")
```

`TelerouteTestRecorder` collects values from concurrent handlers with a
polling `waitForCount(_:)`, and `TelerouteMockFlowStorage` exposes session
state for flow assertions.

### Testing Flows

```swift
@Test func signupFlow() async throws {
    let router = Teleroute()
    router.flow(SignupFlow())

    let (bot, _) = try TelerouteTestSupport.makeTelerouteBot(router: router)
    try await bot.test { client in
        _ = await client.sendCommand("signup")
        _ = await client.sendMessage("Alice")
        let done = await client.sendCommand("done")
        #expect(done.terminalEvent?.kind == .handled)
    }
}
```

> Note: The project convention (see the repository's testing guidelines) is
> Swift Testing (`import Testing`) and no network-dependent tests — the
> in-process approach above covers routing behavior deterministically.
