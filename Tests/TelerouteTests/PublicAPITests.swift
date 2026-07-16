import Testing
import Teleroute
import TelerouteTestSupport

@Test func externalCodeCanCreateFlowSessionForCustomStorage() {
    let session = TelerouteFlowSession(
        id: "SignupFlow",
        step: "name",
        values: .init(["name": "Alice"])
    )

    #expect(session.id == "SignupFlow")
    #expect(session.step == "name")
    #expect(session.values["name"] == "Alice")
}

@Test func legacyCustomStorageReceivesDefaultSessionMutationAPI() async throws {
    let storage = PublicLegacyFlowStorage()
    let key = TelerouteFlowKey(chatId: 1, userId: 2)

    await storage.setSession(
        .init(id: "flow", step: "one", values: .init(["first": "1"])),
        for: key
    )
    let updated = await storage.updateSession(for: key) { current in
        .init(
            id: current?.id ?? "flow",
            step: "two",
            values: .init((current?.values.dictionary ?? [:]).merging(["second": "2"]) { _, new in new })
        )
    }

    #expect(updated?.step == "two")
    #expect(updated?.values["first"] == "1")
    #expect(updated?.values["second"] == "2")
}

@Test func publicKeyboardRowAcceptsThrowingButtonExpressions() async throws {
    let bot = try await TelerouteTestSupport.makeBot()
    let router = Teleroute(bot: bot, logger: .init(label: "public.keyboard.throwing"))

    let keyboard = try router.callbackKeyboard {
        try TelerouteKeyboardBuilder.Row {
            try router.callbackButton("Open", path: "items/{id}", parameters: ["id": "42"])
        }
    }

    #expect(keyboard.inlineKeyboard.first?.first?.callbackData == "items/42")
    router.shutdown()
}

@Test func publicMacrosExposeOptionalMemberwiseInitializers() throws {
    let command = PublicOptionalCommand(value: nil)
    let callback = PublicOptionalCallback(value: "42")

    #expect(command.value == nil)
    #expect(try callback.parameters == ["value": "42"])
}

private actor PublicLegacyFlowStorage: TelerouteFlowStorage {
    private var sessions: [TelerouteFlowKey: TelerouteFlowSession] = [:]

    func session(for key: TelerouteFlowKey) -> TelerouteFlowSession? {
        self.sessions[key]
    }

    func setSession(_ session: TelerouteFlowSession, for key: TelerouteFlowKey) {
        self.sessions[key] = session
    }

    func removeSession(for key: TelerouteFlowKey) {
        self.sessions[key] = nil
    }
}

@TelerouteCommand("optional")
private struct PublicOptionalCommand {
    let value: String?
}

@TelerouteCallback("optional/{value}")
private struct PublicOptionalCallback {
    let value: String?
}
