// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// Represents the `content` of an invoice message to be sent as the result of an inline query.
public struct InputInvoiceMessageContent: Codable, Hashable, Sendable {
    /// Product name, 1-32 characters
    public var title: Swift.String

    /// Product description, 1-255 characters
    public var description: Swift.String

    /// Bot-defined invoice payload, 1-128 bytes. This will not be displayed to the user, use it
    /// for your internal processes.
    public var payload: Swift.String

    /// *Optional*. Payment provider token, obtained via [@BotFather](https://t.me/botfather).
    /// Pass an empty string for payments in [Telegram Stars](https://t.me/BotNews/90).
    public var providerToken: Swift.String?

    /// Three-letter ISO 4217 currency code, see more on currencies. Pass “XTR” for payments in
    /// [Telegram Stars](https://t.me/BotNews/90).
    public var currency: Swift.String

    /// Price breakdown, a JSON-serialized list of components (e.g. product price, tax,
    /// discount, delivery cost, delivery tax, bonus, etc.). Must contain exactly one item for
    /// payments in [Telegram Stars](https://t.me/BotNews/90).
    public var prices: [LabeledPrice]

    /// *Optional*. The maximum accepted amount for tips in the *smallest units* of the currency
    /// (integer, **not** float/double). For example, for a maximum tip of `US$ 1.45` pass
    /// `max_tip_amount = 145`. See the *exp* parameter in currencies.json, it shows the number
    /// of digits past the decimal point for each currency (2 for the majority of currencies).
    /// Defaults to 0. Not supported for payments in [Telegram Stars](https://t.me/BotNews/90).
    public var maxTipAmount: Swift.Int64?

    /// *Optional*. A JSON-serialized Array of suggested amounts of tip in the *smallest units*
    /// of the currency (integer, **not** float/double). At most 4 suggested tip amounts can be
    /// specified. The suggested tip amounts must be positive, passed in a strictly increased
    /// order and must not exceed *max_tip_amount*.
    public var suggestedTipAmounts: [Swift.Int64]?

    /// *Optional*. A JSON-serialized object for data about the invoice, which will be shared
    /// with the payment provider. A detailed description of the required fields should be
    /// provided by the payment provider.
    public var providerData: Swift.String?

    /// *Optional*. URL of the product photo for the invoice. Can be a photo of the goods or a
    /// marketing image for a service.
    public var photoUrl: Swift.String?

    /// *Optional*. Photo size in bytes
    public var photoSize: Swift.Int64?

    /// *Optional*. Photo width
    public var photoWidth: Swift.Int64?

    /// *Optional*. Photo height
    public var photoHeight: Swift.Int64?

    /// *Optional*. Pass *True* if you require the user's full name to complete the order.
    /// Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).
    public var needName: Swift.Bool?

    /// *Optional*. Pass *True* if you require the user's phone number to complete the order.
    /// Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).
    public var needPhoneNumber: Swift.Bool?

    /// *Optional*. Pass *True* if you require the user's email address to complete the order.
    /// Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).
    public var needEmail: Swift.Bool?

    /// *Optional*. Pass *True* if you require the user's shipping address to complete the
    /// order. Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).
    public var needShippingAddress: Swift.Bool?

    /// *Optional*. Pass *True* if the user's phone number should be sent to the provider.
    /// Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).
    public var sendPhoneNumberToProvider: Swift.Bool?

    /// *Optional*. Pass *True* if the user's email address should be sent to the provider.
    /// Ignored for payments in [Telegram Stars](https://t.me/BotNews/90).
    public var sendEmailToProvider: Swift.Bool?

    /// *Optional*. Pass *True* if the final price depends on the shipping method. Ignored for
    /// payments in [Telegram Stars](https://t.me/BotNews/90).
    public var isFlexible: Swift.Bool?

    public init(
        title: Swift.String,
        description: Swift.String,
        payload: Swift.String,
        providerToken: Swift.String? = nil,
        currency: Swift.String,
        prices: [LabeledPrice],
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
    ) {
        self.title = title
        self.description = description
        self.payload = payload
        self.providerToken = providerToken
        self.currency = currency
        self.prices = prices
        self.maxTipAmount = maxTipAmount
        self.suggestedTipAmounts = suggestedTipAmounts
        self.providerData = providerData
        self.photoUrl = photoUrl
        self.photoSize = photoSize
        self.photoWidth = photoWidth
        self.photoHeight = photoHeight
        self.needName = needName
        self.needPhoneNumber = needPhoneNumber
        self.needEmail = needEmail
        self.needShippingAddress = needShippingAddress
        self.sendPhoneNumberToProvider = sendPhoneNumberToProvider
        self.sendEmailToProvider = sendEmailToProvider
        self.isFlexible = isFlexible
    }

    public enum CodingKeys: String, CodingKey {
        case title
        case description
        case payload
        case providerToken = "provider_token"
        case currency
        case prices
        case maxTipAmount = "max_tip_amount"
        case suggestedTipAmounts = "suggested_tip_amounts"
        case providerData = "provider_data"
        case photoUrl = "photo_url"
        case photoSize = "photo_size"
        case photoWidth = "photo_width"
        case photoHeight = "photo_height"
        case needName = "need_name"
        case needPhoneNumber = "need_phone_number"
        case needEmail = "need_email"
        case needShippingAddress = "need_shipping_address"
        case sendPhoneNumberToProvider = "send_phone_number_to_provider"
        case sendEmailToProvider = "send_email_to_provider"
        case isFlexible = "is_flexible"
    }
}
