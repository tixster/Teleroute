import Foundation
import SwiftTelegramBot

/// Values derived from a Telegram update and reused throughout one routing pass.
struct TelerouteParsedUpdate: Sendable {
    let update: TGUpdate
    let callbackQuery: TGCallbackQuery?
    let callbackData: String?
    let callbackComponents: [String]?
    let message: TGMessage?
    let command: TelerouteCommandMatch?
    let chatId: Int64?
    let chatType: TGChatType?
    let userId: Int64?
    let flowKey: TelerouteFlowKey?
    let routeKind: TelerouteEvent.RouteKind

    init(_ update: TGUpdate) {
        let callbackQuery = update.callbackQuery
        let callbackData = callbackQuery?.data
        let message = Self.resolveMessage(from: update)
        let command = TelerouteCommandExtractor.extract(from: update)
        let chatId = message?.chat.id ?? callbackQuery?.message?.chat.id
        let chatType = message?.chat.type ?? callbackQuery?.message?.chat.type
        let userId = callbackQuery?.from.id ?? message?.from?.id

        self.update = update
        self.callbackQuery = callbackQuery
        self.callbackData = callbackData
        self.callbackComponents = callbackData.map(TeleroutePath.components(from:))
        self.message = message
        self.command = command
        self.chatId = chatId
        self.chatType = chatType
        self.userId = userId
        self.flowKey = chatId.map { TelerouteFlowKey(chatId: $0, userId: userId) }
        self.routeKind = if command != nil {
            .command
        } else if callbackData != nil {
            .callback
        } else if message != nil {
            .message
        } else {
            .unknown
        }
    }

    private static func resolveMessage(from update: TGUpdate) -> TGMessage? {
        if let message = TelerouteMessageExtractor.extract(from: update) {
            return message
        }
        if case let .some(.message(message)) = update.callbackQuery?.message {
            return message
        }
        return nil
    }
}
