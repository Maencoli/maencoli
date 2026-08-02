import SwiftUI
import SwiftData
import UIKit

/// Orchestrates the full "촬영 -> 하이라이트 선택 -> 책 연결" flow (spec 2-4).
struct CaptureFlowView: View {
    private enum Step {
        case capture, selectHighlights, assignBook
    }

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    @State private var draft = CaptureDraft()
    @State private var step: Step = .capture
    @State private var isRecognizing = false
    @State private var recognitionError: String?

    var body: some View {
        NavigationStack {
            Group {
                switch step {
                case .capture:
                    CameraCaptureView { image in
                        draft.image = image
                        recognize(image)
                    }
                case .selectHighlights:
                    if isRecognizing {
                        ProgressView("텍스트를 인식하는 중...")
                    } else {
                        VStack(spacing: 0) {
                            if let recognitionError {
                                Text(recognitionError)
                                    .font(.caption)
                                    .foregroundStyle(.orange)
                                    .padding(.horizontal)
                                    .padding(.top, 8)
                            }
                            HighlightSelectionView(draft: draft) {
                                step = .assignBook
                            }
                        }
                    }
                case .assignBook:
                    AssignBookView { book in
                        save(to: book)
                    }
                }
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }

    private func recognize(_ image: UIImage) {
        isRecognizing = true
        step = .selectHighlights
        TextRecognitionService.recognizeText(in: image) { result in
            DispatchQueue.main.async {
                isRecognizing = false
                switch result {
                case .success(let recognition):
                    draft.recognition = recognition
                    if let guessed = recognition.guessedPageNumber {
                        draft.pageNumberText = String(guessed)
                    }
                case .failure:
                    recognitionError = "텍스트 인식에 실패했어요. 페이지 번호와 문장을 직접 입력해주세요."
                }
            }
        }
    }

    private func save(to book: Book?) {
        let photoPath = draft.image.flatMap(PhotoStorage.save)
        let pageNumber = Int(draft.pageNumberText)
        for text in draft.pendingHighlightTexts {
            let highlight = Highlight(
                text: text,
                pageNumber: pageNumber,
                isPageNumberManuallyEdited: draft.isPageNumberManuallyEdited,
                photoRelativePath: photoPath,
                book: book
            )
            modelContext.insert(highlight)
        }
        dismiss()
    }
}
