# ``TelerouteTestSupport``

Test doubles and factories for exercising Teleroute bots in-process.

## Overview

`TelerouteTestSupport` fakes the HTTP transport *underneath* the real
generated Telegram client, so tests run the production code path — routing,
middleware, guards, response execution, request encoding — with no network
access and byte-accurate assertions.

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
    guard case let .sentMessage(message) = telegram.effects.first else { return }
    #expect(message.text == "Welcome")
}
```

### Building Test Bots and Clients

The ``TelerouteTestSupport/TelerouteTestSupport`` namespace provides the
factories:

- `makeTelerouteBot(router:configuration:label:)` — a complete routed bot over
  a ``TelerouteRecordingTransport``, with replay protection disabled so
  repeated synthetic updates aren't dropped;
- `makeClient(transport:)` — a standalone `TelegramBotClient` over any
  transport (default: ``TelerouteStubTransport``).

It also builds synthetic updates for every routable kind:
`makeCommandUpdate`, `makeMessageUpdate`, `makePhotoMessageUpdate`,
`makeEditedMessageUpdate`, `makeCallbackUpdate`, `makeInlineQueryUpdate`,
`makeReactionUpdate`, `makeChatMemberUpdate`, `makePreCheckoutUpdate`,
`makeJoinRequestUpdate`, and `makePollAnswerUpdate` — each with configurable
chat type, user, chat, and update identifiers.

Convenience senders on `TelerouteBotTestClient` (`sendCommand`,
`sendMessage`, `pressCallback`) wrap the factories for the common cases.

### Transports

- ``TelerouteRecordingTransport`` records common Telegram side effects
  (messages, edits, callback answers, command-menu updates) while returning
  synthetic successful responses. A `fallback:` closure fakes any of the 185
  operations the transport has no built-in response for.
- ``TelerouteStubTransport`` throws ``TelerouteTestNetworkError/unexpectedCall``
  on every request — for routing tests that must never reach the API.

```swift
let telegram = TelerouteRecordingTransport { operationID, body in
    // Return (HTTPResponse, HTTPBody?) for operations you want to fake.
    throw TelerouteTestNetworkError.unsupportedMethod(operationID)
}
```

### Asserting on Effects

Recorded effects arrive in request order as ``TelerouteRecordedEffect``
values:

```swift
for effect in telegram.effects {
    switch effect {
    case let .sentMessage(message):        // TelerouteRecordedMessage
        print(message.chatId, message.text, message.replyMarkup as Any)
    case let .editedMessage(edit):         // TelerouteRecordedEdit
        print(edit.text)
    case let .answeredCallback(answer):    // TelerouteRecordedCallbackAnswer
        print(answer.callbackQueryId, answer.text as Any)
    case .commandMenuUpdated:
        break
    }
}
```

For wire-level assertions, ``TelerouteTestMultipart`` parses
`multipart/form-data` request bodies into named parts
(``TelerouteTestMultipartPart``) — field values, JSON-encoded keyboards,
upload filenames.

### Concurrency and Flow Helpers

- ``TelerouteTestRecorder`` collects values from concurrent handlers and
  polls with `waitForCount(_:retries:)`;
- ``TelerouteMockFlowStorage`` is a dictionary-backed flow storage exposing
  `count` and `contains(_:)` for asserting on session state.

## Topics

### Building Test Bots

- ``TelerouteTestSupport/TelerouteTestSupport``

### Transports

- ``TelerouteStubTransport``
- ``TelerouteRecordingTransport``
- ``TelerouteTestNetworkError``

### Recorded Effects

- ``TelerouteRecordedEffect``
- ``TelerouteRecordedMessage``
- ``TelerouteRecordedEdit``
- ``TelerouteRecordedCallbackAnswer``

### Wire-Level Assertions

- ``TelerouteTestMultipart``
- ``TelerouteTestMultipartPart``

### Test Utilities

- ``TelerouteTestRecorder``
- ``TelerouteMockFlowStorage``
