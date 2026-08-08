import SwiftUI
import SwiftData

/// Detail screen for highlights that haven't been linked to a book yet,
/// grouped by the ISO week they were saved in (spec 3.1/4: weekly "가짜 책").
/// No "메모만 남기기" or "책만 등록하기" here — those only make sense with a
/// real, named book already selected.
struct WeekGroupDetailView: View {
    let groupKey: String
    let title: String

    @Query private var allUnassigned: [Highlight]
    @State private var showAddChoice = false
    @State private var pendingAddMode: AddFlowMode?
    @State private var showMergePicker = false
    @State private var mergeTargetBook: Book?

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
                Text("아직 책으로 연결되지 않은 하이라이트예요.")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("책으로 연결하기") { showMergePicker = true }
            }

            if highlights.isEmpty {
                ContentUnavailableView("아직 저장된 기록이 없어요", systemImage: "text.quote")
            } else {
                Section("저장한 문장 (\(highlights.count))") {
                    ForEach(highlights) { highlight in
                        HighlightCard(highlight: highlight)
                    }
                }
            }
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showAddChoice = true
                } label: {
                    Label("추가", systemImage: "plus")
                }
            }
        }
        .confirmationDialog("새 하이라이트", isPresented: $showAddChoice, titleVisibility: .visible) {
            Button("사진으로 추가") { pendingAddMode = .photo }
            Button("직접 입력하기") { pendingAddMode = .manual }
            Button("취소", role: .cancel) {}
        }
        .fullScreenCover(item: $pendingAddMode) { mode in
            switch mode {
            case .photo:
                CaptureFlowView(preselectedBook: nil)
            case .manual:
                ManualEntryView(preselectedBook: nil)
            case .memoOnly, .bookOnly:
                EmptyView()
            }
        }
        .sheet(isPresented: $showMergePicker) {
            BookPickerView(selectedBook: $mergeTargetBook)
        }
        .onChange(of: mergeTargetBook) { _, newBook in
            guard let newBook else { return }
            for highlight in highlights {
                highlight.book = newBook
                for note in highlight.notes { note.book = newBook }
            }
            mergeTargetBook = nil
        }
    }
}
