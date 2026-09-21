import Foundation
import TelegramBotAPI

// MARK: - Laying buttons out in rows

public extension Array where Element == TelerouteButton {
    /// Splits a flat list of buttons into rows of at most `columns` buttons,
    /// which is how list-style menus are usually laid out:
    ///
    /// ```swift
    /// let markup = try context.keyboard {
    ///     orders.map { route.button(Open(id: $0.id), $0.title) }.grid(columns: 2)
    ///     Row { TelerouteButton.url("Help", helpURL) }
    /// }
    /// ```
    ///
    /// - Parameter columns: Buttons per row. Values below 1 are treated as 1.
    func grid(columns: Int) -> [[TelerouteButton]] {
        let width = Swift.max(1, columns)
        return stride(from: 0, to: self.count, by: width).map { start in
            Array(self[start..<Swift.min(start + width, self.count)])
        }
    }
}

// MARK: - Pagination

public extension TeleroutePagination {
    /// Builds a previous/next row with a non-interactive `3 / 10` counter
    /// between the arrows.
    ///
    /// Unlike ``navigationRow(_:page:pageCount:previousLabel:nextLabel:callback:)``
    /// the row keeps a stable width: edge pages get a disabled placeholder
    /// where the missing arrow would be, so the buttons do not jump around as
    /// the user pages through.
    static func navigationRow<Callback: TelerouteCallback>(
        _ route: TelerouteCallbackRoute<Callback>,
        page: Int,
        pageCount: Int,
        counter: Bool,
        previousLabel: String = "◀︎",
        nextLabel: String = "▶︎",
        callback: (Int) -> Callback
    ) -> [TelerouteButton] {
        guard counter else {
            return self.navigationRow(
                route,
                page: page,
                pageCount: pageCount,
                previousLabel: previousLabel,
                nextLabel: nextLabel,
                callback: callback
            )
        }
        var buttons: [TelerouteButton] = []
        buttons.append(
            page > 0
                ? route.button(callback(page - 1), previousLabel)
                : .disabled("·")
        )
        buttons.append(.disabled("\(page + 1) / \(Swift.max(pageCount, 1))"))
        buttons.append(
            page < pageCount - 1
                ? route.button(callback(page + 1), nextLabel)
                : .disabled("·")
        )
        return buttons
    }

    /// Builds a strip of page-number buttons windowed around the current page,
    /// with the current page shown as a disabled marker:
    ///
    /// ```text
    /// 1 · … · 4 · [5] · 6 · … · 20
    /// ```
    ///
    /// - Parameters:
    ///   - route: Route handle the page buttons dispatch to.
    ///   - page: Zero-based index of the current page.
    ///   - pageCount: Total number of pages; fewer than two renders nothing.
    ///   - window: How many pages to show on either side of the current one.
    ///   - ellipsis: Label for the gap buttons; they are disabled.
    ///   - callback: Builds the callback value for a given page index.
    static func pageStrip<Callback: TelerouteCallback>(
        _ route: TelerouteCallbackRoute<Callback>,
        page: Int,
        pageCount: Int,
        window: Int = 2,
        ellipsis: String = "…",
        callback: (Int) -> Callback
    ) -> [TelerouteButton] {
        guard pageCount > 1 else { return [] }
        let current = Swift.min(Swift.max(page, 0), pageCount - 1)
        let radius = Swift.max(0, window)
        let lastIndex = pageCount - 1

        var indices: Set<Int> = [0, lastIndex, current]
        indices.formUnion((current - radius)...(current + radius))
        let visible = indices.filter { (0...lastIndex).contains($0) }.sorted()

        var buttons: [TelerouteButton] = []
        var previous: Int?
        for index in visible {
            if let previous, index - previous > 1 {
                buttons.append(.disabled(ellipsis))
            }
            buttons.append(
                index == current
                    ? .disabled("· \(index + 1) ·")
                    : route.button(callback(index), "\(index + 1)")
            )
            previous = index
        }
        return buttons
    }
}

// MARK: - Confirmation

/// Yes/no confirmation rows built from typed callback routes.
public enum TelerouteConfirm {
    /// Builds a two-button confirm/cancel row from one route.
    ///
    /// ```swift
    /// let route = router.callback(DeleteOrder.self) { callback, context in … }
    ///
    /// router.command("delete") { _ in
    ///     Reply("Delete order 7?").keyboard {
    ///         Row {
    ///             TelerouteConfirm.row(
    ///                 route,
    ///                 confirm: DeleteOrder(id: "7", confirmed: true),
    ///                 cancel: DeleteOrder(id: "7", confirmed: false)
    ///             )
    ///         }
    ///     }
    /// }
    /// ```
    public static func row<Callback: TelerouteCallback>(
        _ route: TelerouteCallbackRoute<Callback>,
        confirm: Callback,
        confirmLabel: String = "✅ Yes",
        cancel: Callback,
        cancelLabel: String = "❌ No"
    ) -> [TelerouteButton] {
        [
            route.button(confirm, confirmLabel, style: .success),
            route.button(cancel, cancelLabel, style: .danger),
        ]
    }

    /// Builds a confirm/cancel row whose two sides live on different routes.
    public static func row<Confirm: TelerouteCallback, Cancel: TelerouteCallback>(
        confirm: TelerouteCallbackRoute<Confirm>,
        _ confirmCallback: Confirm,
        confirmLabel: String = "✅ Yes",
        cancel: TelerouteCallbackRoute<Cancel>,
        _ cancelCallback: Cancel,
        cancelLabel: String = "❌ No"
    ) -> [TelerouteButton] {
        [
            confirm.button(confirmCallback, confirmLabel, style: .success),
            cancel.button(cancelCallback, cancelLabel, style: .danger),
        ]
    }
}
