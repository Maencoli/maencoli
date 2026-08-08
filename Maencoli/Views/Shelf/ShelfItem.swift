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
    let spineGradient: Gradient

    static func book(_ book: Book) -> ShelfItem {
        ShelfItem(
            id: "book-\(book.id.uuidString)",
            kind: .book(book),
            title: book.title,
            spineWidth: SpineWidthCalculator.width(forPageCount: book.pageCount),
            spineGradient: SpineColor.gradient(for: book.title)
        )
    }

    static func weekGroup(key: String, title: String, highlights: [Highlight]) -> ShelfItem {
        ShelfItem(
            id: "week-\(key)",
            kind: .weekGroup(key: key, highlights: highlights),
            title: title,
            spineWidth: SpineWidthCalculator.width(forHighlightCount: highlights.count),
            spineGradient: SpineColor.weekGroupGradient
        )
    }
}

/// Spine colors, matching the reference palette (vivid, distinct hues rather
/// than muted jewel tones) — book-only, unrelated to the highlighter/UI accent.
enum SpineColor {
    private static let palette: [(Color, Color)] = [
        (Color(hex: 0x00AAEE), Color(hex: 0x0577A3)), // cerulean
        (Color(hex: 0xD9381E), Color(hex: 0xA12912)), // vermillion
        (Color(hex: 0xF4C430), Color(hex: 0xB8860B)), // saffron
        (Color(hex: 0xF04894), Color(hex: 0xB8306E)), // rose
        (Color(hex: 0x8BCC65), Color(hex: 0x5F9A3F)), // spring green
        (Color(hex: 0x29BDCF), Color(hex: 0x1A8B99)), // lake blue
        (Color(hex: 0x009698), Color(hex: 0x026E6F)), // viridian teal
        (Color(hex: 0x055983), Color(hex: 0x033B57)), // sapphire navy
    ]

    /// Neutral "pewter" tone for the not-yet-assigned weekly group, so it
    /// reads as distinct from every real, named book on the shelf.
    static let weekGroupGradient = Gradient(colors: [Color(hex: 0xB7AF9C), Color(hex: 0x9D9483)])

    static func gradient(for seed: String) -> Gradient {
        let pair = palette[abs(seed.hashValue) % palette.count]
        return Gradient(colors: [pair.0, pair.1])
    }
}

extension Color {
    init(hex: UInt32) {
        self.init(
            red: Double((hex >> 16) & 0xFF) / 255,
            green: Double((hex >> 8) & 0xFF) / 255,
            blue: Double(hex & 0xFF) / 255
        )
    }
}
