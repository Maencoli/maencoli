import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Bindable var book: Book
    @Environment(\.modelContext) private var modelContext

    private var sortedHighlights: [Highlight] {
        book.highlights.sorted {
            switch ($0.pageNumber, $1.pageNumber) {
            case let (l?, r?): return l != r ? l < r : $0.createdAt < $1.createdAt
            case (nil, nil): return $0.createdAt < $1.createdAt
            case (nil, _): return false
            case (_, nil): return true
            }
        }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    Text(book.title).font(.title2.bold())
                    if let author = book.author {
                        Text(author).foregroundStyle(.secondary)
                    }
                    if let pageCount = book.pageCount {
                        Text("전체 \(pageCount)쪽").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            Section("저장한 문장 (\(sortedHighlights.count))") {
                ForEach(sortedHighlights) { highlight in
                    HighlightRow(highlight: highlight)
                }
                .onDelete(perform: delete)
            }
        }
        .navigationTitle("책 정보")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func delete(at offsets: IndexSet) {
        for index in offsets {
            modelContext.delete(sortedHighlights[index])
        }
    }
}
