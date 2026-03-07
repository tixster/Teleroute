import Teleroute

/// Logger factory used by the example target.
///
/// The example opts into `debug` logging by default so that route matching,
/// replay protection, and flow routing decisions are visible during manual
/// testing. This is useful for learning the library and for diagnosing changes
/// to the example itself.
enum ExampleLoggerFactory {
    static func makeBotLogger() -> Logger {
        var logger = Logger(label: "teleroute.example.bot")
        logger.logLevel = .debug
        return logger
    }

    static func makeRouterLogger() -> Logger {
        var logger = Logger(label: "teleroute.example.router")
        logger.logLevel = .debug
        return logger
    }

    static func makeMiddlewareLogger(label: String) -> Logger {
        var logger = Logger(label: "teleroute.example.middleware.\(label)")
        logger.logLevel = .debug
        return logger
    }
}
