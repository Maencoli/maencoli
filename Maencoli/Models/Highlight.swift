import Foundation
import SwiftData

@Model
final class Highlight {
    var id: UUID
    var text: String
    var pageNumber: Int?
    var isPageNumberManuallyEdited: Bool
    var photoRelativePath: String?
    var createdAt: Date
    var book: Book?

    init(
        text: String,
        pageNumber: Int? = nil,
        isPageNumberManuallyEdited: Bool = false,
        photoRelativePath: String? = nil,
        book: Book? = nil
    ) {
        self.id = UUID()
        self.text = text
        self.pageNumber = pageNumber
        self.isPageNumberManuallyEdited = isPageNumberManuallyEdited
        self.photoRelativePath = photoRelativePath
        self.createdAt = Date()
        self.book = book
    }
}
