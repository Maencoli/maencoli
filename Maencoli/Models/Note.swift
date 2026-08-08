import Foundation
import SwiftData

/// A memo. It must always belong to a book, a highlight, or both — never neither
/// (enforced by the UI, not the schema: memo-only entry requires a book to be
/// picked first, and a highlight's memo mirrors the highlight's book if it has one).
@Model
final class Note {
    var id: UUID
    var text: String
    var createdAt: Date
    var pageNumber: Int?
    var book: Book?
    var highlight: Highlight?

    init(
        text: String,
        pageNumber: Int? = nil,
        book: Book? = nil,
        highlight: Highlight? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.createdAt = Date()
        self.pageNumber = pageNumber
        self.book = book
        self.highlight = highlight
    }
}
