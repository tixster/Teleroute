import Teleroute

/// Central router composition for the example target.
///
/// This file is the best place to scan when you want to understand which example
/// feature covers which part of the library API.
enum ExampleRouterConfiguration {
    /// Mounts all example routes, groups, collections, and flows into the router.
    static func configure(router: Teleroute) {
        let admin = router.group("admin")

        registerRootCommands(router: router, admin: admin)
        registerRootCallbacks(router: router)
        registerAdminRoutes(admin: admin)
        mountCollectionsAndFlows(router: router)
    }

    /// Registers top-level commands that are part of the base example experience.
    private static func registerRootCommands(router: Teleroute, admin: TelerouteGroup) {
        router.command(
            "start",
            description: "Show the example menu",
            visibility: [.allPrivateChats],
            routeGuard: ChatTypeGuard(.private),
            middlewares: [AccessLogMiddleware(label: "start")]
        ) { _, context in
            let screen = try ExampleStartScreen(router: router, admin: admin)
            try await context.reply(text: screen.text, replyMarkup: screen.replyMarkup)
        }

        router.command(
            "resume_signup",
            description: "Restart the signup flow",
            visibility: [.allPrivateChats]
        ) { _, context in
            try await context.start(SignupFlow.self, at: .name)
            try await context.reply(text: "Signup flow restarted. Send your name.")
        }

        router.command(
            "cancel_signup",
            description: "Cancel the active signup flow",
            visibility: [.allPrivateChats]
        ) { _, context in
            try await context.cancelFlow()
            try await context.reply(text: "Active flow cancelled.")
        }

        router.command(
            "refresh_menu",
            description: "Reset and republish this chat's menu",
            visibility: [.allPrivateChats]
        ) { _, context in
            guard let chatId = context.chatId else {
                try await context.reply(text: "Unable to determine chat for menu refresh.")
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
            try await context.reply(text: "Menu refreshed for this chat.")
        }

        router.command(
            ProfileCommand.self,
            routeGuard: ChatTypeGuard(.private),
            middlewares: [AccessLogMiddleware(label: "profile")]
        )
        router.command(SyncCatalogCommand.self)
    }

    /// Registers top-level callbacks that are not encapsulated in collections or flows.
    private static func registerRootCallbacks(router: Teleroute) {
        router.callback(
            ApproveOrderCallback.self,
            routeGuard: ChatTypeGuard(.private),
            middlewares: [AccessLogMiddleware(label: "approve-order")]
        ) { _, context, callback in
            try await context.answerCallbackQuery(text: "Order \(callback.orderID) approved")
            try await context.edit(text: "Order \(callback.orderID) approved")
        }

        router.callback(ArchiveTicketCallback.self)

        router.callback(
            "support/{topic}",
            routeGuard: ChatTypeGuard(.private),
            middlewares: [AccessLogMiddleware(label: "support")]
        ) { _, context in
            let topic = try context.parameters.require("topic")
            try await context.answerCallbackQuery(text: "Opening \(topic)")
            try await context.edit(text: "Support topic: \(topic)")
        }
    }

    /// Registers routes inside the `admin` group.
    private static func registerAdminRoutes(admin: TelerouteGroup) {
        admin.command(
            AdminBanCommand.self,
            description: "Ban a user inside the admin namespace",
            visibility: [.allChatAdministrators],
            middlewares: [AccessLogMiddleware(label: "admin-ban")]
        ) { _, context, command in
            try await context.reply(
                text: "Admin ban: \(command.userID), reason: \(command.reason ?? "not provided")"
            )
        }

        admin.callback(
            "users/{userID}/ban",
            middlewares: [AccessLogMiddleware(label: "admin-callback-ban")]
        ) { _, context in
            let userID = try context.parameters.require("userID")
            try await context.answerCallbackQuery(text: "User \(userID) banned")
            try await context.edit(text: "Admin action completed for user \(userID)")
        }
    }

    /// Mounts reusable route collections and flows.
    private static func mountCollectionsAndFlows(router: Teleroute) {
        router.add(collection: BillingCollection())
        router.add(collection: DiagnosticsCollection())
        router.group(ModerationCollection())
        router.add(flow: SignupFlow())
    }
}
