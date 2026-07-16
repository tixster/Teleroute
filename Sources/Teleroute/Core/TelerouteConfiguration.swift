import Foundation

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
    public var metricsSink: any TelerouteMetricsSink
    public var onError: TelerouteErrorHandler?
    /// Whether ``TelerouteBot/start()`` publishes all registered
    /// command menus before starting the bot connection.
    public var syncPublishedCommandsOnStart: Bool

    public init(
        flowStorage: any TelerouteFlowStorage = TelerouteInMemoryFlowStorage(),
        replayProtectionStorage: (any TelerouteReplayProtectionStorage)? = TelerouteInMemoryReplayProtectionStorage(),
        replayProtectionTTL: Duration = .seconds(2),
        maximumConcurrentUpdates: Int = 64,
        flowCancellationPolicy: TelerouteFlowCancellationPolicy = .cancelOnAnyUnmatchedCommand,
        metricsSink: any TelerouteMetricsSink = TelerouteNoOpMetricsSink(),
        onError: TelerouteErrorHandler? = nil,
        syncPublishedCommandsOnStart: Bool = false
    ) {
        self.flowStorage = flowStorage
        self.replayProtectionStorage = replayProtectionStorage
        self.replayProtectionTTL = replayProtectionTTL
        self.maximumConcurrentUpdates = maximumConcurrentUpdates
        self.flowCancellationPolicy = flowCancellationPolicy
        self.metricsSink = metricsSink
        self.onError = onError
        self.syncPublishedCommandsOnStart = syncPublishedCommandsOnStart
    }
}
