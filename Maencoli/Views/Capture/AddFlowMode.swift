import Foundation

/// The four ways a highlight/memo/book can be added, offered contextually:
/// home shows photo/manual/bookOnly, a book's detail screen shows
/// photo/manual/memoOnly (see BookshelfView / BookDetailView / WeekGroupDetailView).
enum AddFlowMode: Identifiable, Hashable {
    case photo, manual, memoOnly, bookOnly

    var id: Self { self }
}
