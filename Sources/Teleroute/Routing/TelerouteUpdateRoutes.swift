import Foundation
import TelegramBotAPI

// MARK: - Message content filter

/// Content predicate for plain-message routes.
public struct TelerouteMessageFilter: Sendable {
    let name: String
    let matches: @Sendable (Message) -> Bool

    init(name: String, matches: @escaping @Sendable (Message) -> Bool) {
        self.name = name
        self.matches = matches
    }

    /// Matches every message.
    public static let any = TelerouteMessageFilter(name: "any") { _ in true }
    /// Messages carrying text.
    public static let text = TelerouteMessageFilter(name: "text") { $0.text != nil }
    /// Messages carrying a photo.
    public static let photo = TelerouteMessageFilter(name: "photo") { $0.photo != nil }
    /// Messages carrying a document.
    public static let document = TelerouteMessageFilter(name: "document") { $0.document != nil }
    /// Messages carrying a video.
    public static let video = TelerouteMessageFilter(name: "video") { $0.video != nil }
    /// Messages carrying an audio file.
    public static let audio = TelerouteMessageFilter(name: "audio") { $0.audio != nil }
    /// Messages carrying a voice note.
    public static let voice = TelerouteMessageFilter(name: "voice") { $0.voice != nil }
    /// Messages carrying a video note.
    public static let videoNote = TelerouteMessageFilter(name: "videoNote") { $0.videoNote != nil }
    /// Messages carrying a sticker.
    public static let sticker = TelerouteMessageFilter(name: "sticker") { $0.sticker != nil }
    /// Messages carrying an animation.
    public static let animation = TelerouteMessageFilter(name: "animation") { $0.animation != nil }
    /// Messages carrying a location.
    public static let location = TelerouteMessageFilter(name: "location") { $0.location != nil }
    /// Messages carrying a shared contact.
    public static let contact = TelerouteMessageFilter(name: "contact") { $0.contact != nil }
    /// Messages announcing new chat members.
    public static let newChatMembers = TelerouteMessageFilter(name: "newChatMembers") {
        $0.newChatMembers?.isEmpty == false
    }
    /// Messages carrying a successful payment.
    public static let successfulPayment = TelerouteMessageFilter(name: "successfulPayment") {
        $0.successfulPayment != nil
    }

    /// A custom predicate.
    public static func custom(
        _ name: String = "custom",
        _ matches: @escaping @Sendable (Message) -> Bool
    ) -> TelerouteMessageFilter {
        .init(name: name, matches: matches)
    }
}

// MARK: - SPI registration

@_spi(Testing)
public extension TelerouteRoutes {
    func message(
        from sources: Set<TelerouteMessageSource> = [.message],
        filter: TelerouteMessageFilter = .any,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping TelerouteHandler
    ) {
        let resolved = TelerouteMiddlewareComposer.resolve(
            inheritedMiddlewares: self.inheritedMiddlewares,
            inheritedGuards: self.inheritedGuards,
            guards: guards,
            middlewares: middlewares
        )
        self.storage.appendMessageRoute(
            .init(
                name: "message(\(filter.name))",
                sources: sources,
                filter: filter,
                middlewares: resolved,
                handler: handler
            )
        )
    }

    func on(
        _ kinds: Set<UpdateKind>,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping TelerouteHandler
    ) {
        let resolved = TelerouteMiddlewareComposer.resolve(
            inheritedMiddlewares: self.inheritedMiddlewares,
            inheritedGuards: self.inheritedGuards,
            guards: guards,
            middlewares: middlewares
        )
        self.storage.appendKindRoute(
            .init(
                name: kinds.map(\.rawValue).sorted().joined(separator: "|"),
                kinds: kinds,
                middlewares: resolved,
                handler: handler
            )
        )
    }

    func unmatched(
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping TelerouteHandler
    ) {
        let resolved = TelerouteMiddlewareComposer.resolve(
            inheritedMiddlewares: self.inheritedMiddlewares,
            inheritedGuards: self.inheritedGuards,
            guards: [],
            middlewares: middlewares
        )
        self.storage.appendUnmatchedRoute(
            .init(middlewares: resolved, handler: handler)
        )
    }
}

// MARK: - Group-level registration

public extension TelerouteRouterGroup {
    /// Registers a handler for plain (non-command) messages.
    ///
    /// - Parameters:
    ///   - filter: Content filter, e.g. `.text`, `.photo`, `.custom { ... }`.
    ///   - sources: Which update fields to accept messages from
    ///     (default: fresh direct messages only).
    ///   - guards: Guards evaluated before the handler runs.
    ///   - middlewares: Middleware wrapping this route's handler.
    ///   - handler: Route handler returning any ``TelerouteResponseGenerator``.
    func message<Response: TelerouteResponseGenerator>(
        _ filter: TelerouteMessageFilter = .any,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Response
    ) {
        self.registerMessage(filter: filter, sources: sources, guards: guards, middlewares: middlewares) {
            try await handler($0).makeResponse()
        }
    }

    /// Registers a plain-message handler returning a ``TelerouteResponse``.
    func message(
        _ filter: TelerouteMessageFilter = .any,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) {
        self.registerMessage(
            filter: filter, sources: sources, guards: guards, middlewares: middlewares, handler: handler
        )
    }

    /// Registers a plain-message handler with a side-effect-only body.
    func message(
        _ filter: TelerouteMessageFilter = .any,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Void
    ) {
        self.registerMessage(filter: filter, sources: sources, guards: guards, middlewares: middlewares) {
            try await handler($0)
            return .none
        }
    }

    /// Registers a handler for exact text messages.
    func text<Response: TelerouteResponseGenerator>(
        _ exact: String,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Response
    ) {
        self.message(
            .custom("text(\(exact))") { $0.text == exact },
            from: sources,
            guards: guards,
            middlewares: middlewares,
            use: handler
        )
    }

    /// Registers a handler for text messages starting with a prefix.
    func text<Response: TelerouteResponseGenerator>(
        prefix: String,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Response
    ) {
        self.message(
            .custom("text(prefix: \(prefix))") { $0.text?.hasPrefix(prefix) == true },
            from: sources,
            guards: guards,
            middlewares: middlewares,
            use: handler
        )
    }

    /// Registers a handler for text messages matching a regex.
    func text<Response: TelerouteResponseGenerator>(
        matching regex: Regex<some Any>,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Response
    ) {
        nonisolated(unsafe) let regex = regex
        self.message(
            .custom("text(regex)") { message in
                guard let text = message.text else { return false }
                return (try? regex.firstMatch(in: text)) != nil
            },
            from: sources,
            guards: guards,
            middlewares: middlewares,
            use: handler
        )
    }

    /// Registers a handler for one or more update kinds.
    func on<Response: TelerouteResponseGenerator>(
        _ kinds: UpdateKind...,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Response
    ) {
        self.registerKinds(Set(kinds), guards: guards, middlewares: middlewares) {
            try await handler($0).makeResponse()
        }
    }

    /// Registers a side-effect-only handler for one or more update kinds.
    func on(
        _ kinds: UpdateKind...,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Void
    ) {
        self.registerKinds(Set(kinds), guards: guards, middlewares: middlewares) {
            try await handler($0)
            return .none
        }
    }

    /// Registers the final hook that runs when no route matched an update.
    func unmatched<Response: TelerouteResponseGenerator>(
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Response
    ) {
        self.registerUnmatched(middlewares: middlewares) {
            try await handler($0).makeResponse()
        }
    }

    /// Registers a side-effect-only unmatched hook.
    func unmatched(
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Void
    ) {
        self.registerUnmatched(middlewares: middlewares) {
            try await handler($0)
            return .none
        }
    }
}

// MARK: - Typed payload sugar

public extension TelerouteRouterGroup {
    /// Registers an inline-query handler.
    func inlineQuery<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (InlineQuery, Context) async throws -> Response
    ) {
        self.onPayload(.inlineQuery, \.inlineQuery, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a chosen-inline-result handler.
    func chosenInlineResult<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ChosenInlineResult, Context) async throws -> Response
    ) {
        self.onPayload(.chosenInlineResult, \.chosenInlineResult, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a shipping-query handler (invoice with flexible pricing).
    func shippingQuery<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ShippingQuery, Context) async throws -> Response
    ) {
        self.onPayload(.shippingQuery, \.shippingQuery, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a pre-checkout-query handler. Telegram requires an answer
    /// within 10 seconds.
    func preCheckoutQuery<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (PreCheckoutQuery, Context) async throws -> Response
    ) {
        self.onPayload(.preCheckoutQuery, \.preCheckoutQuery, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a handler for another member's status changes in a chat.
    func chatMember<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ChatMemberUpdated, Context) async throws -> Response
    ) {
        self.onPayload(.chatMember, \.chatMember, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a handler for the bot's own status changes in a chat.
    func myChatMember<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ChatMemberUpdated, Context) async throws -> Response
    ) {
        self.onPayload(.myChatMember, \.myChatMember, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a chat-join-request handler.
    func chatJoinRequest<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ChatJoinRequest, Context) async throws -> Response
    ) {
        self.onPayload(.chatJoinRequest, \.chatJoinRequest, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a message-reaction handler.
    func messageReaction<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (MessageReactionUpdated, Context) async throws -> Response
    ) {
        self.onPayload(.messageReaction, \.messageReaction, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers an anonymous reaction-count handler (channels).
    func messageReactionCount<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (MessageReactionCountUpdated, Context) async throws -> Response
    ) {
        self.onPayload(.messageReactionCount, \.messageReactionCount, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a poll-state handler (polls sent by the bot).
    func poll<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Poll, Context) async throws -> Response
    ) {
        self.onPayload(.poll, \.poll, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a poll-answer handler (non-anonymous polls).
    func pollAnswer<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (PollAnswer, Context) async throws -> Response
    ) {
        self.onPayload(.pollAnswer, \.pollAnswer, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a business-connection handler.
    func businessConnection<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (BusinessConnection, Context) async throws -> Response
    ) {
        self.onPayload(.businessConnection, \.businessConnection, guards: guards, middlewares: middlewares, use: handler)
    }

    /// Registers a purchased-paid-media handler.
    func purchasedPaidMedia<Response: TelerouteResponseGenerator>(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (PaidMediaPurchased, Context) async throws -> Response
    ) {
        self.onPayload(.purchasedPaidMedia, \.purchasedPaidMedia, guards: guards, middlewares: middlewares, use: handler)
    }

    private func onPayload<Payload: Sendable, Response: TelerouteResponseGenerator>(
        _ kind: UpdateKind,
        _ keyPath: any KeyPath<Update, Payload?> & Sendable,
        guards: [any TelerouteGuard],
        middlewares: [any TelerouteMiddleware<TelerouteContext>],
        use handler: @escaping @Sendable (Payload, Context) async throws -> Response
    ) {
        self.registerKinds(Set([kind]), guards: guards, middlewares: middlewares) { context in
            guard let payload = context.update[keyPath: keyPath] else {
                return .unhandled
            }
            return try await handler(payload, context).makeResponse()
        }
    }
}

// MARK: - Context payload accessors

public extension TelerouteContext {
    var inlineQuery: InlineQuery? { self.update.inlineQuery }
    var chosenInlineResult: ChosenInlineResult? { self.update.chosenInlineResult }
    var shippingQuery: ShippingQuery? { self.update.shippingQuery }
    var preCheckoutQuery: PreCheckoutQuery? { self.update.preCheckoutQuery }
    var chatMemberUpdated: ChatMemberUpdated? {
        self.update.chatMember ?? self.update.myChatMember
    }
    var chatJoinRequest: ChatJoinRequest? { self.update.chatJoinRequest }
    var messageReaction: MessageReactionUpdated? { self.update.messageReaction }
    var poll: Poll? { self.update.poll }
    var pollAnswer: PollAnswer? { self.update.pollAnswer }
    /// The update's kind, when it carries a known payload.
    var updateKind: UpdateKind? { self.parsedUpdate.kind }
    /// Which update field produced ``message``.
    var messageSource: TelerouteMessageSource? { self.parsedUpdate.messageSource }
}

// MARK: - Side-effect overloads for the typed payload sugar

public extension TelerouteRouterGroup {

    /// Registers a side-effect-only inlineQuery handler.
    func inlineQuery(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (InlineQuery, Context) async throws -> Void
    ) {
        self.inlineQuery(guards: guards, middlewares: middlewares) { (payload: InlineQuery, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only chosenInlineResult handler.
    func chosenInlineResult(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ChosenInlineResult, Context) async throws -> Void
    ) {
        self.chosenInlineResult(guards: guards, middlewares: middlewares) { (payload: ChosenInlineResult, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only shippingQuery handler.
    func shippingQuery(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ShippingQuery, Context) async throws -> Void
    ) {
        self.shippingQuery(guards: guards, middlewares: middlewares) { (payload: ShippingQuery, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only preCheckoutQuery handler.
    func preCheckoutQuery(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (PreCheckoutQuery, Context) async throws -> Void
    ) {
        self.preCheckoutQuery(guards: guards, middlewares: middlewares) { (payload: PreCheckoutQuery, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only chatMember handler.
    func chatMember(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ChatMemberUpdated, Context) async throws -> Void
    ) {
        self.chatMember(guards: guards, middlewares: middlewares) { (payload: ChatMemberUpdated, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only myChatMember handler.
    func myChatMember(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ChatMemberUpdated, Context) async throws -> Void
    ) {
        self.myChatMember(guards: guards, middlewares: middlewares) { (payload: ChatMemberUpdated, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only chatJoinRequest handler.
    func chatJoinRequest(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (ChatJoinRequest, Context) async throws -> Void
    ) {
        self.chatJoinRequest(guards: guards, middlewares: middlewares) { (payload: ChatJoinRequest, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only messageReaction handler.
    func messageReaction(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (MessageReactionUpdated, Context) async throws -> Void
    ) {
        self.messageReaction(guards: guards, middlewares: middlewares) { (payload: MessageReactionUpdated, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only messageReactionCount handler.
    func messageReactionCount(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (MessageReactionCountUpdated, Context) async throws -> Void
    ) {
        self.messageReactionCount(guards: guards, middlewares: middlewares) { (payload: MessageReactionCountUpdated, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only poll handler.
    func poll(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Poll, Context) async throws -> Void
    ) {
        self.poll(guards: guards, middlewares: middlewares) { (payload: Poll, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only pollAnswer handler.
    func pollAnswer(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (PollAnswer, Context) async throws -> Void
    ) {
        self.pollAnswer(guards: guards, middlewares: middlewares) { (payload: PollAnswer, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only businessConnection handler.
    func businessConnection(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (BusinessConnection, Context) async throws -> Void
    ) {
        self.businessConnection(guards: guards, middlewares: middlewares) { (payload: BusinessConnection, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers a side-effect-only purchasedPaidMedia handler.
    func purchasedPaidMedia(
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (PaidMediaPurchased, Context) async throws -> Void
    ) {
        self.purchasedPaidMedia(guards: guards, middlewares: middlewares) { (payload: PaidMediaPurchased, context: Context) -> TelerouteResponse in
            try await handler(payload, context)
            return .none
        }
    }

    /// Registers an update-kind handler returning a ``TelerouteResponse``.
    func on(
        _ kinds: UpdateKind...,
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) {
        self.registerKinds(Set(kinds), guards: guards, middlewares: middlewares, handler: handler)
    }

    /// Registers an unmatched hook returning a ``TelerouteResponse``.
    func unmatched(
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> TelerouteResponse
    ) {
        self.registerUnmatched(middlewares: middlewares, handler: handler)
    }
}

// MARK: - Side-effect overloads for text routes

public extension TelerouteRouterGroup {
    /// Registers a side-effect-only handler for exact text messages.
    func text(
        _ exact: String,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Void
    ) {
        self.message(
            .custom("text(\(exact))") { $0.text == exact },
            from: sources,
            guards: guards,
            middlewares: middlewares,
            use: handler
        )
    }

    /// Registers a side-effect-only handler for prefixed text messages.
    func text(
        prefix: String,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Void
    ) {
        self.message(
            .custom("text(prefix: \(prefix))") { $0.text?.hasPrefix(prefix) == true },
            from: sources,
            guards: guards,
            middlewares: middlewares,
            use: handler
        )
    }

    /// Registers a side-effect-only handler for regex-matched text messages.
    func text(
        matching regex: Regex<some Any>,
        from sources: Set<TelerouteMessageSource> = [.message],
        guards: [any TelerouteGuard] = [],
        middlewares: [any TelerouteMiddleware<TelerouteContext>] = [],
        use handler: @escaping @Sendable (Context) async throws -> Void
    ) {
        nonisolated(unsafe) let regex = regex
        self.message(
            .custom("text(regex)") { message in
                guard let text = message.text else { return false }
                return (try? regex.firstMatch(in: text)) != nil
            },
            from: sources,
            guards: guards,
            middlewares: middlewares,
            use: handler
        )
    }
}
