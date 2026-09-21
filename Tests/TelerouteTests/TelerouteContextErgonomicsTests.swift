import Foundation
import Testing
import Teleroute
import TelerouteTestSupport

/// Covers the accessors and `require*` resolvers that replace optional chains
/// like `context.message?.from?.firstName` in handlers.
@Suite struct TelerouteContextErgonomicsTests {
    private func context(_ update: Update) throws -> TelerouteContext {
        TelerouteContext(bot: try TelerouteTestSupport.makeClient(), update: update)
    }

    @Test func userResolvesFromAMessage() throws {
        let context = try self.context(
            TelerouteTestSupport.makeMessageUpdate(text: "hi", userId: 42)
        )
        #expect(context.user?.id == 42)
        #expect(try context.requireUser().id == 42)
        #expect(try context.requireUserId() == 42)
    }

    /// The payoff: a callback query has no `message.from` for the presser, so
    /// the old idiom returned the wrong user or nil. `user` resolves it.
    @Test func userResolvesFromACallbackQuery() throws {
        let context = try self.context(
            TelerouteTestSupport.makeCallbackUpdate(data: "orders/7", callbackUserId: 99)
        )
        #expect(context.user?.id == 99)
        #expect(context.callbackQuery?.from.id == 99)
    }

    @Test func userResolvesFromAnInlineQuery() throws {
        let context = try self.context(
            TelerouteTestSupport.makeInlineQueryUpdate(query: "cats", userId: 7)
        )
        #expect(context.user?.id == 7)
        // An inline query has no chat at all, which is exactly the case the
        // require* family reports rather than silently defaulting.
        #expect(context.chatId == nil)
        #expect(throws: TelerouteError.self) { try context.requireChatId() }
    }

    @Test func requireUserThrowsForUpdateWithoutAUser() throws {
        let context = try self.context(Update(updateId: 1))
        #expect(context.user == nil)
        #expect(throws: TelerouteError.self) { try context.requireUser() }
        #expect(throws: TelerouteError.self) { try context.requireUserId() }
    }

    @Test func requireMessageAndCommandReportWhatIsMissing() throws {
        let context = try self.context(
            TelerouteTestSupport.makeMessageUpdate(text: "plain")
        )
        #expect(try context.requireMessage().text == "plain")
        // A plain message is not a command route, and carries no callback.
        #expect(throws: TelerouteError.self) { try context.requireCommand() }
        #expect(throws: TelerouteError.self) { try context.requireCallbackQuery() }
    }

    @Test func chatResolvesFromMessageAndCallback() throws {
        let fromMessage = try self.context(
            TelerouteTestSupport.makeMessageUpdate(text: "hi", chatId: 5)
        )
        #expect(fromMessage.chat?.id == 5)

        let fromCallback = try self.context(
            TelerouteTestSupport.makeCallbackUpdate(data: "x", chatId: 6)
        )
        #expect(fromCallback.chat?.id == 6)
    }

    /// `updateKind` and `messageSource` are deliberately NOT deduplicated onto
    /// the protocol extension: it reads them back through `coreContext`, which
    /// is `self` here, so removing the concrete overrides would recurse
    /// forever. A hang, not a compile error — hence the time limit.
    @Test(.timeLimit(.minutes(1)))
    func contextUpdateKindDoesNotRecurse() throws {
        let context = try self.context(
            TelerouteTestSupport.makeMessageUpdate(text: "hi")
        )
        #expect(context.updateKind == .message)
        #expect(context.messageSource == .message)

        // Same two accessors reached through the protocol extension.
        func viaProtocol(_ context: some TelerouteRequestContext) -> UpdateKind? {
            context.updateKind
        }
        #expect(viaProtocol(context) == .message)
    }
}

/// Typed value decoding, kept symmetric across the three string-keyed bags.
@Suite struct TelerouteTypedValueTests {
    @Test func flowValuesDecodeTypedValues() throws {
        let values = TelerouteFlowValues(["amount": "12.5", "page": "3", "name": "Alice"])

        #expect(try values.require("amount", as: Double.self) == 12.5)
        #expect(values.get("page", as: Int.self) == 3)
        #expect(values.get("name", as: Int.self) == nil)
        #expect(values.count == 3)
    }

    @Test func flowValuesRequireReportsMalformedValues() {
        let values: TelerouteFlowValues = ["page": "not-a-number"]

        #expect(throws: TelerouteError.self) {
            try values.require("page", as: Int.self)
        }
        #expect(throws: TelerouteError.self) {
            try values.require("missing", as: Int.self)
        }
    }

    @Test func flowValuesMergeAndRemove() {
        let values: TelerouteFlowValues = ["a": "1", "b": "2"]

        #expect(values.merging(["b": "3", "c": "4"]).dictionary == ["a": "1", "b": "3", "c": "4"])
        #expect(values.removing("a").dictionary == ["b": "2"])
        #expect(values.removing("a", "b").isEmpty)
        // Merging is non-mutating.
        #expect(values.dictionary == ["a": "1", "b": "2"])
    }

    @Test func parametersDecodeTypedValues() throws {
        let parameters = TelerouteParameters(["page": "7", "id": "abc"])

        #expect(parameters.get("page", as: Int.self) == 7)
        #expect(parameters.get("id", as: Int.self) == nil)
        #expect(try parameters.require("page", as: Int.self) == 7)
    }
}
