import SwiftUI

/// View-level wrapper around either a real Book or an unassigned ISO-week
/// group of highlights, so the shelf can render both as spines uniformly.
struct ShelfItem: Identifiable {
    enum Kind {
        case book(Book)
        case weekGroup(key: String, highlights: [Highlight])
    }

    let id: String
    let kind: Kind
    let title: String
    let spineWidth: CGFloat
    let spineColor: Color

    static func book(_ book: Book) -> ShelfItem {
        ShelfItem(
            id: "book-\(book.id.uuidString)",
            kind: .book(book),
            title: book.title,
            spineWidth: SpineWidthCalculator.width(forPageCount: book.pageCount),
            spineColor: SpineColor.color(for: book.title)
        )
    }

    static func weekGroup(key: String, title: String, highlights: [Highlight]) -> ShelfItem {
        ShelfItem(
            id: "week-\(key)",
            kind: .weekGroup(key: key, highlights: highlights),
            title: title,
            spineWidth: SpineWidthCalculator.width(forHighlightCount: highlights.count),
            spineColor: SpineColor.color(for: key)
        )
    }
}

enum SpineColor {
    private static let palette: [Color] = [.brown, .indigo, .teal, .orange, .purple, .pink, .mint, .cyan]

    static func color(for seed: String) -> Color {
        let hash = abs(seed.hashValue)
        return palette[hash % palette.count]
    }
}
