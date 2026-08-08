import SwiftUI
import SwiftData

/// One saved highlight plus its (possibly several) memos. Tapping the quote
/// offers 수정/메모 추가/삭제; tapping a memo edits just that memo.
struct HighlightCard: View {
    @Bindable var highlight: Highlight
    @Environment(\.modelContext) private var modelContext

    @State private var showActions = false
    @State private var showEditQuote = false
    @State private var showAddMemo = false
    @State private var showDeleteConfirm = false
    @State private var editingNote: Note?

    private var sortedNotes: [Note] {
        highlight.notes.sorted { $0.createdAt < $1.createdAt }
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(highlight.text)
                .font(.body)
                .padding(.leading, 10)
                .overlay(alignment: .leading) {
                    Rectangle().fill(Color.accentColor).frame(width: 3)
                }
                .contentShape(Rectangle())
                .onTapGesture { showActions = true }

            Text(highlight.pageNumber.map { "\($0)쪽" } ?? "페이지 미정")
                .font(.caption)
                .foregroundStyle(.secondary)

            ForEach(sortedNotes) { note in
                MemoBubble(text: note.text, date: note.createdAt) { editingNote = note }
            }
        }
        .padding(.vertical, 4)
        .confirmationDialog("하이라이트", isPresented: $showActions, titleVisibility: .visible) {
            Button("하이라이트 수정") { showEditQuote = true }
            Button("메모 추가") { showAddMemo = true }
            Button("하이라이트 삭제", role: .destructive) { showDeleteConfirm = true }
            Button("취소", role: .cancel) {}
        }
        .alert("하이라이트를 삭제할까요?", isPresented: $showDeleteConfirm) {
            Button("취소", role: .cancel) {}
            Button("삭제", role: .destructive, action: delete)
        } message: {
            Text(deleteMessage)
        }
        .sheet(isPresented: $showEditQuote) {
            EditHighlightSheet(highlight: highlight)
        }
        .sheet(isPresented: $showAddMemo) {
            EditNoteSheet(mode: .createForHighlight(highlight))
        }
        .sheet(item: $editingNote) { note in
            EditNoteSheet(mode: .editExisting(note))
        }
    }

    private var deleteMessage: String {
        guard !highlight.notes.isEmpty else { return "삭제하면 되돌릴 수 없어요." }
        if highlight.book != nil {
            return "하이라이트만 삭제되고, 메모 \(highlight.notes.count)개는 이 책의 메모로 남아있어요."
        } else {
            return "아직 책과 연결되지 않아서, 딸린 메모 \(highlight.notes.count)개도 하이라이트와 함께 삭제돼요. 메모를 남기려면 먼저 책을 연결해주세요."
        }
    }

    private func delete() {
        highlight.detachNotesBeforeDeletion(context: modelContext)
        modelContext.delete(highlight)
    }
}
