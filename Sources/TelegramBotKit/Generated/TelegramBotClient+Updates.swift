// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

import Foundation
import TelegramBotAPI

public extension TelegramBotClient {
    /// Use this method to receive incoming updates using long polling
    /// ([wiki](https://en.wikipedia.org/wiki/Push_technology#Long_polling)). Returns an Array
    /// of ``Update`` objects.
    @discardableResult
    func getUpdates(
        offset: Swift.Int64? = nil,
        limit: Swift.Int64? = nil,
        timeout: Swift.Int64? = nil,
        allowedUpdates: [Swift.String]? = nil
    ) async throws -> [Update] {
        var request = TelegramRequest("getUpdates")
        request.set("offset", offset)
        request.set("limit", limit)
        request.set("timeout", timeout)
        request.set("allowed_updates", allowedUpdates)
        return try await self.perform(request)
    }

    /// Use this method to specify a URL and receive incoming updates via an outgoing webhook.
    /// Whenever there is an update for the bot, we will send an HTTPS POST request to the
    /// specified URL, containing a JSON-serialized ``Update``. In case of an unsuccessful
    /// request (a request with response [HTTP status
    /// code](https://en.wikipedia.org/wiki/List_of_HTTP_status_codes) different from `2XY`), we
    /// will repeat the request and give up after a reasonable amount of attempts. Returns
    /// *True* on success. If you'd like to make sure that the webhook was set by you, you can
    /// specify secret data in the parameter *secret_token*. If specified, the request will
    /// contain a header “X-Telegram-Bot-Api-Secret-Token” with the secret token as content.
    @discardableResult
    func setWebhook(
        url: Swift.String,
        certificate: FileInput? = nil,
        ipAddress: Swift.String? = nil,
        maxConnections: Swift.Int64? = nil,
        allowedUpdates: [Swift.String]? = nil,
        dropPendingUpdates: Swift.Bool? = nil,
        secretToken: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setWebhook")
        request.set("url", url)
        request.set("certificate", certificate)
        request.set("ip_address", ipAddress)
        request.set("max_connections", maxConnections)
        request.set("allowed_updates", allowedUpdates)
        request.set("drop_pending_updates", dropPendingUpdates)
        request.set("secret_token", secretToken)
        return try await self.perform(request)
    }

    /// Use this method to remove webhook integration if you decide to switch back to
    /// `getUpdates`. Returns *True* on success.
    @discardableResult
    func deleteWebhook(
        dropPendingUpdates: Swift.Bool? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("deleteWebhook")
        request.set("drop_pending_updates", dropPendingUpdates)
        return try await self.perform(request)
    }

    /// Use this method to get current webhook status. Requires no parameters. On success,
    /// returns a ``WebhookInfo`` object. If the bot is using `getUpdates`, will return an
    /// object with the *url* field empty.
    @discardableResult
    func getWebhookInfo() async throws -> WebhookInfo {
        let request = TelegramRequest("getWebhookInfo")
        return try await self.perform(request)
    }

    /// A simple method for testing your bot's authentication token. Requires no parameters.
    /// Returns basic information about the bot in form of a ``User`` object.
    @discardableResult
    func getMe() async throws -> User {
        let request = TelegramRequest("getMe")
        return try await self.perform(request)
    }

    /// Use this method to log out from the cloud Bot API server before launching the bot
    /// locally. You **must** log out the bot before running it locally, otherwise there is no
    /// guarantee that the bot will receive updates. After a successful call, you can
    /// immediately log in on a local server, but will not be able to log in back to the cloud
    /// Bot API server for 10 minutes. Returns *True* on success. Requires no parameters.
    @discardableResult
    func logOut() async throws -> Swift.Bool {
        let request = TelegramRequest("logOut")
        return try await self.perform(request)
    }

    /// Use this method to close the bot instance before moving it from one local server to
    /// another. You need to delete the webhook before calling this method to ensure that the
    /// bot isn't launched again after server restart. The method will return error 429 in the
    /// first 10 minutes after the bot is launched. Returns *True* on success. Requires no
    /// parameters.
    @discardableResult
    func close() async throws -> Swift.Bool {
        let request = TelegramRequest("close")
        return try await self.perform(request)
    }
}
