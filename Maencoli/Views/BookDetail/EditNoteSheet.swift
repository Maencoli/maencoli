import SwiftUI
import SwiftData

enum EditNoteMode {
    case createForHighlight(Highlight)
    case editExisting(Note)
}

/// Adds a new memo to a highlight, or edits/deletes an existing memo
/// (highlight-attached or a book's standalone memo — same editor either way).
struct EditNoteSheet: View {
    let mode: EditNoteMode

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var text: String = ""

    private var isExisting: Bool {
        if case .editExisting = mode { return true }
        return false
    }

    var body: some View {
        NavigationStack {
            Form {
                Section("메모") {
                    TextEditor(text: $text).frame(minHeight: 120)
                }
            }
            .navigationTitle(isExisting ? "메모 수정" : "메모 추가")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                if isExisting {
                    ToolbarItem(placement: .destructiveAction) {
                        Button("삭제", role: .destructive, action: deleteNote)
                    }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: save)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                if case .editExisting(let note) = mode {
                    text = note.text
                }
            }
        }
    }

    private func save() {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        switch mode {
        case .createForHighlight(let highlight):
            let note = Note(text: trimmed, book: highlight.book, highlight: highlight)
            modelContext.insert(note)
        case .editExisting(let note):
            note.text = trimmed
        }
        dismiss()
    }

    private func deleteNote() {
        if case .editExisting(let note) = mode {
            modelContext.delete(note)
        }
        dismiss()
    }
}
