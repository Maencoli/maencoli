import SwiftUI
import SwiftData

/// "책만 등록하기" — registers a book with no highlight or memo attached.
/// Only offered from the home screen (a book's own detail screen already has
/// a book, so this option doesn't apply there).
struct BookOnlyEntryView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @Query private var books: [Book]

    @State private var title = ""
    @State private var author = ""
    @State private var pageCountText = ""
    @State private var showDiscardConfirm = false
    @State private var showDuplicateWarning = false

    var body: some View {
        NavigationStack {
            Form {
                Section {
                    TextField("책 제목", text: $title)
                    TextField("저자 (선택)", text: $author)
                    TextField("전체 페이지 수 (선택)", text: $pageCountText)
                        .keyboardType(.numberPad)
                } footer: {
                    Text("하이라이트나 메모 없이 책만 먼저 책장에 꽂아둘 수 있어요. 나중에 책 상세에서 추가하면 돼요.")
                }
            }
            .navigationTitle("책 등록")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", action: attemptCancel)
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("책 저장", action: save)
                        .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
            .alert("이미 있는 책이에요", isPresented: $showDuplicateWarning) {
                Button("확인", role: .cancel) {}
            }
            .alert("지금까지 입력한 내용이 사라져요", isPresented: $showDiscardConfirm) {
                Button("계속 편집", role: .cancel) {}
                Button("나가기", role: .destructive) { dismiss() }
            }
        }
    }

    private func attemptCancel() {
        if title.trimmingCharacters(in: .whitespaces).isEmpty {
            dismiss()
        } else {
            showDiscardConfirm = true
        }
    }

    private func save() {
        let trimmedTitle = title.trimmingCharacters(in: .whitespaces)
        guard !trimmedTitle.isEmpty else { return }
        guard !books.contains(where: { $0.title == trimmedTitle }) else {
            showDuplicateWarning = true
            return
        }
        let book = Book(
            title: trimmedTitle,
            author: author.isEmpty ? nil : author,
            pageCount: Int(pageCountText),
            addedManually: true
        )
        modelContext.insert(book)
        dismiss()
    }
}
