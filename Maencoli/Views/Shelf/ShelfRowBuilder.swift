import Foundation
import CoreGraphics

/// Greedily wraps shelf items into rows that fit a given width, so the shelf
/// grows taller (more rows) as more books/highlights are added — the MVP
/// stand-in for "작은 책장 -> 큰 책장" progression.
enum ShelfRowBuilder {
    static func rows(for items: [ShelfItem], rowWidth: CGFloat, spacing: CGFloat) -> [[ShelfItem]] {
        guard rowWidth > 0 else { return items.isEmpty ? [] : [items] }

        var rows: [[ShelfItem]] = []
        var current: [ShelfItem] = []
        var currentWidth: CGFloat = 0

        for item in items {
            let itemWidth = item.spineWidth
            if currentWidth + itemWidth + spacing > rowWidth, !current.isEmpty {
                rows.append(current)
                current = []
                currentWidth = 0
            }
            current.append(item)
            currentWidth += itemWidth + spacing
        }
        if !current.isEmpty {
            rows.append(current)
        }
        return rows
    }
}
