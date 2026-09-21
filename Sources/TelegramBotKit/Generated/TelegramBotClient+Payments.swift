// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

import Foundation
import TelegramBotAPI

public extension TelegramBotClient {
    /// Use this method to send paid media. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendPaidMedia(
        chatId: ChatId,
        starCount: Swift.Int64,
        media: [InputPaidMedia],
        businessConnectionId: Swift.String? = nil,
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        payload: Swift.String? = nil,
        caption: Swift.String? = nil,
        parseMode: ParseMode? = nil,
        captionEntities: [MessageEntity]? = nil,
        showCaptionAboveMedia: Swift.Bool? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: ReplyMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendPaidMedia")
        request.set("business_connection_id", businessConnectionId)
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("star_count", starCount)
        request.set("media", media)
        request.set("payload", payload)
        request.set("caption", caption)
        request.set("parse_mode", parseMode?.rawValue)
        request.set("caption_entities", captionEntities)
        request.set("show_caption_above_media", showCaptionAboveMedia)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to create a [subscription invite
    /// link](https://telegram.org/blog/superchannels-star-reactions-subscriptions#star-subscriptions)
    /// for a channel chat. The bot must have the *can_invite_users* administrator rights. The
    /// link can be edited using the method `editChatSubscriptionInviteLink` or revoked using
    /// the method `revokeChatInviteLink`. Returns the new invite link as a ``ChatInviteLink``
    /// object.
    @discardableResult
    func createChatSubscriptionInviteLink(
        chatId: ChatId,
        subscriptionPeriod: Swift.Int64,
        subscriptionPrice: Swift.Int64,
        name: Swift.String? = nil
    ) async throws -> ChatInviteLink {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("createChatSubscriptionInviteLink")
        request.set("chat_id", chatId)
        request.set("name", name)
        request.set("subscription_period", subscriptionPeriod)
        request.set("subscription_price", subscriptionPrice)
        return try await self.perform(request)
    }

    /// Use this method to edit a subscription invite link created by the bot. The bot must have
    /// the *can_invite_users* administrator rights. Returns the edited invite link as a
    /// ``ChatInviteLink`` object.
    @discardableResult
    func editChatSubscriptionInviteLink(
        chatId: ChatId,
        inviteLink: Swift.String,
        name: Swift.String? = nil
    ) async throws -> ChatInviteLink {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("editChatSubscriptionInviteLink")
        request.set("chat_id", chatId)
        request.set("invite_link", inviteLink)
        request.set("name", name)
        return try await self.perform(request)
    }

    /// Returns the list of gifts that can be sent by the bot to users and channel chats.
    /// Requires no parameters. Returns a ``Gifts`` object.
    @discardableResult
    func getAvailableGifts() async throws -> Gifts {
        let request = TelegramRequest("getAvailableGifts")
        return try await self.perform(request)
    }

    /// Sends a gift to the given user or channel chat. The gift can't be converted to Telegram
    /// Stars by the receiver. Returns *True* on success.
    @discardableResult
    func sendGift(
        giftId: Swift.String,
        userId: Swift.Int64? = nil,
        chatId: ChatId? = nil,
        payForUpgrade: Swift.Bool? = nil,
        text: Swift.String? = nil,
        textParseMode: Swift.String? = nil,
        textEntities: [MessageEntity]? = nil
    ) async throws -> Swift.Bool {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendGift")
        request.set("user_id", userId)
        request.set("chat_id", chatId)
        request.set("gift_id", giftId)
        request.set("pay_for_upgrade", payForUpgrade)
        request.set("text", text)
        request.set("text_parse_mode", textParseMode)
        request.set("text_entities", textEntities)
        return try await self.perform(request)
    }

    /// Gifts a Telegram Premium subscription to the given user. Returns *True* on success.
    @discardableResult
    func giftPremiumSubscription(
        userId: Swift.Int64,
        monthCount: Swift.Int64,
        starCount: Swift.Int64,
        text: Swift.String? = nil,
        textParseMode: Swift.String? = nil,
        textEntities: [MessageEntity]? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("giftPremiumSubscription")
        request.set("user_id", userId)
        request.set("month_count", monthCount)
        request.set("star_count", starCount)
        request.set("text", text)
        request.set("text_parse_mode", textParseMode)
        request.set("text_entities", textEntities)
        return try await self.perform(request)
    }

    /// Changes the privacy settings pertaining to incoming gifts in a managed business account.
    /// Requires the *can_change_gift_settings* business bot right. Returns *True* on success.
    @discardableResult
    func setBusinessAccountGiftSettings(
        businessConnectionId: Swift.String,
        showGiftButton: Swift.Bool,
        acceptedGiftTypes: AcceptedGiftTypes
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("setBusinessAccountGiftSettings")
        request.set("business_connection_id", businessConnectionId)
        request.set("show_gift_button", showGiftButton)
        request.set("accepted_gift_types", acceptedGiftTypes)
        return try await self.perform(request)
    }

    /// Returns the amount of Telegram Stars owned by a managed business account. Requires the
    /// *can_view_gifts_and_stars* business bot right. Returns ``StarAmount`` on success.
    @discardableResult
    func getBusinessAccountStarBalance(
        businessConnectionId: Swift.String
    ) async throws -> StarAmount {
        var request = TelegramRequest("getBusinessAccountStarBalance")
        request.set("business_connection_id", businessConnectionId)
        return try await self.perform(request)
    }

    /// Transfers Telegram Stars from the business account balance to the bot's balance.
    /// Requires the *can_transfer_stars* business bot right. Returns *True* on success.
    @discardableResult
    func transferBusinessAccountStars(
        businessConnectionId: Swift.String,
        starCount: Swift.Int64
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("transferBusinessAccountStars")
        request.set("business_connection_id", businessConnectionId)
        request.set("star_count", starCount)
        return try await self.perform(request)
    }

    /// Returns the gifts received and owned by a managed business account. Requires the
    /// *can_view_gifts_and_stars* business bot right. Returns ``OwnedGifts`` on success.
    @discardableResult
    func getBusinessAccountGifts(
        businessConnectionId: Swift.String,
        excludeUnsaved: Swift.Bool? = nil,
        excludeSaved: Swift.Bool? = nil,
        excludeUnlimited: Swift.Bool? = nil,
        excludeLimitedUpgradable: Swift.Bool? = nil,
        excludeLimitedNonUpgradable: Swift.Bool? = nil,
        excludeUnique: Swift.Bool? = nil,
        excludeFromBlockchain: Swift.Bool? = nil,
        sortByPrice: Swift.Bool? = nil,
        offset: Swift.String? = nil,
        limit: Swift.Int64? = nil
    ) async throws -> OwnedGifts {
        var request = TelegramRequest("getBusinessAccountGifts")
        request.set("business_connection_id", businessConnectionId)
        request.set("exclude_unsaved", excludeUnsaved)
        request.set("exclude_saved", excludeSaved)
        request.set("exclude_unlimited", excludeUnlimited)
        request.set("exclude_limited_upgradable", excludeLimitedUpgradable)
        request.set("exclude_limited_non_upgradable", excludeLimitedNonUpgradable)
        request.set("exclude_unique", excludeUnique)
        request.set("exclude_from_blockchain", excludeFromBlockchain)
        request.set("sort_by_price", sortByPrice)
        request.set("offset", offset)
        request.set("limit", limit)
        return try await self.perform(request)
    }

    /// Returns the gifts owned and hosted by a user. Returns ``OwnedGifts`` on success.
    @discardableResult
    func getUserGifts(
        userId: Swift.Int64,
        excludeUnlimited: Swift.Bool? = nil,
        excludeLimitedUpgradable: Swift.Bool? = nil,
        excludeLimitedNonUpgradable: Swift.Bool? = nil,
        excludeFromBlockchain: Swift.Bool? = nil,
        excludeUnique: Swift.Bool? = nil,
        sortByPrice: Swift.Bool? = nil,
        offset: Swift.String? = nil,
        limit: Swift.Int64? = nil
    ) async throws -> OwnedGifts {
        var request = TelegramRequest("getUserGifts")
        request.set("user_id", userId)
        request.set("exclude_unlimited", excludeUnlimited)
        request.set("exclude_limited_upgradable", excludeLimitedUpgradable)
        request.set("exclude_limited_non_upgradable", excludeLimitedNonUpgradable)
        request.set("exclude_from_blockchain", excludeFromBlockchain)
        request.set("exclude_unique", excludeUnique)
        request.set("sort_by_price", sortByPrice)
        request.set("offset", offset)
        request.set("limit", limit)
        return try await self.perform(request)
    }

    /// Returns the gifts owned by a chat. Returns ``OwnedGifts`` on success.
    @discardableResult
    func getChatGifts(
        chatId: ChatId,
        excludeUnsaved: Swift.Bool? = nil,
        excludeSaved: Swift.Bool? = nil,
        excludeUnlimited: Swift.Bool? = nil,
        excludeLimitedUpgradable: Swift.Bool? = nil,
        excludeLimitedNonUpgradable: Swift.Bool? = nil,
        excludeFromBlockchain: Swift.Bool? = nil,
        excludeUnique: Swift.Bool? = nil,
        sortByPrice: Swift.Bool? = nil,
        offset: Swift.String? = nil,
        limit: Swift.Int64? = nil
    ) async throws -> OwnedGifts {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("getChatGifts")
        request.set("chat_id", chatId)
        request.set("exclude_unsaved", excludeUnsaved)
        request.set("exclude_saved", excludeSaved)
        request.set("exclude_unlimited", excludeUnlimited)
        request.set("exclude_limited_upgradable", excludeLimitedUpgradable)
        request.set("exclude_limited_non_upgradable", excludeLimitedNonUpgradable)
        request.set("exclude_from_blockchain", excludeFromBlockchain)
        request.set("exclude_unique", excludeUnique)
        request.set("sort_by_price", sortByPrice)
        request.set("offset", offset)
        request.set("limit", limit)
        return try await self.perform(request)
    }

    /// Converts a given regular gift to Telegram Stars. Requires the
    /// *can_convert_gifts_to_stars* business bot right. Returns *True* on success.
    @discardableResult
    func convertGiftToStars(
        businessConnectionId: Swift.String,
        ownedGiftId: Swift.String
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("convertGiftToStars")
        request.set("business_connection_id", businessConnectionId)
        request.set("owned_gift_id", ownedGiftId)
        return try await self.perform(request)
    }

    /// Upgrades a given regular gift to a unique gift. Requires the
    /// *can_transfer_and_upgrade_gifts* business bot right. Additionally requires the
    /// *can_transfer_stars* business bot right if the upgrade is paid. Returns *True* on
    /// success.
    @discardableResult
    func upgradeGift(
        businessConnectionId: Swift.String,
        ownedGiftId: Swift.String,
        keepOriginalDetails: Swift.Bool? = nil,
        starCount: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("upgradeGift")
        request.set("business_connection_id", businessConnectionId)
        request.set("owned_gift_id", ownedGiftId)
        request.set("keep_original_details", keepOriginalDetails)
        request.set("star_count", starCount)
        return try await self.perform(request)
    }

    /// Transfers an owned unique gift to another user. Requires the
    /// *can_transfer_and_upgrade_gifts* business bot right. Requires *can_transfer_stars*
    /// business bot right if the transfer is paid. Returns *True* on success.
    @discardableResult
    func transferGift(
        businessConnectionId: Swift.String,
        ownedGiftId: Swift.String,
        newOwnerChatId: Swift.Int64,
        starCount: Swift.Int64? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("transferGift")
        request.set("business_connection_id", businessConnectionId)
        request.set("owned_gift_id", ownedGiftId)
        request.set("new_owner_chat_id", newOwnerChatId)
        request.set("star_count", starCount)
        return try await self.perform(request)
    }

    /// Use this method to send invoices. On success, the sent ``Message`` is returned.
    @discardableResult
    func sendInvoice(
        chatId: ChatId,
        title: Swift.String,
        description: Swift.String,
        payload: Swift.String,
        currency: Swift.String,
        prices: [LabeledPrice],
        messageThreadId: Swift.Int64? = nil,
        directMessagesTopicId: Swift.Int64? = nil,
        providerToken: Swift.String? = nil,
        maxTipAmount: Swift.Int64? = nil,
        suggestedTipAmounts: [Swift.Int64]? = nil,
        startParameter: Swift.String? = nil,
        providerData: Swift.String? = nil,
        photoUrl: Swift.String? = nil,
        photoSize: Swift.Int64? = nil,
        photoWidth: Swift.Int64? = nil,
        photoHeight: Swift.Int64? = nil,
        needName: Swift.Bool? = nil,
        needPhoneNumber: Swift.Bool? = nil,
        needEmail: Swift.Bool? = nil,
        needShippingAddress: Swift.Bool? = nil,
        sendPhoneNumberToProvider: Swift.Bool? = nil,
        sendEmailToProvider: Swift.Bool? = nil,
        isFlexible: Swift.Bool? = nil,
        disableNotification: Swift.Bool? = nil,
        protectContent: Swift.Bool? = nil,
        allowPaidBroadcast: Swift.Bool? = nil,
        messageEffectId: Swift.String? = nil,
        suggestedPostParameters: SuggestedPostParameters? = nil,
        replyParameters: ReplyParameters? = nil,
        replyMarkup: InlineKeyboardMarkup? = nil
    ) async throws -> Message {
        try await self.pace(chatId: chatId)
        var request = TelegramRequest("sendInvoice")
        request.set("chat_id", chatId)
        request.set("message_thread_id", messageThreadId)
        request.set("direct_messages_topic_id", directMessagesTopicId)
        request.set("title", title)
        request.set("description", description)
        request.set("payload", payload)
        request.set("provider_token", providerToken)
        request.set("currency", currency)
        request.set("prices", prices)
        request.set("max_tip_amount", maxTipAmount)
        request.set("suggested_tip_amounts", suggestedTipAmounts)
        request.set("start_parameter", startParameter)
        request.set("provider_data", providerData)
        request.set("photo_url", photoUrl)
        request.set("photo_size", photoSize)
        request.set("photo_width", photoWidth)
        request.set("photo_height", photoHeight)
        request.set("need_name", needName)
        request.set("need_phone_number", needPhoneNumber)
        request.set("need_email", needEmail)
        request.set("need_shipping_address", needShippingAddress)
        request.set("send_phone_number_to_provider", sendPhoneNumberToProvider)
        request.set("send_email_to_provider", sendEmailToProvider)
        request.set("is_flexible", isFlexible)
        request.set("disable_notification", disableNotification)
        request.set("protect_content", protectContent)
        request.set("allow_paid_broadcast", allowPaidBroadcast)
        request.set("message_effect_id", messageEffectId)
        request.set("suggested_post_parameters", suggestedPostParameters)
        request.set("reply_parameters", replyParameters)
        request.set("reply_markup", replyMarkup)
        return try await self.perform(request)
    }

    /// Use this method to create a link for an invoice. Returns the created invoice link as
    /// *String* on success.
    @discardableResult
    func createInvoiceLink(
        title: Swift.String,
        description: Swift.String,
        payload: Swift.String,
        currency: Swift.String,
        prices: [LabeledPrice],
        businessConnectionId: Swift.String? = nil,
        providerToken: Swift.String? = nil,
        subscriptionPeriod: Swift.Int64? = nil,
        maxTipAmount: Swift.Int64? = nil,
        suggestedTipAmounts: [Swift.Int64]? = nil,
        providerData: Swift.String? = nil,
        photoUrl: Swift.String? = nil,
        photoSize: Swift.Int64? = nil,
        photoWidth: Swift.Int64? = nil,
        photoHeight: Swift.Int64? = nil,
        needName: Swift.Bool? = nil,
        needPhoneNumber: Swift.Bool? = nil,
        needEmail: Swift.Bool? = nil,
        needShippingAddress: Swift.Bool? = nil,
        sendPhoneNumberToProvider: Swift.Bool? = nil,
        sendEmailToProvider: Swift.Bool? = nil,
        isFlexible: Swift.Bool? = nil
    ) async throws -> Swift.String {
        var request = TelegramRequest("createInvoiceLink")
        request.set("business_connection_id", businessConnectionId)
        request.set("title", title)
        request.set("description", description)
        request.set("payload", payload)
        request.set("provider_token", providerToken)
        request.set("currency", currency)
        request.set("prices", prices)
        request.set("subscription_period", subscriptionPeriod)
        request.set("max_tip_amount", maxTipAmount)
        request.set("suggested_tip_amounts", suggestedTipAmounts)
        request.set("provider_data", providerData)
        request.set("photo_url", photoUrl)
        request.set("photo_size", photoSize)
        request.set("photo_width", photoWidth)
        request.set("photo_height", photoHeight)
        request.set("need_name", needName)
        request.set("need_phone_number", needPhoneNumber)
        request.set("need_email", needEmail)
        request.set("need_shipping_address", needShippingAddress)
        request.set("send_phone_number_to_provider", sendPhoneNumberToProvider)
        request.set("send_email_to_provider", sendEmailToProvider)
        request.set("is_flexible", isFlexible)
        return try await self.perform(request)
    }

    /// If you sent an invoice requesting a shipping address and the parameter *is_flexible* was
    /// specified, the Bot API will send an ``Update`` with a *shipping_query* field to the bot.
    /// Use this method to reply to shipping queries. On success, *True* is returned.
    @discardableResult
    func answerShippingQuery(
        shippingQueryId: Swift.String,
        ok: Swift.Bool,
        shippingOptions: [ShippingOption]? = nil,
        errorMessage: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("answerShippingQuery")
        request.set("shipping_query_id", shippingQueryId)
        request.set("ok", ok)
        request.set("shipping_options", shippingOptions)
        request.set("error_message", errorMessage)
        return try await self.perform(request)
    }

    /// Once the user has confirmed their payment and shipping details, the Bot API sends the
    /// final confirmation in the form of an ``Update`` with the field *pre_checkout_query*. Use
    /// this method to respond to such pre-checkout queries. On success, *True* is returned.
    /// **Note:** The Bot API must receive an answer within 10 seconds after the pre-checkout
    /// query was sent.
    @discardableResult
    func answerPreCheckoutQuery(
        preCheckoutQueryId: Swift.String,
        ok: Swift.Bool,
        errorMessage: Swift.String? = nil
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("answerPreCheckoutQuery")
        request.set("pre_checkout_query_id", preCheckoutQueryId)
        request.set("ok", ok)
        request.set("error_message", errorMessage)
        return try await self.perform(request)
    }

    /// A method to get the current Telegram Stars balance of the bot. Requires no parameters.
    /// On success, returns a ``StarAmount`` object.
    @discardableResult
    func getMyStarBalance() async throws -> StarAmount {
        let request = TelegramRequest("getMyStarBalance")
        return try await self.perform(request)
    }

    /// Returns the bot's Telegram Star transactions in chronological order. On success, returns
    /// a ``StarTransactions`` object.
    @discardableResult
    func getStarTransactions(
        offset: Swift.Int64? = nil,
        limit: Swift.Int64? = nil
    ) async throws -> StarTransactions {
        var request = TelegramRequest("getStarTransactions")
        request.set("offset", offset)
        request.set("limit", limit)
        return try await self.perform(request)
    }

    /// Refunds a successful payment in [Telegram Stars](https://t.me/BotNews/90). Returns
    /// *True* on success.
    @discardableResult
    func refundStarPayment(
        userId: Swift.Int64,
        telegramPaymentChargeId: Swift.String
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("refundStarPayment")
        request.set("user_id", userId)
        request.set("telegram_payment_charge_id", telegramPaymentChargeId)
        return try await self.perform(request)
    }

    /// Allows the bot to cancel or re-enable extension of a subscription paid in Telegram
    /// Stars. Returns *True* on success.
    @discardableResult
    func editUserStarSubscription(
        userId: Swift.Int64,
        telegramPaymentChargeId: Swift.String,
        isCanceled: Swift.Bool
    ) async throws -> Swift.Bool {
        var request = TelegramRequest("editUserStarSubscription")
        request.set("user_id", userId)
        request.set("telegram_payment_charge_id", telegramPaymentChargeId)
        request.set("is_canceled", isCanceled)
        return try await self.perform(request)
    }
}
