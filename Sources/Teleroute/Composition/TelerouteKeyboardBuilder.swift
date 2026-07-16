import Foundation
import SwiftTelegramBot

/// A result builder for declaratively constructing inline keyboards.
///
/// Instead of nesting `[[TGInlineKeyboardButton]]` array literals, use
/// ``TelerouteKeyboardBuilder/Row`` blocks and button helpers:
///
/// ```swift
/// let keyboard = try TelerouteKeyboardBuilder.build {
///     try TelerouteKeyboardBuilder.Row {
///         try router.callbackButton("Prev", path: "page", parameters: ["n": "0"])
///         try router.callbackButton("Next", path: "page", parameters: ["n": "2"])
///     }
///     try TelerouteKeyboardBuilder.Row {
///         try router.callbackButton("Cancel", path: "cancel")
///     }
/// }
/// ```
@resultBuilder
public enum TelerouteKeyboardBuilder {
    /// A single keyboard row.
    public struct Row: Sendable {
        let components: [Component]

        /// Creates a row from the buttons produced by the supplied closure.
        public init(
            @TelerouteKeyboardBuilder _ content: () throws -> [Component]
        ) rethrows {
            self.components = try content()
        }
    }

    /// A buildable component: either a single button, a nested row, or a deferred row.
    public enum Component: Sendable {
        case button(TGInlineKeyboardButton)
        case row(Row)
    }

    public static func buildBlock(_ components: [Component]...) -> [Component] {
        components.flatMap { $0 }
    }

    public static func buildExpression(_ button: TGInlineKeyboardButton) -> [Component] {
        [.button(button)]
    }

    public static func buildExpression(_ row: Row) -> [Component] {
        [.row(row)]
    }

    public static func buildOptional(_ component: [Component]?) -> [Component] {
        component ?? []
    }

    public static func buildEither(first: [Component]) -> [Component] {
        first
    }

    public static func buildEither(second: [Component]) -> [Component] {
        second
    }

    public static func buildArray(_ components: [[Component]]) -> [Component] {
        components.flatMap { $0 }
    }

    /// Assembles a keyboard from the supplied builder closure.
    public static func build(
        @TelerouteKeyboardBuilder _ content: () throws -> [Component]
    ) throws -> TGInlineKeyboardMarkup {
        let components = try content()
        var rows: [[TGInlineKeyboardButton]] = []
        var currentRow: [TGInlineKeyboardButton] = []

        func flushRow() {
            if currentRow.isEmpty == false {
                rows.append(currentRow)
                currentRow = []
            }
        }

        func append(_ component: Component) {
            switch component {
            case .button(let button):
                currentRow.append(button)
            case .row(let row):
                flushRow()
                for nested in row.components {
                    append(nested)
                }
                flushRow()
            }
        }

        for component in components {
            append(component)
        }
        flushRow()
        return TGInlineKeyboardMarkup(inlineKeyboard: rows)
    }
}

public extension TelerouteGroup {
    /// Builds an inline keyboard using a declarative result-builder closure.
    func callbackKeyboard(
        @TelerouteKeyboardBuilder _ content: () throws -> [TelerouteKeyboardBuilder.Component]
    ) throws -> TGInlineKeyboardMarkup {
        try TelerouteKeyboardBuilder.build(content)
    }
}

public extension Teleroute {
    /// Builds an inline keyboard using a declarative result-builder closure.
    func callbackKeyboard(
        @TelerouteKeyboardBuilder _ content: () throws -> [TelerouteKeyboardBuilder.Component]
    ) throws -> TGInlineKeyboardMarkup {
        try self.rootGroup.callbackKeyboard(content)
    }
}

/// Pagination helpers for inline keyboards backed by callback routes.
public enum TeleroutePagination {
    /// Builds a prev/next navigation row for the given page path.
    ///
    /// - Parameters:
    ///   - path: Callback route path, e.g. `"list"`.
    ///   - page: Zero-based current page index.
    ///   - pageCount: Total number of pages. `Prev` is omitted on the first
    ///     page and `Next` on the last.
    ///   - previousLabel / nextLabel: Button text. Defaults to `"◀︎ Prev"` / `"Next ▶︎"`.
    public static func navigationRow(
        path: String,
        page: Int,
        pageCount: Int,
        previousLabel: String = "◀︎ Prev",
        nextLabel: String = "Next ▶︎",
        makeButton: (String, String, [String: String]) throws -> TGInlineKeyboardButton
    ) rethrows -> [TGInlineKeyboardButton] {
        var buttons: [TGInlineKeyboardButton] = []
        if page > 0 {
            buttons.append(try makeButton(previousLabel, path, ["page": String(page - 1)]))
        }
        if page < pageCount - 1 {
            buttons.append(try makeButton(nextLabel, path, ["page": String(page + 1)]))
        }
        return buttons
    }
}
