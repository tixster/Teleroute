import Foundation

/// Process-environment helpers for bot bootstrap.
public enum TelerouteEnvironment: Sendable {
    /// Errors thrown while reading bot configuration from the environment.
    public enum Error: LocalizedError, Sendable, Equatable {
        /// The variable is unset, or set to an empty/whitespace-only value.
        case missingVariable(String)

        public var errorDescription: String? {
            switch self {
            case let .missingVariable(key):
                "Environment variable '\(key)' is not set."
            }
        }
    }

    /// Reads the bot token from the process environment.
    ///
    /// ```swift
    /// let bot = try TelerouteBot(
    ///     token: TelerouteEnvironment.token(),
    ///     router: router
    /// )
    /// ```
    ///
    /// - Throws: ``Error/missingVariable(_:)`` when the variable is unset or
    ///   blank, so a misconfigured deployment fails at startup with a message
    ///   that names the variable instead of at the first Telegram call with a
    ///   401.
    public static func token(_ key: String = "TELEGRAM_BOT_TOKEN") throws -> String {
        try self.require(key)
    }

    /// Reads a required environment variable, rejecting blank values.
    public static func require(_ key: String) throws -> String {
        guard let value = self.value(key) else {
            throw Error.missingVariable(key)
        }
        return value
    }

    /// Reads an environment variable, treating a blank value as absent.
    public static func value(_ key: String) -> String? {
        guard let raw = ProcessInfo.processInfo.environment[key] else { return nil }
        let trimmed = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        return trimmed.isEmpty ? nil : trimmed
    }
}
