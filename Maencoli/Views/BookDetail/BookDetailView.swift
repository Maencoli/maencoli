import SwiftUI
import SwiftData

struct BookDetailView: View {
    @Bindable var book: Book
    @State private var showAddChoice = false
    @State private var pendingAddMode: AddFlowMode?

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
    private var sortedNotes: [Note] {
        book.notes.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        List {
            Section {
                VStack(alignment: .leading, spacing: 4) {
                    if let author = book.author {
                        Text(author).foregroundStyle(.secondary)
                    }
                    if let pageCount = book.pageCount {
                        Text("전체 \(pageCount)쪽").font(.caption).foregroundStyle(.secondary)
                    }
                }
                .padding(.vertical, 4)
            }

            if !sortedHighlights.isEmpty {
                Section("저장한 문장 (\(sortedHighlights.count))") {
                    ForEach(sortedHighlights) { highlight in
                        HighlightCard(highlight: highlight)
                    }
                }
            }

            if !sortedNotes.isEmpty {
                Section("책 메모 (\(sortedNotes.count))") {
                    ForEach(sortedNotes) { note in
                        NoteCard(note: note)
                    }
                }
            }

            if sortedHighlights.isEmpty && sortedNotes.isEmpty {
                ContentUnavailableView("아직 저장된 기록이 없어요", systemImage: "text.quote")
            }
        }
        .navigationTitle(book.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddChoice = true
                } label: {
                    Label("하이라이트 추가", systemImage: "plus")
                }
            }
        }
        .confirmationDialog("\(book.title)에 추가", isPresented: $showAddChoice, titleVisibility: .visible) {
            Button("사진으로 추가") { pendingAddMode = .photo }
            Button("직접 입력하기") { pendingAddMode = .manual }
            Button("메모만 남기기") { pendingAddMode = .memoOnly }
            Button("취소", role: .cancel) {}
        }
        .fullScreenCover(item: $pendingAddMode) { mode in
            switch mode {
            case .photo:
                CaptureFlowView(preselectedBook: book)
            case .manual:
                ManualEntryView(preselectedBook: book)
            case .memoOnly:
                MemoOnlyEntryView(preselectedBook: book)
            case .bookOnly:
                EmptyView()
            }
        }
    }
}
