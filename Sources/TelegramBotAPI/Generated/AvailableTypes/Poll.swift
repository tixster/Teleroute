// Generated from the Telegram Bot API documentation by Tooling/BotAPIGen.
// Bot API 10.3 (August 24, 2026).
//
// Do not edit by hand: re-run Scripts/generate-api.sh instead.

/// This object contains information about a poll.
public struct Poll: Codable, Hashable, Sendable {
    /// Unique poll identifier
    public var id: Swift.String

    /// Poll question, 1-300 characters
    public var question: Swift.String

    /// *Optional*. Special entities that appear in the *question*. Currently, only custom emoji
    /// entities are allowed in poll questions
    public var questionEntities: [MessageEntity]?

    /// List of poll options
    public var options: [PollOption]

    /// Total number of users that voted in the poll
    public var totalVoterCount: Swift.Int64

    /// *True*, if the poll is closed
    public var isClosed: Swift.Bool

    /// *True*, if the poll is anonymous
    public var isAnonymous: Swift.Bool

    /// Poll type, currently can be “regular” or “quiz”
    public var type: PollType

    /// *True*, if the poll allows multiple answers
    public var allowsMultipleAnswers: Swift.Bool

    /// *True*, if the poll allows to change the chosen answer options
    public var allowsRevoting: Swift.Bool

    /// *True* if voting is limited to users who have been members of the chat where the poll
    /// was originally sent for more than 24 hours
    public var membersOnly: Swift.Bool

    /// *Optional*. A list of two-letter [ISO 3166-1
    /// alpha-2](https://en.wikipedia.org/wiki/ISO_3166-1_alpha-2) country codes indicating the
    /// countries from which users can vote in the poll. The country code “FT” is used for users
    /// with anonymous numbers. If omitted, then users from any country can participate in the
    /// poll.
    public var countryCodes: [Swift.String]?

    /// *Optional*. Array of 0-based identifiers of the correct answer options. Available only
    /// for polls in quiz mode which are closed or were sent (not forwarded) by the bot or to
    /// the private chat with the bot.
    public var correctOptionIds: [Swift.Int64]?

    /// *Optional*. Text that is shown when a user chooses an incorrect answer or taps on the
    /// lamp icon in a quiz-style poll, 0-200 characters
    public var explanation: Swift.String?

    /// *Optional*. Special entities like usernames, URLs, bot commands, etc. that appear in the
    /// *explanation*
    public var explanationEntities: [MessageEntity]?

    private var explanationMediaBox: _IndirectBox<PollMedia>?
    /// *Optional*. Media added to the quiz explanation
    public var explanationMedia: PollMedia? {
        get { self.explanationMediaBox?.value }
        set { self.explanationMediaBox = newValue.map(_IndirectBox.init) }
    }

    /// *Optional*. Amount of time in seconds the poll will be active after creation
    public var openPeriod: Swift.Int64?

    /// *Optional*. Point in time (Unix timestamp) when the poll will be automatically closed
    public var closeDate: Swift.Int64?

    /// *Optional*. Description of the poll; for polls inside the ``Message`` object only
    public var description: Swift.String?

    /// *Optional*. Special entities like usernames, URLs, bot commands, etc. that appear in the
    /// description
    public var descriptionEntities: [MessageEntity]?

    private var mediaBox: _IndirectBox<PollMedia>?
    /// *Optional*. Media added to the poll description; for polls inside the ``Message`` object
    /// only
    public var media: PollMedia? {
        get { self.mediaBox?.value }
        set { self.mediaBox = newValue.map(_IndirectBox.init) }
    }

    public init(
        id: Swift.String,
        question: Swift.String,
        questionEntities: [MessageEntity]? = nil,
        options: [PollOption],
        totalVoterCount: Swift.Int64,
        isClosed: Swift.Bool,
        isAnonymous: Swift.Bool,
        type: PollType,
        allowsMultipleAnswers: Swift.Bool,
        allowsRevoting: Swift.Bool,
        membersOnly: Swift.Bool,
        countryCodes: [Swift.String]? = nil,
        correctOptionIds: [Swift.Int64]? = nil,
        explanation: Swift.String? = nil,
        explanationEntities: [MessageEntity]? = nil,
        explanationMedia: PollMedia? = nil,
        openPeriod: Swift.Int64? = nil,
        closeDate: Swift.Int64? = nil,
        description: Swift.String? = nil,
        descriptionEntities: [MessageEntity]? = nil,
        media: PollMedia? = nil
    ) {
        self.id = id
        self.question = question
        self.questionEntities = questionEntities
        self.options = options
        self.totalVoterCount = totalVoterCount
        self.isClosed = isClosed
        self.isAnonymous = isAnonymous
        self.type = type
        self.allowsMultipleAnswers = allowsMultipleAnswers
        self.allowsRevoting = allowsRevoting
        self.membersOnly = membersOnly
        self.countryCodes = countryCodes
        self.correctOptionIds = correctOptionIds
        self.explanation = explanation
        self.explanationEntities = explanationEntities
        self.explanationMediaBox = explanationMedia.map(_IndirectBox.init)
        self.openPeriod = openPeriod
        self.closeDate = closeDate
        self.description = description
        self.descriptionEntities = descriptionEntities
        self.mediaBox = media.map(_IndirectBox.init)
    }

    public enum CodingKeys: String, CodingKey {
        case id
        case question
        case questionEntities = "question_entities"
        case options
        case totalVoterCount = "total_voter_count"
        case isClosed = "is_closed"
        case isAnonymous = "is_anonymous"
        case type
        case allowsMultipleAnswers = "allows_multiple_answers"
        case allowsRevoting = "allows_revoting"
        case membersOnly = "members_only"
        case countryCodes = "country_codes"
        case correctOptionIds = "correct_option_ids"
        case explanation
        case explanationEntities = "explanation_entities"
        case explanationMediaBox = "explanation_media"
        case openPeriod = "open_period"
        case closeDate = "close_date"
        case description
        case descriptionEntities = "description_entities"
        case mediaBox = "media"
    }
}
