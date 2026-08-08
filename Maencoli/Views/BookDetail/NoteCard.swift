import SwiftUI

/// A book-level memo with no linked highlight (created via "메모만 남기기",
/// or left behind after its highlight was deleted).
struct NoteCard: View {
    @Bindable var note: Note
    @State private var showEdit = false

    var body: some View {
        MemoBubble(text: note.text, date: note.createdAt) { showEdit = true }
            .sheet(isPresented: $showEdit) {
                EditNoteSheet(mode: .editExisting(note))
            }
    }
}
