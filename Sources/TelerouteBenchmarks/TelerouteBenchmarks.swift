import Foundation
import Logging
import Teleroute
import TelerouteTestSupport

@main
struct TelerouteBenchmarks {
    private static let updateCount = 2_000
    private static let routeCounts = [10, 100, 1_000]

    static func main() async throws {
        print("Teleroute routing benchmark (release mode recommended)")
        print("updates per scenario: \(self.updateCount)")

        for routeCount in self.routeCounts {
            let duration = try await self.measureCommands(routeCount: routeCount)
            self.printResult(kind: "command", routeCount: routeCount, duration: duration)
        }

        for routeCount in self.routeCounts {
            let duration = try await self.measureCallbacks(routeCount: routeCount)
            self.printResult(kind: "callback", routeCount: routeCount, duration: duration)
        }

        for routeCount in self.routeCounts {
            let duration = try await self.measureMessages(routeCount: routeCount)
            self.printResult(kind: "message ", routeCount: routeCount, duration: duration)
        }
    }

    private static func measureMessages(routeCount: Int) async throws -> Duration {
        let telegramBot = try TelerouteTestSupport.makeClient()
        var logger = Logger(label: "teleroute.benchmark.message")
        logger.logLevel = .critical
        let router = Teleroute()
        let bot = TelerouteBot(
            client: telegramBot,
            router: router,
            logger: logger,
            configuration: .init(replayProtectionStorage: nil)
        )
        let completion = BenchmarkCompletion()

        for index in 0..<routeCount {
            router.text("text-\(index)") { (_: TelerouteContext) -> Void in
                if index == routeCount - 1 {
                    await completion.record()
                }
            }
        }

        let updates = (0..<self.updateCount).map { index in
            TelerouteTestSupport.makeMessageUpdate(
                text: "text-\(routeCount - 1)",
                updateId: Int64(30_000 + index)
            )
        }
        let duration = await ContinuousClock().measure {
            await bot.process(updates)
            await completion.wait(until: self.updateCount)
        }
        await bot.shutdown()
        return duration
    }

    private static func measureCommands(routeCount: Int) async throws -> Duration {
        let telegramBot = try TelerouteTestSupport.makeClient()
        var logger = Logger(label: "teleroute.benchmark.command")
        logger.logLevel = .critical
        let router = Teleroute()
        let bot = TelerouteBot(
            client: telegramBot,
            router: router,
            logger: logger,
            configuration: .init(replayProtectionStorage: nil)
        )
        let completion = BenchmarkCompletion()

        for index in 0..<routeCount {
            router.command("route\(index)") { (_: TelerouteContext) -> Void in
                if index == routeCount - 1 {
                    await completion.record()
                }
            }
        }

        let updates = (0..<self.updateCount).map { index in
            TelerouteTestSupport.makeCommandUpdate(
                text: "/route\(routeCount - 1)",
                updateId: Int64(10_000 + index)
            )
        }
        let duration = await ContinuousClock().measure {
            await bot.process(updates)
            await completion.wait(until: self.updateCount)
        }
        await bot.shutdown()
        return duration
    }

    private static func measureCallbacks(routeCount: Int) async throws -> Duration {
        let telegramBot = try TelerouteTestSupport.makeClient()
        var logger = Logger(label: "teleroute.benchmark.callback")
        logger.logLevel = .critical
        let router = Teleroute()
        let bot = TelerouteBot(
            client: telegramBot,
            router: router,
            logger: logger,
            configuration: .init(replayProtectionStorage: nil)
        )
        let completion = BenchmarkCompletion()

        for index in 0..<routeCount {
            router.callback("route\(index)/{value}") { (_: TelerouteContext) -> Void in
                if index == routeCount - 1 {
                    await completion.record()
                }
            }
        }

        let updates = (0..<self.updateCount).map { index in
            TelerouteTestSupport.makeCallbackUpdate(
                data: "route\(routeCount - 1)/\(index)",
                updateId: Int64(20_000 + index)
            )
        }
        let duration = await ContinuousClock().measure {
            await bot.process(updates)
            await completion.wait(until: self.updateCount)
        }
        await bot.shutdown()
        return duration
    }

    private static func printResult(kind: String, routeCount: Int, duration: Duration) {
        let components = duration.components
        let milliseconds = Double(components.seconds) * 1_000
            + Double(components.attoseconds) / 1_000_000_000_000_000
        let updatesPerSecond = Double(self.updateCount) / (milliseconds / 1_000)
        print(
            String(
                format: "%@ routes=%4d  %8.2f ms  %10.0f updates/s",
                kind,
                routeCount,
                milliseconds,
                updatesPerSecond
            )
        )
    }
}

private actor BenchmarkCompletion {
    private var count = 0
    private var target: Int?
    private var continuation: CheckedContinuation<Void, Never>?

    func record() {
        self.count += 1
        guard let target = self.target, self.count >= target else { return }
        self.target = nil
        let continuation = self.continuation
        self.continuation = nil
        continuation?.resume()
    }

    func wait(until target: Int) async {
        guard self.count < target else { return }
        await withCheckedContinuation { continuation in
            self.target = target
            self.continuation = continuation
        }
    }
}
