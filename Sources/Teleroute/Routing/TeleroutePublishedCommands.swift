import Foundation
import OrderedCollections

/// Chat target used by Telegram command visibility scopes.
public enum TelerouteCommandChat: Hashable, Sendable {
    /// Numeric Telegram chat identifier.
    case id(Int64)
    /// Public Telegram chat username, for example `"@my_group"`.
    case username(String)

    func telegramChatID() -> ChatId {
        switch self {
        case let .id(value):
            return .id(value)
        case let .username(value):
            return .username(value)
        }
    }

    func storageKey() -> String {
        switch self {
        case let .id(value):
            return "id:\(value)"
        case let .username(value):
            return "username:\(value)"
        }
    }
}

/// Scope used when publishing Telegram bot commands.
public enum TelerouteCommandScope: Hashable, Sendable {
    /// Base Telegram command scope used when there is no narrower match.
    ///
    /// Telegram resolves command lists from the narrowest scope to the broadest one
    /// and falls back to `default` when no more specific scope applies.
    case `default`
    /// Commands visible in all private chats with the bot.
    case allPrivateChats
    /// Commands visible in all group and supergroup chats.
    case allGroupChats
    /// Commands visible to administrators in all group and supergroup chats.
    case allChatAdministrators
    /// Commands visible only in one specific chat.
    case chat(TelerouteCommandChat)
    /// Commands visible only to administrators of one specific chat.
    case chatAdministrators(TelerouteCommandChat)
    /// Commands visible only to one specific user in one specific chat.
    case chatMember(chat: TelerouteCommandChat, userID: Int64)

    func telegramScope() -> BotCommandScope {
        switch self {
        case .default:
            return ._default(.init(_type: "default"))
        case .allPrivateChats:
            return .allPrivateChats(.init(_type: "all_private_chats"))
        case .allGroupChats:
            return .allGroupChats(.init(_type: "all_group_chats"))
        case .allChatAdministrators:
            return .allChatAdministrators(.init(_type: "all_chat_administrators"))
        case let .chat(chat):
            return .chat(.init(_type: "chat", chatId: chat.telegramChatID()))
        case let .chatAdministrators(chat):
            return .chatAdministrators(
                .init(_type: "chat_administrators", chatId: chat.telegramChatID())
            )
        case let .chatMember(chat, userID):
            return .chatMember(
                .init(_type: "chat_member", chatId: chat.telegramChatID(), userId: userID)
            )
        }
    }

    func storageKey() -> String {
        switch self {
        case .default:
            return "default"
        case .allPrivateChats:
            return "allPrivateChats"
        case .allGroupChats:
            return "allGroupChats"
        case .allChatAdministrators:
            return "allChatAdministrators"
        case let .chat(chat):
            return "chat|\(chat.storageKey())"
        case let .chatAdministrators(chat):
            return "chatAdministrators|\(chat.storageKey())"
        case let .chatMember(chat, userID):
            return "chatMember|\(chat.storageKey())|\(userID)"
        }
    }
}

/// Published Telegram command visibility configuration.
public struct TelerouteCommandVisibility: Hashable, Sendable {
    /// Telegram scope used for the published command list.
    public let scope: TelerouteCommandScope
    /// Optional ISO 639-1 language code for a localized command list.
    public let languageCode: String?

    /// Creates a published command visibility configuration.
    ///
    /// - Parameters:
    ///   - scope: Telegram command scope. Defaults to `.default`.
    ///   - languageCode: Optional ISO 639-1 language code.
    public init(
        _ scope: TelerouteCommandScope = .default,
        languageCode: String? = nil
    ) {
        self.scope = scope
        self.languageCode = languageCode
    }

    /// Base Telegram command scope used when there is no narrower match.
    public static let `default` = Self()
    /// Commands visible in all private chats with the bot.
    public static let allPrivateChats = Self(.allPrivateChats)
    /// Commands visible in all group and supergroup chats.
    public static let allGroupChats = Self(.allGroupChats)
    /// Commands visible to administrators in all group and supergroup chats.
    public static let allChatAdministrators = Self(.allChatAdministrators)

    /// Creates visibility for one specific chat.
    public static func chat(_ chat: TelerouteCommandChat) -> Self {
        .init(.chat(chat))
    }

    /// Creates visibility for administrators of one specific chat.
    public static func chatAdministrators(_ chat: TelerouteCommandChat) -> Self {
        .init(.chatAdministrators(chat))
    }

    /// Creates visibility for one specific user inside one specific chat.
    public static func chatMember(
        _ chat: TelerouteCommandChat,
        userID: Int64
    ) -> Self {
        .init(.chatMember(chat: chat, userID: userID))
    }

    func storageKey() -> String {
        "\(self.scope.storageKey())|\(self.languageCode ?? "*")"
    }
}

/// Published commands grouped into a Telegram scope.
public struct TeleroutePublishedCommandSet: Sendable {
    public let visibility: TelerouteCommandVisibility
    public let commands: [BotCommand]
}

struct TeleroutePublishedCommand: Sendable {
    let name: String
    let description: String
    let visibility: TelerouteCommandVisibility
}

enum TeleroutePublishedCommandBuilder {
    typealias GroupedCommands = OrderedDictionary<
        String,
        (visibility: TelerouteCommandVisibility, commands: OrderedDictionary<String, String>)
    >

    static func registeredSets(
        from commands: [TeleroutePublishedCommand]
    ) throws -> [TeleroutePublishedCommandSet] {
        var grouped: GroupedCommands = [:]
        for command in commands {
            try self.append(
                .init(command: command.name, description: command.description),
                visibility: command.visibility,
                to: &grouped
            )
        }
        return self.sets(from: grouped)
    }

    static func makeBotCommand(
        _ command: any TelerouteCommand.Type
    ) throws -> BotCommand {
        guard let description = command.commandDescription else {
            throw TelerouteError.missingPublishedCommandDescription(command.path)
        }
        return .init(command: command.path, description: description)
    }

    static func typedSets(
        for commands: [any TelerouteCommand.Type]
    ) throws -> [TeleroutePublishedCommandSet] {
        var grouped: GroupedCommands = [:]
        for command in commands {
            let botCommand = try self.makeBotCommand(command)
            for visibility in command.visibility {
                try self.append(botCommand, visibility: visibility, to: &grouped)
            }
        }
        return self.sets(from: grouped)
    }

    private static func append(
        _ botCommand: BotCommand,
        visibility: TelerouteCommandVisibility,
        to grouped: inout GroupedCommands
    ) throws {
        let visibilityKey = visibility.storageKey()
        var group = grouped[visibilityKey] ?? (visibility, [:])
        if let existingDescription = group.commands[botCommand.command] {
            guard existingDescription == botCommand.description else {
                throw TelerouteError.duplicatePublishedCommand(
                    botCommand.command,
                    visibility: visibilityKey
                )
            }
            grouped[visibilityKey] = group
            return
        }
        group.commands[botCommand.command] = botCommand.description
        grouped[visibilityKey] = group
    }

    private static func sets(
        from grouped: GroupedCommands
    ) -> [TeleroutePublishedCommandSet] {
        grouped.values.map { value in
            .init(
                visibility: value.visibility,
                commands: value.commands.map { command, description in
                    .init(command: command, description: description)
                }
            )
        }
    }
}

public extension TelerouteRouterGroup {
    /// Returns commands registered in this router, grouped by Telegram
    /// visibility scope.
    func publishedCommandSets() throws -> [TeleroutePublishedCommandSet] {
        try TeleroutePublishedCommandBuilder.registeredSets(
            from: self.routes.storage.publishedCommands
        )
    }
}

@_spi(Testing)
public extension TelerouteRuntime {
    /// Publishes an explicit list of commands for the supplied visibility scope.
    ///
    /// Use this when command visibility must change at runtime, for example after
    /// login or after selecting a bot mode.
    func publishCommands(
        _ commands: [BotCommand],
        visibility: TelerouteCommandVisibility = .default
    ) async throws {
        try await self.bot.setMyCommands(
            commands,
            scope: visibility.scope.telegramScope(),
            languageCode: visibility.languageCode
        )
    }

    /// Publishes an explicit list of commands for the supplied visibility scope.
    ///
    /// This overload accepts simple `(command, description)` tuples and converts
    /// them into `BotCommand` values for you.
    func publishCommands(
        _ commands: [(command: String, description: String)],
        visibility: TelerouteCommandVisibility = .default
    ) async throws {
        try await self.publishCommands(
            commands.map { .init(command: $0.command, description: $0.description) },
            visibility: visibility
        )
    }

    /// Publishes typed commands using their `path`, `commandDescription`, and `visibility`.
    func publishCommands(
        _ commands: [any TelerouteCommand.Type]
    ) async throws {
        for commandSet in try TeleroutePublishedCommandBuilder.typedSets(for: commands) {
            try await self.publishCommands(
                commandSet.commands,
                visibility: commandSet.visibility
            )
        }
    }

    /// Publishes typed commands using their `path` and `commandDescription` for one explicit visibility scope.
    func publishCommands(
        _ commands: [any TelerouteCommand.Type],
        visibility: TelerouteCommandVisibility
    ) async throws {
        try await self.publishCommands(
            try commands.map(TeleroutePublishedCommandBuilder.makeBotCommand),
            visibility: visibility
        )
    }

    /// Returns registered Telegram bot commands grouped by their visibility scope.
    func publishedCommandSets() throws -> [TeleroutePublishedCommandSet] {
        try TeleroutePublishedCommandBuilder.registeredSets(
            from: self.storage.publishedCommands
        )
    }

    /// Publishes registered Telegram bot commands via `setMyCommands`.
    ///
    /// Telegram resolves command lists from narrower scopes to broader ones, so
    /// a chat- or member-specific command list overrides broader scopes such as
    /// `allGroupChats` and `default`.
    func syncPublishedCommands() async throws {
        for commandSet in try self.publishedCommandSets() {
            try await self.bot.setMyCommands(
                commandSet.commands,
                scope: commandSet.visibility.scope.telegramScope(),
                languageCode: commandSet.visibility.languageCode
            )
        }
    }

    static func makePublishedBotCommand(
        _ command: any TelerouteCommand.Type
    ) throws -> BotCommand {
        try TeleroutePublishedCommandBuilder.makeBotCommand(command)
    }

    /// Groups typed commands into the visibility-scoped sets that should be
    /// published via `setMyCommands`. Pure function: does not read router state.
    static func publishedCommandSets(
        for commands: [any TelerouteCommand.Type]
    ) throws -> [TeleroutePublishedCommandSet] {
        try TeleroutePublishedCommandBuilder.typedSets(for: commands)
    }
}

public extension TelerouteContext {
    /// Publishes an explicit list of commands for the supplied visibility scope.
    ///
    /// This is useful inside command handlers when the visible command list must
    /// change immediately after the current action completes.
    func publishCommands(
        _ commands: [BotCommand],
        visibility: TelerouteCommandVisibility = .default
    ) async throws {
        try await self.bot.setMyCommands(
            commands,
            scope: visibility.scope.telegramScope(),
            languageCode: visibility.languageCode
        )
    }

    /// Publishes an explicit list of commands for the supplied visibility scope.
    ///
    /// This overload accepts simple `(command, description)` tuples and converts
    /// them into `BotCommand` values for you.
    func publishCommands(
        _ commands: [(command: String, description: String)],
        visibility: TelerouteCommandVisibility = .default
    ) async throws {
        try await self.publishCommands(
            commands.map { .init(command: $0.command, description: $0.description) },
            visibility: visibility
        )
    }

    /// Publishes typed commands using their `path`, `commandDescription`, and `visibility`.
    func publishCommands(
        _ commands: [any TelerouteCommand.Type]
    ) async throws {
        for commandSet in try TeleroutePublishedCommandBuilder.typedSets(for: commands) {
            try await self.bot.setMyCommands(
                commandSet.commands,
                scope: commandSet.visibility.scope.telegramScope(),
                languageCode: commandSet.visibility.languageCode
            )
        }
    }

    /// Publishes typed commands using their `path` and `commandDescription` for one explicit visibility scope.
    func publishCommands(
        _ commands: [any TelerouteCommand.Type],
        visibility: TelerouteCommandVisibility
    ) async throws {
        try await self.publishCommands(
            try commands.map(TeleroutePublishedCommandBuilder.makeBotCommand),
            visibility: visibility
        )
    }
}
