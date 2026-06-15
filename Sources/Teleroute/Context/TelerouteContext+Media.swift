import Foundation
import SwiftTelegramBot

/// Telegram chat actions used by ``TelerouteContext/sendChatAction(_:)``.
///
/// `swift-telegram-bot` accepts these as raw strings; this enum provides a
/// type-safe wrapper so callers do not have to remember the literal values.
public enum TelerouteChatAction: Sendable {
    case typing
    case uploadPhoto
    case recordVideo
    case uploadVideo
    case recordVoice
    case uploadVoice
    case uploadDocument
    case chooseSticker
    case findLocation
    case recordVideoNote
    case uploadVideoNote

    var rawValue: String {
        switch self {
        case .typing: "typing"
        case .uploadPhoto: "upload_photo"
        case .recordVideo: "record_video"
        case .uploadVideo: "upload_video"
        case .recordVoice: "record_voice"
        case .uploadVoice: "upload_voice"
        case .uploadDocument: "upload_document"
        case .chooseSticker: "choose_sticker"
        case .findLocation: "find_location"
        case .recordVideoNote: "record_video_note"
        case .uploadVideoNote: "upload_video_note"
        }
    }
}

public extension TelerouteContext {
    /// Resolves the target chat id for a send operation, preferring an explicit
    /// override and falling back to the chat inferred from the current update.
    func resolvedChatId(_ override: Int64?) throws -> Int64 {
        guard let resolved = override ?? self.chatId else {
            throw TelerouteError.chatTargetMissing
        }
        return resolved
    }

    /// Resolves a message id, preferring an explicit override and falling back
    /// to the message carried by the current update.
    func resolvedMessageId(_ override: Int?) throws -> Int {
        guard let resolved = override ?? self.message?.messageId else {
            throw TelerouteError.messageTargetMissing
        }
        return resolved
    }

    // MARK: - Media

    /// Sends a photo to the resolved chat.
    func sendPhoto(
        _ photo: TGFileInfo,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws -> TGMessage {
        let resolved = try self.resolvedChatId(chatId)
        return try await self.bot.sendPhoto(
            params: .init(
                chatId: .chat(resolved),
                photo: photo,
                caption: caption,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )
        )
    }

    /// Sends a document to the resolved chat.
    func sendDocument(
        _ document: TGFileInfo,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws -> TGMessage {
        let resolved = try self.resolvedChatId(chatId)
        return try await self.bot.sendDocument(
            params: .init(
                chatId: .chat(resolved),
                document: document,
                caption: caption,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )
        )
    }

    /// Sends a video to the resolved chat.
    func sendVideo(
        _ video: TGFileInfo,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws -> TGMessage {
        let resolved = try self.resolvedChatId(chatId)
        return try await self.bot.sendVideo(
            params: .init(
                chatId: .chat(resolved),
                video: video,
                caption: caption,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )
        )
    }

    /// Sends an animation (GIF) to the resolved chat.
    func sendAnimation(
        _ animation: TGFileInfo,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws -> TGMessage {
        let resolved = try self.resolvedChatId(chatId)
        return try await self.bot.sendAnimation(
            params: .init(
                chatId: .chat(resolved),
                animation: animation,
                caption: caption,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )
        )
    }

    /// Sends an audio file to the resolved chat.
    func sendAudio(
        _ audio: TGFileInfo,
        caption: String? = nil,
        to chatId: Int64? = nil,
        parseMode: TGParseMode? = nil,
        replyMarkup: TGReplyMarkup? = nil
    ) async throws -> TGMessage {
        let resolved = try self.resolvedChatId(chatId)
        return try await self.bot.sendAudio(
            params: .init(
                chatId: .chat(resolved),
                audio: audio,
                caption: caption,
                parseMode: parseMode,
                replyMarkup: replyMarkup
            )
        )
    }

    /// Sends a group of media (2–10 items) as an album to the resolved chat.
    func sendMediaGroup(
        _ media: [TGInputMedia],
        to chatId: Int64? = nil
    ) async throws -> [TGMessage] {
        let resolved = try self.resolvedChatId(chatId)
        return try await self.bot.sendMediaGroup(
            params: .init(
                chatId: .chat(resolved),
                media: media
            )
        )
    }

    // MARK: - Message operations

    /// Forwards a message from another chat to the resolved target chat.
    func forwardMessage(
        from sourceChatId: Int64,
        messageId: Int,
        to chatId: Int64? = nil
    ) async throws -> TGMessage {
        let resolved = try self.resolvedChatId(chatId)
        return try await self.bot.forwardMessage(
            params: .init(
                chatId: .chat(resolved),
                fromChatId: .chat(sourceChatId),
                messageId: messageId
            )
        )
    }

    /// Deletes a message, defaulting to the message carried by the current update.
    func deleteMessage(messageId: Int? = nil, in chatId: Int64? = nil) async throws {
        let resolvedChat = try self.resolvedChatId(chatId)
        let resolvedMessage = try self.resolvedMessageId(messageId)
        _ = try await self.bot.deleteMessage(
            params: .init(chatId: .chat(resolvedChat), messageId: resolvedMessage)
        )
    }

    /// Edits only the inline keyboard of a message without resending its text.
    ///
    /// Defaults to the message carried by the current update. Throws
    /// ``TelerouteError/messageTargetMissing`` when no message can be resolved.
    func editReplyMarkup(
        _ markup: TGInlineKeyboardMarkup?,
        messageId: Int? = nil,
        in chatId: Int64? = nil
    ) async throws {
        let resolvedChat = try self.resolvedChatId(chatId)
        let resolvedMessage = try self.resolvedMessageId(messageId)
        _ = try await self.bot.editMessageReplyMarkup(
            params: .init(
                chatId: .chat(resolvedChat),
                messageId: resolvedMessage,
                replyMarkup: markup
            )
        )
    }

    // MARK: - Chat actions

    /// Sends a chat action indicator such as "typing…".
    func sendChatAction(_ action: TelerouteChatAction, in chatId: Int64? = nil) async throws {
        let resolved = try self.resolvedChatId(chatId)
        _ = try await self.bot.sendChatAction(
            params: .init(chatId: .chat(resolved), action: action.rawValue)
        )
    }
}
