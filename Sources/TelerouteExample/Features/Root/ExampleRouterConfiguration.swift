import Teleroute

/// Root controller that composes the example's routes, modules, and flows.
struct ExampleRouterConfiguration: TelerouteModule {
    func register(in routes: TelerouteRoutes) {
        let admin = routes.group("admin")
        let billing = routes.group("billing").mount(BillingModule())
        let callbacks = self.registerCallbacks(routes: routes, admin: admin, billing: billing)

        self.registerRootCommands(routes: routes, callbacks: callbacks)
        self.registerAdminCommands(admin: admin)
        self.mountModulesAndFlows(in: routes)
    }

    private func registerRootCommands(
        routes: TelerouteRoutes,
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
        routes: TelerouteRoutes,
        admin: TelerouteRoutes,
        billing: BillingModule.Routes
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
            middlewares: [TelerouteAccessLogMiddleware(label: "admin-callback-ban")],
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

    private func registerAdminCommands(admin: TelerouteRoutes) {
        admin.command(
            AdminBanCommand.self,
            description: "Ban a user inside the admin namespace",
            visibility: [.allChatAdministrators],
            middlewares: [TelerouteAccessLogMiddleware(label: "admin-ban")]
        )
    }

    private func mountModulesAndFlows(in routes: TelerouteRoutes) {
        routes.group("diag").mount(DiagnosticsModule())
        routes.group("moderation").mount(ModerationModule())
        routes.flow(SignupFlow())
    }

    private func start(
        _ context: TelerouteContext,
        routes: TelerouteRoutes,
        callbacks: ExampleStartScreen.CallbackRoutes
    ) async throws {
        let screen = try ExampleStartScreen(routes: routes, callbacks: callbacks)
        try await context.reply(screen.text, replyMarkup: screen.replyMarkup)
    }

    private func resumeSignup(_ context: TelerouteContext) async throws {
        try await context.start(SignupFlow.self, at: .name)
        try await context.reply("Signup flow restarted. Send your name.")
    }

    private func cancelSignup(_ context: TelerouteContext) async throws {
        try await context.cancelFlow()
        try await context.reply("Active flow cancelled.")
    }

    private func refreshMenu(_ context: TelerouteContext) async throws {
        guard let chatId = context.chatId else {
            try await context.reply("Unable to determine chat for menu refresh.")
            return
        }

        try await context.bot.deleteMyCommands(
            params: .init(
                scope: .botCommandScopeChat(
                    .init(type: .chat, chatId: .chat(chatId))
                )
            )
        )
        try await context.publishCommands(
            ExampleCommandMenus.privateChat,
            visibility: .chat(.id(chatId))
        )
        try await context.reply("Menu refreshed for this chat.")
    }

    private func openSupport(
        _ callback: SupportCallback,
        _ context: TelerouteContext
    ) async throws {
        try await context.answerCallbackQuery("Opening \(callback.topic)")
        try await context.edit("Support topic: \(callback.topic)")
    }

    private func banUser(
        _ callback: AdminBanCallback,
        _ context: TelerouteContext
    ) async throws {
        try await context.answerCallbackQuery("User \(callback.userID) banned")
        try await context.edit("Admin action completed for user \(callback.userID)")
    }
}
