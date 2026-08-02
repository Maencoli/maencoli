import SwiftUI
import UIKit

/// Step 2 of the capture flow: review/fix OCR'd text, select sentences to
/// highlight (spec 3), and confirm/edit the page number (spec 3.1-3.3).
struct HighlightSelectionView: View {
    @Bindable var draft: CaptureDraft
    var onNext: () -> Void

    @State private var pageText: String = ""
    @State private var selectedText: String = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 12) {
                if let image = draft.image {
                    Image(uiImage: image)
                        .resizable()
                        .scaledToFit()
                        .frame(maxHeight: 140)
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }

                HStack {
                    Text("페이지 번호")
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
                    .frame(minHeight: 200)
                    .overlay(RoundedRectangle(cornerRadius: 8).stroke(.secondary.opacity(0.3)))

                Button("선택한 문장 하이라이트로 추가") {
                    addSelectedHighlight()
                }
                .disabled(selectedText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty)

                if !draft.pendingHighlightTexts.isEmpty {
                    Text("추가된 하이라이트 (\(draft.pendingHighlightTexts.count))")
                        .font(.headline)
                    VStack(alignment: .leading, spacing: 8) {
                        ForEach(Array(draft.pendingHighlightTexts.enumerated()), id: \.offset) { index, text in
                            HStack(alignment: .top) {
                                Text(text).font(.callout)
                                Spacer()
                                Button {
                                    draft.pendingHighlightTexts.remove(at: index)
                                } label: {
                                    Image(systemName: "xmark.circle.fill")
                                        .foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }

                Button("다음") { onNext() }
                    .buttonStyle(.borderedProminent)
                    .disabled(draft.pendingHighlightTexts.isEmpty)
                    .frame(maxWidth: .infinity)
            }
            .padding()
        }
        .onAppear {
            pageText = draft.recognition?.fullText ?? ""
        }
    }

    private func addSelectedHighlight() {
        let trimmed = selectedText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        draft.pendingHighlightTexts.append(trimmed)
        selectedText = ""
    }
}
