import Foundation
import SwiftData

@Model
final class Book {
    var id: UUID
    var title: String
    var author: String?
    var isbn: String?
    var pageCount: Int?
    var coverImageURLString: String?
    var addedManually: Bool
    var createdAt: Date

    @Relationship(deleteRule: .cascade, inverse: \Highlight.book)
    var highlights: [Highlight] = []

    /// Memos attached directly to this book (no specific highlight) — created via
    /// the book-detail-only "메모만 남기기" flow, or left behind when a highlight
    /// that had memos is deleted.
    @Relationship(deleteRule: .cascade, inverse: \Note.book)
    var notes: [Note] = []

    init(
        title: String,
        author: String? = nil,
        isbn: String? = nil,
        pageCount: Int? = nil,
        coverImageURLString: String? = nil,
        addedManually: Bool = false
    ) {
        self.id = UUID()
        self.title = title
        self.author = author
        self.isbn = isbn
        self.pageCount = pageCount
        self.coverImageURLString = coverImageURLString
        self.addedManually = addedManually
        self.createdAt = Date()
    }
}
