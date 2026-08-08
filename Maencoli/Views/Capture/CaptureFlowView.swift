import SwiftUI
import SwiftData
import UIKit

/// Photo capture flow: 촬영 -> OCR -> 문장 선택/메모/책 연결 -> 저장.
/// `preselectedBook` pre-fills the book chip when launched from a book's
/// detail screen; it stays editable via the chip either way.
struct CaptureFlowView: View {
    var preselectedBook: Book?

    private enum Step {
        case capture, recognizing, compose
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var draft = CaptureDraft()
    @State private var step: Step = .capture
    @State private var recognitionError: String?
    @State private var showDiscardConfirm = false

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .capture:
                    CameraCaptureView(
                        onCapture: { image in
                            draft.image = image
                            recognize(image)
                        },
                        onCancel: { dismiss() }
                    )
                case .recognizing:
                    ProgressView("텍스트를 인식하는 중...")
                case .compose:
                    HighlightSelectionView(draft: draft, recognitionError: recognitionError, onSave: save)
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소", action: attemptCancel)
                }
            }
            .alert("지금까지 담은 내용이 사라져요", isPresented: $showDiscardConfirm) {
                Button("계속 편집", role: .cancel) {}
                Button("나가기", role: .destructive) { dismiss() }
            } message: {
                Text("하이라이트 \(draft.pendingHighlights.count)개가 저장되지 않고 사라집니다. 나갈까요?")
            }
        }
        .onAppear {
            draft.selectedBook = preselectedBook
        }
    }

    private func attemptCancel() {
        if draft.pendingHighlights.isEmpty {
            dismiss()
        } else {
            showDiscardConfirm = true
        }
    }

    private func recognize(_ image: UIImage) {
        step = .recognizing
        TextRecognitionService.recognizeText(in: image) { result in
            DispatchQueue.main.async {
                switch result {
                case .success(let recognition):
                    draft.recognition = recognition
                    recognitionError = nil
                    if let guessed = recognition.guessedPageNumber {
                        draft.pageNumberText = String(guessed)
                    }
                case .failure:
                    draft.recognition = PageRecognitionResult(lines: [], fullText: "", guessedPageNumber: nil)
                    recognitionError = "텍스트 인식에 실패했어요. 페이지 번호와 문장을 직접 입력해주세요."
                }
                step = .compose
            }
        }
    }

    private func save() {
        let pageNumber = Int(draft.pageNumberText)
        for pending in draft.pendingHighlights {
            let highlight = Highlight(
                text: pending.quote,
                pageNumber: pageNumber,
                isPageNumberManuallyEdited: draft.isPageNumberManuallyEdited,
                book: draft.selectedBook
            )
            modelContext.insert(highlight)

            let trimmedMemo = pending.memo.trimmingCharacters(in: .whitespacesAndNewlines)
            if !trimmedMemo.isEmpty {
                let note = Note(text: trimmedMemo, book: draft.selectedBook, highlight: highlight)
                modelContext.insert(note)
            }
        }
        dismiss()
    }
}
