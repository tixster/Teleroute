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

        // Keyboard DSL with mixed destinations, described inline in the
        // response: the buttons are rendered when it executes.
        routes.command("links", description: "Show useful links") { _ in
            Reply("Useful links:").keyboard {
                Row {
                    TelerouteButton("Documentation", url: "https://core.telegram.org/bots/api")
                    TelerouteButton.switchInlineQuery("Share", query: "hello")
                }
                TelerouteButton("Copy token format", copy: "123456:ABC-DEF")
            }
        }

        // Handlers written straight into the buttons. Enabled by
        // `inlineActions` in ExampleBootstrap; the handlers live in memory,
        // so these buttons stop working when the process restarts.
        routes.command("confirm", description: "Inline button handlers") { _ in
            Reply("Publish the draft?").keyboard {
                Row {
                    TelerouteButton("Publish") { press in
                        try await press.answerCallbackQuery("Published")
                        return Edit("Draft published ✅")
                    }
                    .style(.success)
                    TelerouteButton("Discard") { Edit("Draft discarded") }
                        .style(.danger)
                    // Clears itself after a clean run, leaving the other two.
                    TelerouteButton("Snooze", onSuccess: .removeButton) { _ in
                        AnswerCallback(text: "Snoozed for an hour")
                    }
                }
            }
        }
    }
}
