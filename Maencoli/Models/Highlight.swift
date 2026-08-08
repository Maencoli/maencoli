import Foundation
import SwiftData

@Model
final class Highlight {
    var id: UUID
    var text: String
    var pageNumber: Int?
    var isPageNumberManuallyEdited: Bool
    var createdAt: Date
    var book: Book?

    /// Memos attached to this specific highlight. A highlight can carry several.
    @Relationship(deleteRule: .nullify, inverse: \Note.highlight)
    var notes: [Note] = []

    init(
        text: String,
        pageNumber: Int? = nil,
        isPageNumberManuallyEdited: Bool = false,
        book: Book? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.pageNumber = pageNumber
        self.isPageNumberManuallyEdited = isPageNumberManuallyEdited
        self.createdAt = Date()
        self.book = book
    }
}

extension Highlight {
    /// A memo must always belong to a book or a highlight. When this highlight
    /// is deleted, its memos survive as standalone book memos if it has a book;
    /// otherwise there's no valid parent left, so they're deleted with it.
    func detachNotesBeforeDeletion(context: ModelContext) {
        if book == nil {
            for note in notes { context.delete(note) }
        } else {
            for note in notes { note.highlight = nil }
        }
    }
}
