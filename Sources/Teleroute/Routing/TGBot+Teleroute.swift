import SwiftTelegramBot
import Foundation

public extension TGBot {
    /// Adds a `Teleroute` as a regular Telegram dispatcher.
    func add(router: Teleroute) async throws {
        try await self.add(dispatcher: router)
    }
}
