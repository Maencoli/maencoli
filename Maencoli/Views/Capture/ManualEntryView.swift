import SwiftUI
import SwiftData

/// "직접 입력" — a single quote typed by hand, no photo/OCR involved.
struct ManualEntryView: View {
    var preselectedBook: Book?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedBook: Book?
    @State private var quote = ""
    @State private var memo = ""
    @State private var pageText = ""
    @State private var showBookPicker = false
    @State private var showDiscardConfirm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        BookChipView(book: selectedBook) { showBookPicker = true }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("인용 문장").font(.caption).foregroundStyle(.secondary)
                            TextEditor(text: $quote)
                                .frame(minHeight: 100)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)))
                        }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("메모 (선택)").font(.caption).foregroundStyle(.secondary)
                            TextEditor(text: $memo)
                                .frame(minHeight: 70)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)))
                        }

                        HStack {
                            Text("페이지")
                            TextField("예: 42", text: $pageText)
                                .keyboardType(.numberPad)
                                .textFieldStyle(.roundedBorder)
                                .frame(width: 80)
                            Spacer()
                        }
                    }
                    .padding()
                }

                Divider()
                Button("저장", action: save)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .disabled(quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
            }
            .navigationTitle("직접 입력")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", action: attemptCancel)
                }
            }
            .alert("지금까지 담은 내용이 사라져요", isPresented: $showDiscardConfirm) {
                Button("계속 편집", role: .cancel) {}
                Button("나가기", role: .destructive) { dismiss() }
            } message: {
                Text("입력한 내용이 저장되지 않고 사라집니다. 나갈까요?")
            }
            .sheet(isPresented: $showBookPicker) {
                BookPickerView(selectedBook: $selectedBook)
            }
        }
        .onAppear { selectedBook = preselectedBook }
    }

    private func attemptCancel() {
        if quote.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            dismiss()
        } else {
            showDiscardConfirm = true
        }
    }

    private func save() {
        let trimmedQuote = quote.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedQuote.isEmpty else { return }

        let highlight = Highlight(
            text: trimmedQuote,
            pageNumber: Int(pageText),
            isPageNumberManuallyEdited: !pageText.isEmpty,
            book: selectedBook
        )
        modelContext.insert(highlight)

        let trimmedMemo = memo.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedMemo.isEmpty {
            let note = Note(text: trimmedMemo, book: selectedBook, highlight: highlight)
            modelContext.insert(note)
        }
        dismiss()
    }
}
