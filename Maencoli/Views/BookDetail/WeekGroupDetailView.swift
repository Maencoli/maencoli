import SwiftUI
import SwiftData

/// Detail screen for highlights that haven't been linked to a book yet,
/// grouped by the ISO week they were saved in (spec 3.1/4: weekly "가짜 책").
struct WeekGroupDetailView: View {
    let groupKey: String
    let title: String

    @Query private var allUnassigned: [Highlight]
    @State private var showAssignBook = false

    init(groupKey: String, title: String) {
        self.groupKey = groupKey
        self.title = title
        _allUnassigned = Query(filter: #Predicate<Highlight> { $0.book == nil })
    }

    private var highlights: [Highlight] {
        allUnassigned
            .filter { ISOWeekHelper.groupKey(for: $0.createdAt) == groupKey }
            .sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        List {
            Section {
                Text(title).font(.title2.bold())
                Text("아직 책으로 연결되지 않은 하이라이트예요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("책으로 연결하기") {
                    showAssignBook = true
                }
            }

            Section("저장한 문장 (\(highlights.count))") {
                ForEach(highlights) { highlight in
                    HighlightRow(highlight: highlight)
                }
            }
        }
        .navigationTitle("주간 기록")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAssignBook) {
            NavigationStack {
                AssignBookView { book in
                    guard let book else {
                        showAssignBook = false
                        return
                    }
                    for highlight in highlights {
                        highlight.book = book
                    }
                    showAssignBook = false
                }
            }
        }
    }
}
