import Teleroute

/// Root controller that composes the example's route collections and flows.
struct ExampleRouterConfiguration: TelerouteRouteCollection {
    func addRoutes(to routes: ExampleRoutes) {
        let admin = routes.group("admin", context: ExampleUserContext.self)
        admin.middlewares.add(core: TelerouteAccessLogMiddleware(label: "admin"))
        admin.guards.add(TelerouteAdminGuard())

        let billing = routes.group("billing").addRoutes(BillingRoutes())
        let callbacks = self.registerCallbacks(routes: routes, admin: admin, billing: billing)

        self.registerRootCommands(routes: routes, callbacks: callbacks)
        self.registerAdminCommands(admin: admin)
        self.addCollectionsAndFlows(to: routes)
    }

    private func registerRootCommands(
        routes: ExampleRoutes,
        callbacks: ExampleStartScreen.CallbackRoutes
    ) {
        routes.command(
            "start",
            description: "Show the example menu",
            visibility: [.allPrivateChats],
            guards: [TeleroutePrivateChatGuard()],
            middlewares: [TelerouteAccessLogMiddleware(label: "start")]
        ) { context in
            try await self.start(context, routes: routes, callbacks: callbacks)
        }

        routes.command(
            "resume_signup",
            description: "Restart the signup flow",
            visibility: [.allPrivateChats],
            use: self.resumeSignup
        )

        routes.command(
            "cancel_signup",
            description: "Cancel the active signup flow",
            visibility: [.allPrivateChats],
            use: self.cancelSignup
        )

        routes.command(
            "refresh_menu",
            description: "Reset and republish this chat's menu",
            visibility: [.allPrivateChats],
            use: self.refreshMenu
        )

        routes.command(
            ProfileCommand.self,
            guards: [TeleroutePrivateChatGuard()],
            middlewares: [TelerouteAccessLogMiddleware(label: "profile")]
        )

        routes.command(SyncCatalogCommand.self)
    }

    private func registerCallbacks(
        routes: ExampleRoutes,
        admin: ExampleUserRoutes,
        billing: BillingRoutes.Routes
    ) -> ExampleStartScreen.CallbackRoutes {
        let approveOrder = routes.callback(
            ApproveOrderCallback.self,
            guards: [TeleroutePrivateChatGuard()],
            middlewares: [TelerouteAccessLogMiddleware(label: "approve-order")]
        )

        let archiveTicket = routes.callback(ArchiveTicketCallback.self)

        let support = routes.callback(
            SupportCallback.self,
            guards: [TeleroutePrivateChatGuard()],
            middlewares: [TelerouteAccessLogMiddleware(label: "support")],
            use: self.openSupport
        )

        let adminBan = admin.callback(
            AdminBanCallback.self,
            use: self.banUser
        )

        return .init(
            support: support,
            approveOrder: approveOrder,
            archiveTicket: archiveTicket,
            adminBan: adminBan,
            payInvoice: billing.pay
        )
    }

    private func registerAdminCommands(admin: ExampleUserRoutes) {
        admin.command(
            AdminBanCommand.self,
            description: "Ban a user inside the admin namespace",
            visibility: [.allChatAdministrators]
        )
    }

    private func addCollectionsAndFlows(to routes: ExampleRoutes) {
        routes.group("diag").addRoutes(DiagnosticsRoutes())
        routes.group("moderation").addRoutes(ModerationRoutes())
        routes.addRoutes(UpdateShowcaseRoutes())
        routes.flow(SignupFlow())
    }

    private func start(
        _ context: ExampleRequestContext,
        routes: ExampleRoutes,
        callbacks: ExampleStartScreen.CallbackRoutes
    ) async throws -> TelerouteResponse {
        let screen = try ExampleStartScreen(routes: routes, callbacks: callbacks)
        return .reply(
            "\(screen.text)\n\nRequest: \(context.requestID)",
            replyMarkup: screen.replyMarkup
        )
    }

    private func resumeSignup(_ context: ExampleRequestContext) async throws {
        try await context.start(SignupFlow.self, at: .name)
        try await context.reply("Signup flow restarted. Send your name.")
    }

    private func cancelSignup(_ context: ExampleRequestContext) async throws {
        try await context.cancelFlow()
        try await context.reply("Active flow cancelled.")
    }

    private func refreshMenu(_ context: ExampleRequestContext) async throws {
        guard let chatId = context.chatId else {
            try await context.reply("Unable to determine chat for menu refresh.")
            return
        }

        try await context.bot.deleteMyCommands(
            scope: .chat(.init(chatId: .id(chatId)))
        )
        try await context.coreContext.publishCommands(
            ExampleCommandMenus.privateChat,
            visibility: .chat(.id(chatId))
        )
        try await context.reply("Menu refreshed for this chat.")
    }

    private func openSupport(
        _ callback: SupportCallback,
        _ context: ExampleRequestContext
    ) async throws -> TelerouteResponse {
        .sequence([
            .answerCallback("Opening \(callback.topic)"),
            .edit("Support topic: \(callback.topic)"),
        ])
    }

    private func banUser(
        _ callback: AdminBanCallback,
        _ context: ExampleUserContext
    ) async throws -> TelerouteResponse {
        .sequence([
            .answerCallback("User \(callback.userID) banned by \(context.userID)"),
            .edit("Admin action completed for user \(callback.userID)"),
        ])
    }
}
