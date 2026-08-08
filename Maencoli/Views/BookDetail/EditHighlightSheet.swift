import SwiftUI

/// Edits an existing highlight's quote text and page number in place.
struct EditHighlightSheet: View {
    @Bindable var highlight: Highlight
    @Environment(\.dismiss) private var dismiss

    @State private var text: String = ""
    @State private var pageText: String = ""

    var body: some View {
        NavigationStack {
            Form {
                Section("인용 문장") {
                    TextEditor(text: $text).frame(minHeight: 100)
                }
                Section("페이지") {
                    TextField("페이지 번호", text: $pageText)
                        .keyboardType(.numberPad)
                }
            }
            .navigationTitle("하이라이트 수정")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장", action: save)
                        .disabled(text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)
                }
            }
            .onAppear {
                text = highlight.text
                pageText = highlight.pageNumber.map(String.init) ?? ""
            }
        }
    }

    private func save() {
        highlight.text = text.trimmingCharacters(in: .whitespacesAndNewlines)
        highlight.pageNumber = Int(pageText)
        highlight.isPageNumberManuallyEdited = true
        dismiss()
    }
}
