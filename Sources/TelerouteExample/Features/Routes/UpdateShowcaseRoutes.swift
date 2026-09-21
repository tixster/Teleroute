import Teleroute

/// Showcases the 2.0 routing surface: plain-message and text routes, typed
/// update-kind handlers, chainable responses, and the keyboard DSL.
struct UpdateShowcaseRoutes: TelerouteRouteCollection {
    func addRoutes(to routes: ExampleRoutes) {
        // Exact-text route — no command required.
        routes.text("ping") { _ in "pong" }

        // Prefix route with a chainable reply.
        routes.text(prefix: "!echo ") { context in
            Reply(String(context.message?.text?.dropFirst(6) ?? ""))
                .quoting("echo")
                .silent()
        }

        // Content-filtered message route.
        routes.message(.photo) { context in
            Reply("Nice photo! Caption: \(context.message?.caption ?? "—")")
        }

        // Emoji reactions on any handled message.
        routes.text("react") { context in
            try await context.react("🔥")
            return TelerouteResponse.done
        }

        // Typed update-kind handlers.
        routes.messageReaction { reaction, context in
            try await context.send(
                "Thanks for the reaction in chat \(reaction.chat.id)!",
                to: .id(reaction.chat.id)
            )
        }

        routes.chatJoinRequest { request, context in
            try await context.approveJoinRequest()
            try await context.send(
                "Welcome, \(request.from.firstName)!",
                to: .id(request.chat.id)
            )
        }

        routes.inlineQuery { query, context in
            try await context.bot.answerInlineQuery(
                inlineQueryId: query.id,
                results: [
                    .InlineQueryResultArticle(.init(                        id: "hello",
                        title: "Say hello",
                        inputMessageContent: .InputTextMessageContent(.init(
                            messageText: "Hello from inline mode!"
                        ))
                    )),
                ],
                cacheTime: 30
            )
        }

        // Keyboard DSL with mixed destinations.
        routes.command("links", description: "Show useful links") { context in
            let keyboard = try routes.keyboard {
                Row {
                    TelerouteButton.url("Documentation", "https://core.telegram.org/bots/api")
                    TelerouteButton.switchInlineQuery("Share", query: "hello")
                }
                TelerouteButton.copyText("Copy token format", copy: "123456:ABC-DEF")
            }
            return Reply("Useful links:").keyboard(keyboard)
        }
    }
}
