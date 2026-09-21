import Foundation
import Testing
import Teleroute
import TelerouteTestSupport

/// Covers the request-scoped logger on ``TelerouteContext`` and the metadata the
/// runtime and flow coordinator attach to it.
@Suite struct TelerouteContextLoggerTests {
    @Test func handlerLoggerCarriesUpdateMetadata() async throws {
        let router = Teleroute()
        router.command("start") { (context: TelerouteContext) -> Void in
            context.logger.info("handler ran")
        }

        let (bot, _, logs) = try TelerouteTestSupport.makeTelerouteBotCapturingLogs(
            router: router
        )
        try await bot.test { client in
            _ = await client.sendCommand("start", updateId: 9_001)
        }
        await bot.shutdown()

        let entry = try #require(logs.first(message: "handler ran"))
        #expect(entry.metadataValue("update_id") == "9001")
        #expect(entry.metadataValue("chat_id") == "1")
        #expect(entry.metadataValue("user_id") == "1")
        #expect(entry.metadataValue("route_kind") == "command")
        #expect(entry.metadataValue("command") == "start")
    }

    @Test func callbackHandlerLoggerCarriesCallbackMetadata() async throws {
        let router = Teleroute()
        router.callback("orders/{id}/approve") { (context: TelerouteContext) -> Void in
            context.logger.info("callback ran")
        }

        let (bot, _, logs) = try TelerouteTestSupport.makeTelerouteBotCapturingLogs(
            router: router
        )
        try await bot.test { client in
            _ = await client.pressCallback("orders/7/approve", updateId: 9_002)
        }
        await bot.shutdown()

        let entry = try #require(logs.first(message: "callback ran"))
        #expect(entry.metadataValue("route_kind") == "callback")
        #expect(entry.metadataValue("callback_data") == "orders/7/approve")
    }

    /// A flow step's logger carries the update metadata *and* the flow's own
    /// identity, which is what makes multi-step conversations traceable.
    @Test func flowStepLoggerCarriesFlowMetadata() async throws {
        let router = Teleroute()
        router.flow(LoggingFlow())

        let (bot, _, logs) = try TelerouteTestSupport.makeTelerouteBotCapturingLogs(
            router: router
        )
        try await bot.test { client in
            _ = await client.sendCommand("logflow", updateId: 9_003)
            _ = await client.sendMessage("Alice", updateId: 9_004)
        }
        await bot.shutdown()

        let entry = try #require(logs.first(message: "flow step ran"))
        #expect(entry.metadataValue("flow_id") == LoggingFlow.id)
        #expect(entry.metadataValue("flow_step") == "name")
        #expect(entry.metadataValue("update_id") == "9004")
        #expect(entry.metadataValue("chat_id") == "1")
    }

    @Test func loggingMetadataReturnsContextWithAddedMetadata() {
        let context = TelerouteContext(
            bot: try! TelerouteTestSupport.makeClient(),
            update: TelerouteTestSupport.makeCommandUpdate(text: "/start")
        )
        let enriched = context.logging(metadata: ["tenant": .string("acme")])

        #expect(enriched.logger[metadataKey: "tenant"] != nil)
        #expect(context.logger[metadataKey: "tenant"] == nil)
    }
}

private struct LoggingFlow: TelerouteFlow {
    enum Step: String, Sendable {
        case name
    }

    func boot(flow: TelerouteFlowGroup<LoggingFlow>) {
        flow.start("logflow", at: .name) { _ in }
        flow.message(at: .name) { context in
            context.logger.info("flow step ran")
        }
    }
}
