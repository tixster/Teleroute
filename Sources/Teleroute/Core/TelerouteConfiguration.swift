import Foundation

/// Converts an unhandled route error into a user-facing response.
/// Return `nil` to leave the user without a visible reaction.
public typealias TelerouteErrorRenderer = @Sendable (
    any Error,
    TelerouteContext
) async -> TelerouteResponse?

/// Advanced dependencies and processing policies shared by a
/// ``TelerouteBot`` and its internal update runtime.
public struct TelerouteConfiguration: Sendable {
    public var flowStorage: any TelerouteFlowStorage
    public var replayProtectionStorage: (any TelerouteReplayProtectionStorage)?
    public var replayProtectionTTL: Duration
    /// Maximum number of update handlers allowed to execute concurrently. Must
    /// be positive.
    public var maximumConcurrentUpdates: Int
    public var flowCancellationPolicy: TelerouteFlowCancellationPolicy
    /// How long a flow session survives without activity.
    ///
    /// `nil` (the default) keeps sessions alive until a handler ends them,
    /// which means an abandoned conversation captures its chat indefinitely.
    /// Setting a TTL makes an idle session expire: the next update falls
    /// through to normal routing and the session is dropped. Every write to a
    /// session — start, transition, update, restart — refreshes the deadline.
    public var flowSessionTTL: Duration?
    public var metricsSink: any TelerouteMetricsSink
    public var onError: TelerouteErrorHandler?
    /// Whether ``TelerouteBot/start()`` publishes all registered
    /// command menus before starting the bot connection.
    public var syncPublishedCommandsOnStart: Bool
    /// Long-polling behavior used by ``TelerouteBot/start()``.
    public var polling: TelegramPollingConfiguration
    /// Parse mode applied by text helpers and string responses when no
    /// explicit mode is passed.
    public var defaultParseMode: ParseMode?
    /// Automatically answers handled callback queries that no handler
    /// answered, so inline buttons never keep spinning.
    public var autoAnswerCallbackQueries: Bool
    /// Converts unhandled route errors into user-facing responses before the
    /// failure is reported to events, metrics, and ``onError``.
    public var errorRenderer: TelerouteErrorRenderer?
    /// How long a graceful shutdown waits for in-flight handlers to finish
    /// before cancelling them.
    public var shutdownGracePeriod: Duration
    /// Whether buttons may carry inline handlers, and how long those handlers
    /// stay pressable. Disabled by default: enabling it registers a callback
    /// route, which in turn puts `callback_query` in `allowed_updates`.
    public var inlineActions: TelerouteInlineActionPolicy

    public init(
        flowStorage: any TelerouteFlowStorage = TelerouteInMemoryFlowStorage(),
        replayProtectionStorage: (any TelerouteReplayProtectionStorage)? = TelerouteInMemoryReplayProtectionStorage(),
        replayProtectionTTL: Duration = .seconds(2),
        maximumConcurrentUpdates: Int = 64,
        flowCancellationPolicy: TelerouteFlowCancellationPolicy = .cancelOnAnyUnmatchedCommand,
        flowSessionTTL: Duration? = nil,
        metricsSink: any TelerouteMetricsSink = TelerouteNoOpMetricsSink(),
        onError: TelerouteErrorHandler? = nil,
        syncPublishedCommandsOnStart: Bool = false,
        polling: TelegramPollingConfiguration = .init(),
        defaultParseMode: ParseMode? = nil,
        autoAnswerCallbackQueries: Bool = true,
        errorRenderer: TelerouteErrorRenderer? = nil,
        shutdownGracePeriod: Duration = .seconds(15),
        inlineActions: TelerouteInlineActionPolicy = .disabled
    ) {
        self.flowStorage = flowStorage
        self.replayProtectionStorage = replayProtectionStorage
        self.replayProtectionTTL = replayProtectionTTL
        self.maximumConcurrentUpdates = maximumConcurrentUpdates
        self.flowCancellationPolicy = flowCancellationPolicy
        self.flowSessionTTL = flowSessionTTL
        self.metricsSink = metricsSink
        self.onError = onError
        self.syncPublishedCommandsOnStart = syncPublishedCommandsOnStart
        self.polling = polling
        self.defaultParseMode = defaultParseMode
        self.autoAnswerCallbackQueries = autoAnswerCallbackQueries
        self.errorRenderer = errorRenderer
        self.shutdownGracePeriod = shutdownGracePeriod
        self.inlineActions = inlineActions
    }
}
