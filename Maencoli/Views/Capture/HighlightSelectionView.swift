import SwiftUI
import UIKit

/// Step 2 of the photo capture flow: review/fix OCR'd text, select sentences
/// to highlight (spec 3), confirm/edit the page number, and pick the book —
/// all before an explicit "저장" commits anything.
struct HighlightSelectionView: View {
    @Bindable var draft: CaptureDraft
    var recognitionError: String?
    var onSave: () -> Void

    @State private var pageText: String = ""
    @State private var selectedText: String = ""
    @State private var showBookPicker = false

    var body: some View {
        VStack(spacing: 0) {
            ScrollView {
                VStack(alignment: .leading, spacing: 14) {
                    if let image = draft.image {
                        Image(uiImage: image)
                            .resizable()
                            .scaledToFit()
                            .frame(maxHeight: 140)
                            .clipShape(RoundedRectangle(cornerRadius: 8))
                    }

                    BookChipView(book: draft.selectedBook) { showBookPicker = true }

                    if let recognitionError {
                        Text(recognitionError)
                            .font(.caption)
                            .foregroundStyle(.orange)
                    }

                    HStack {
                        Text("페이지")
                        TextField("예: 42", text: $draft.pageNumberText)
                            .keyboardType(.numberPad)
                            .textFieldStyle(.roundedBorder)
                            .frame(width: 80)
                            .onChange(of: draft.pageNumberText) { _, _ in
                                draft.isPageNumberManuallyEdited = true
                            }
                        Spacer()
                    }

                    Text("문장을 드래그해서 선택한 뒤 추가 버튼을 누르세요. 인식이 잘못된 부분은 직접 고칠 수 있어요.")
                        .font(.caption)
                        .foregroundStyle(.secondary)

                    SelectableTextView(text: $pageText, selectedText: $selectedText)
                        .frame(minHeight: 180)
                        .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)))

                    Button("선택한 문장 하이라이트로 추가") { addSelectedHighlight() }
                        .disabled(selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                    ForEach($draft.pendingHighlights) { pendingBinding in
                        PendingHighlightCard(pending: pendingBinding) {
                            draft.pendingHighlights.removeAll { $0.id == pendingBinding.wrappedValue.id }
                        }
                    }
                }
                .padding()
            }

            Divider()
            VStack(spacing: 8) {
                Text(footerHint)
                    .font(.caption)
                    .foregroundStyle(.secondary)
                Button("저장", action: onSave)
                    .buttonStyle(.borderedProminent)
                    .frame(maxWidth: .infinity)
                    .disabled(draft.pendingHighlights.isEmpty)
            }
            .padding()
        }
        .onAppear { pageText = draft.recognition?.fullText ?? "" }
        .sheet(isPresented: $showBookPicker) {
            BookPickerView(selectedBook: $draft.selectedBook)
        }
    }

    private var footerHint: String {
        let count = draft.pendingHighlights.count
        guard count > 0 else { return "하이라이트를 1개 이상 추가해주세요" }
        let destination = draft.selectedBook?.title ?? "이번 주 기록"
        return "하이라이트 \(count)개를 \(destination)에 저장"
    }

    private func addSelectedHighlight() {
        let trimmed = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        draft.pendingHighlights.append(PendingHighlight(quote: trimmed))
        selectedText = ""
    }
}
