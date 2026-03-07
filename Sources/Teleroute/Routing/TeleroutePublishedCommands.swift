import SwiftTelegramBot
import Foundation

/// Chat target used by Telegram command visibility scopes.
public enum TelerouteCommandChat: Hashable, Sendable {
    /// Numeric Telegram chat identifier.
    case id(Int64)
    /// Public Telegram chat username, for example `"@my_group"`.
    case username(String)

    func telegramChatID() -> TGChatId {
        switch self {
        case let .id(value):
            return .chat(value)
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

    func telegramScope() -> TGBotCommandScope {
        switch self {
        case .default:
            return .botCommandScopeDefault(.init(type: .default))
        case .allPrivateChats:
            return .botCommandScopeAllPrivateChats(.init(type: .allPrivateChats))
        case .allGroupChats:
            return .botCommandScopeAllGroupChats(.init(type: .allGroupChats))
        case .allChatAdministrators:
            return .botCommandScopeAllChatAdministrators(.init(type: .allChatAdministrators))
        case let .chat(chat):
            return .botCommandScopeChat(.init(type: .chat, chatId: chat.telegramChatID()))
        case let .chatAdministrators(chat):
            return .botCommandScopeChatAdministrators(
                .init(type: .chatAdministrators, chatId: chat.telegramChatID())
            )
        case let .chatMember(chat, userID):
            return .botCommandScopeChatMember(
                .init(type: .chatMember, chatId: chat.telegramChatID(), userId: userID)
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
    public let commands: [TGBotCommand]

    var telegramParams: TGSetMyCommandsParams {
        self.visibility.telegramParams(commands: self.commands)
    }
}

struct TeleroutePublishedCommand: Sendable {
    let name: String
    let description: String
    let visibility: TelerouteCommandVisibility
}

public extension Teleroute {
    /// Publishes an explicit list of commands for the supplied visibility scope.
    ///
    /// Use this when command visibility must change at runtime, for example after
    /// login or after selecting a bot mode.
    func publishCommands(
        _ commands: [TGBotCommand],
        visibility: TelerouteCommandVisibility = .default
    ) async throws {
        _ = try await self.bot.setMyCommands(params: visibility.telegramParams(commands: commands))
    }

    /// Publishes an explicit list of commands for the supplied visibility scope.
    ///
    /// This overload accepts simple `(command, description)` tuples and converts
    /// them into `TGBotCommand` values for you.
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
        for commandSet in try publishedCommandSets(for: commands) {
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
            try commands.map(Self.makePublishedBotCommand),
            visibility: visibility
        )
    }

    /// Returns registered Telegram bot commands grouped by their visibility scope.
    func publishedCommandSets() throws -> [TeleroutePublishedCommandSet] {
        var grouped: [String: (visibility: TelerouteCommandVisibility, commands: [TGBotCommand])] = [:]
        var existingDescriptions: [String: [String: String]] = [:]

        for command in self.storage.publishedCommands {
            let visibilityKey = command.visibility.storageKey()
            if let existingDescription = existingDescriptions[visibilityKey]?[command.name] {
                guard existingDescription == command.description else {
                    throw TelerouteError.duplicatePublishedCommand(
                        command.name,
                        visibility: visibilityKey
                    )
                }
                continue
            }

            existingDescriptions[visibilityKey, default: [:]][command.name] = command.description
            grouped[visibilityKey, default: (command.visibility, [])].commands.append(
                .init(command: command.name, description: command.description)
            )
        }

        return grouped
            .sorted { $0.key < $1.key }
            .map { _, value in
                .init(visibility: value.visibility, commands: value.commands)
            }
    }

    /// Publishes registered Telegram bot commands via `setMyCommands`.
    ///
    /// Telegram resolves command lists from narrower scopes to broader ones, so
    /// a chat- or member-specific command list overrides broader scopes such as
    /// `allGroupChats` and `default`.
    func syncPublishedCommands() async throws {
        for commandSet in try self.publishedCommandSets() {
            _ = try await self.bot.setMyCommands(params: commandSet.telegramParams)
        }
    }

    private static func makePublishedBotCommand(
        _ command: any TelerouteCommand.Type
    ) throws -> TGBotCommand {
        guard let description = command.commandDescription else {
            throw TelerouteError.missingPublishedCommandDescription(command.path)
        }
        return .init(command: command.path, description: description)
    }

    private func publishedCommandSets(
        for commands: [any TelerouteCommand.Type]
    ) throws -> [TeleroutePublishedCommandSet] {
        var grouped: [String: (visibility: TelerouteCommandVisibility, commands: [TGBotCommand])] = [:]

        for command in commands {
            let botCommand = try Self.makePublishedBotCommand(command)
            for visibility in command.visibility {
                grouped[visibility.storageKey(), default: (visibility, [])].commands.append(botCommand)
            }
        }

        return grouped
            .sorted { $0.key < $1.key }
            .map { _, value in
                .init(visibility: value.visibility, commands: value.commands)
            }
    }
}

public extension TelerouteContext {
    /// Publishes an explicit list of commands for the supplied visibility scope.
    ///
    /// This is useful inside command handlers when the visible command list must
    /// change immediately after the current action completes.
    func publishCommands(
        _ commands: [TGBotCommand],
        visibility: TelerouteCommandVisibility = .default
    ) async throws {
        _ = try await self.bot.setMyCommands(params: visibility.telegramParams(commands: commands))
    }

    /// Publishes an explicit list of commands for the supplied visibility scope.
    ///
    /// This overload accepts simple `(command, description)` tuples and converts
    /// them into `TGBotCommand` values for you.
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
        let router = Teleroute(bot: self.bot, logger: .init(label: "teleroute.publish"))
        try await router.publishCommands(commands)
    }

    /// Publishes typed commands using their `path` and `commandDescription` for one explicit visibility scope.
    func publishCommands(
        _ commands: [any TelerouteCommand.Type],
        visibility: TelerouteCommandVisibility
    ) async throws {
        let router = Teleroute(bot: self.bot, logger: .init(label: "teleroute.publish"))
        try await router.publishCommands(commands, visibility: visibility)
    }
}

private extension TelerouteCommandVisibility {
    func telegramParams(commands: [TGBotCommand]) -> TGSetMyCommandsParams {
        .init(
            commands: commands,
            scope: self.scope.telegramScope(),
            languageCode: self.languageCode
        )
    }
}
