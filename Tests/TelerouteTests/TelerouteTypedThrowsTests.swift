import Foundation
import Testing
import Teleroute
import TelerouteTestSupport

/// The resolution and `require` families throw `TelerouteError` and nothing
/// else, so they are declared `throws(TelerouteError)`. These pin that contract
/// — both that it holds, and that it stops exactly where it should.
@Suite struct TelerouteTypedThrowsTests {
    /// Each `switch` below compiles only while the thrown type is concrete:
    /// `error` is bound to `TelerouteError` with no cast. That is the whole
    /// point of the typed signature.
    @Test func requireFamilyThrowsTelerouteErrorConcretely() throws {
        let context = TelerouteContext(
            bot: try TelerouteTestSupport.makeClient(),
            update: Update(updateId: 1)
        )

        do {
            _ = try context.requireChatId()
            Issue.record("expected a throw")
        } catch {
            switch error {
            case .chatTargetMissing: break
            default: Issue.record("unexpected \(error)")
            }
        }

        do {
            _ = try context.requireUser()
            Issue.record("expected a throw")
        } catch {
            switch error {
            case .userTargetMissing: break
            default: Issue.record("unexpected \(error)")
            }
        }
    }

    @Test func parametersValuesAndCommandMatchThrowConcretely() {
        do {
            _ = try TelerouteParameters().require("missing")
            Issue.record("expected a throw")
        } catch {
            switch error {
            case let .missingParameter(name): #expect(name == "missing")
            default: Issue.record("unexpected \(error)")
            }
        }

        do {
            _ = try TelerouteFlowValues(["page": "x"]).require("page", as: Int.self)
            Issue.record("expected a throw")
        } catch {
            switch error {
            case let .invalidParameter(name, value):
                #expect(name == "page")
                #expect(value == "x")
            default:
                Issue.record("unexpected \(error)")
            }
        }

        let command = TelerouteCommandMatch(
            name: "cmd",
            rawValue: "/cmd",
            mentionedBotUsername: nil,
            argumentsText: nil,
            arguments: []
        )
        do {
            _ = try command.require("id")
            Issue.record("expected a throw")
        } catch {
            switch error {
            case let .missingParameter(name): #expect(name == "id")
            default: Issue.record("unexpected \(error)")
            }
        }
    }

    /// A typed-throws function must still satisfy every untyped context, which
    /// is what keeps the change source-compatible for existing callers.
    @Test func typedThrowsStaysCompatibleWithUntypedCallers() throws {
        let context = TelerouteContext(
            bot: try TelerouteTestSupport.makeClient(),
            update: TelerouteTestSupport.makeMessageUpdate(text: "hi")
        )

        // Erased into an untyped throwing function value.
        let resolve: () throws -> Int64 = context.requireChatId
        #expect(try resolve() == 1)

        // Fed through a `rethrows` generic.
        func consume<T>(_ body: () throws -> T) rethrows -> T { try body() }
        #expect(try consume { try context.requireMessage() }.text == "hi")

        // Caught and used as `any Error`.
        do {
            _ = try context.requireCallbackQuery()
            Issue.record("expected a throw")
        } catch {
            let erased: any Error = error
            #expect(erased is TelerouteError)
        }
    }
}

/// Typed throws stops at the network and at JSON: those paths surface
/// `TelegramAPIError`, transport errors, or `DecodingError`, none of which are
/// `TelerouteError`. This documents the boundary as a compiling assertion.
@Suite struct TelerouteUntypedThrowsBoundaryTests {
    @Test func jsonBackedStateStaysUntyped() {
        let values = TelerouteFlowValues([TelerouteFlowValues.stateKey: "not json"])

        do {
            _ = try values.state(Probe.self)
            Issue.record("expected a throw")
        } catch {
            // Binding to `any Error` only compiles while `state(_:)` is
            // untyped, and the thrown value really is not a TelerouteError.
            let erased: any Error = error
            #expect(erased is TelerouteError == false)
        }
    }

    private struct Probe: Codable, Sendable {
        var value = 0
    }
}
