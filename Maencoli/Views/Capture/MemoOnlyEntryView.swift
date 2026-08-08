import SwiftUI
import SwiftData

/// "메모만 남기기" — only reachable from a book's detail screen. A memo must
/// always belong to a book or a highlight, so saving stays disabled until a
/// real book is picked; there's no "이번 주 기록" fallback here.
struct MemoOnlyEntryView: View {
    var preselectedBook: Book?

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var selectedBook: Book?
    @State private var text = ""
    @State private var pageText = ""
    @State private var showBookPicker = false
    @State private var showDiscardConfirm = false

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ScrollView {
                    VStack(alignment: .leading, spacing: 14) {
                        BookChipView(book: selectedBook, requiresBook: true) { showBookPicker = true }

                        VStack(alignment: .leading, spacing: 6) {
                            Text("메모").font(.caption).foregroundStyle(.secondary)
                            TextEditor(text: $text)
                                .frame(minHeight: 140)
                                .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)))
                        }

                        HStack {
                            Text("페이지 (선택)")
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
                VStack(spacing: 8) {
                    Text(footerHint)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Button("저장", action: save)
                        .buttonStyle(.borderedProminent)
                        .frame(maxWidth: .infinity)
                        .disabled(!canSave)
                }
                .padding()
            }
            .navigationTitle("메모만 남기기")
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
                Text("입력한 메모가 저장되지 않고 사라집니다. 나갈까요?")
            }
            .sheet(isPresented: $showBookPicker) {
                BookPickerView(selectedBook: $selectedBook)
            }
        }
        .onAppear { selectedBook = preselectedBook }
    }

    private var trimmedText: String { text.trimmingCharacters(in: .whitespacesAndNewlines) }
    private var canSave: Bool { selectedBook != nil && !trimmedText.isEmpty }

    private var footerHint: String {
        if selectedBook == nil { return "메모를 저장하려면 먼저 책을 선택해주세요" }
        if trimmedText.isEmpty { return "메모 내용을 입력해주세요" }
        return "\"\(selectedBook?.title ?? "")\"에 메모 저장"
    }

    private func attemptCancel() {
        if trimmedText.isEmpty {
            dismiss()
        } else {
            showDiscardConfirm = true
        }
    }

    private func save() {
        guard canSave, let selectedBook else { return }
        let note = Note(text: trimmedText, pageNumber: Int(pageText), book: selectedBook)
        modelContext.insert(note)
        dismiss()
    }
}
