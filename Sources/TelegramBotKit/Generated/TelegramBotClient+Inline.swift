// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

import Foundation
import TelegramBotAPI

public extension TelegramBotClient {
    /// Use this method to process a received chat join request query by showing a Mini App to
    /// the user before deciding the outcome. Call `answerChatJoinRequestQuery` to resolve the
    /// join request query based on the user interaction with the Mini App. Returns *True* on
    /// success.
    @discardableResult
    func sendChatJoinRequestWebApp(
        chatJoinRequestQueryId: Swift.String,
        webAppUrl: Swift.String
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("sendChatJoinRequestWebApp")
        request.set("chat_join_request_query_id", chatJoinRequestQueryId)
        request.set("web_app_url", webAppUrl)
        return try await self.perform(request)
    }

    /// Use this method to reply to a received guest message. On success, a ``SentGuestMessage``
    /// object is returned.
    @discardableResult
    func answerGuestQuery(
        guestQueryId: Swift.String,
        result: InlineQueryResult
    ) async throws -> SentGuestMessage {
        var request = TelegramRequest("answerGuestQuery")
        request.set("guest_query_id", guestQueryId)
        request.set("result", result)
        return try await self.perform(request)
    }

    /// Use this method to set the result of an interaction with a Web App and send a
    /// corresponding message on behalf of the user to the chat from which the query originated.
    /// On success, a ``SentWebAppMessage`` object is returned.
    @discardableResult
    func answerWebAppQuery(
        webAppQueryId: Swift.String,
        result: InlineQueryResult
    ) async throws -> SentWebAppMessage {
        var request = TelegramRequest("answerWebAppQuery")
        request.set("web_app_query_id", webAppQueryId)
        request.set("result", result)
        return try await self.perform(request)
    }

    /// Stores a message that can be sent by a user of a Mini App. Returns a
    /// ``PreparedInlineMessage`` object.
    @discardableResult
    func savePreparedInlineMessage(
        userId: Swift.Int64,
        result: InlineQueryResult,
        allowUserChats: Swift.Bool? = nil,
        allowBotChats: Swift.Bool? = nil,
        allowGroupChats: Swift.Bool? = nil,
        allowChannelChats: Swift.Bool? = nil
    ) async throws -> PreparedInlineMessage {
        var request = TelegramRequest("savePreparedInlineMessage")
        request.set("user_id", userId)
        request.set("result", result)
        request.set("allow_user_chats", allowUserChats)
        request.set("allow_bot_chats", allowBotChats)
        request.set("allow_group_chats", allowGroupChats)
        request.set("allow_channel_chats", allowChannelChats)
        return try await self.perform(request)
    }

    /// Use this method to send answers to an inline query. On success, *True* is returned. No
    /// more than **50** results per query are allowed.
    @discardableResult
    func answerInlineQuery(
        inlineQueryId: Swift.String,
        results: [InlineQueryResult],
        cacheTime: Swift.Int64? = nil,
        isPersonal: Swift.Bool? = nil,
        nextOffset: Swift.String? = nil,
        button: InlineQueryResultsButton? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("answerInlineQuery")
        request.set("inline_query_id", inlineQueryId)
        request.set("results", results)
        request.set("cache_time", cacheTime)
        request.set("is_personal", isPersonal)
        request.set("next_offset", nextOffset)
        request.set("button", button)
        return try await self.perform(request)
    }
}
