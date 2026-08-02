import SwiftUI
import UIKit

/// Thin UIViewRepresentable over UITextView so the user gets native drag-to-select
/// text selection (and can fix OCR mistakes inline) — spec 3: "텍스트를 선택하여
/// 문장을 하이라이트".
struct SelectableTextView: UIViewRepresentable {
    @Binding var text: String
    @Binding var selectedText: String

    func makeUIView(context: Context) -> UITextView {
        let textView = UITextView()
        textView.isEditable = true
        textView.isSelectable = true
        textView.font = .preferredFont(forTextStyle: .body)
        textView.delegate = context.coordinator
        textView.text = text
        return textView
    }

    func updateUIView(_ uiView: UITextView, context: Context) {
        if uiView.text != text {
            uiView.text = text
        }
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    final class Coordinator: NSObject, UITextViewDelegate {
        let parent: SelectableTextView

        init(_ parent: SelectableTextView) {
            self.parent = parent
        }

        func textViewDidChange(_ textView: UITextView) {
            parent.text = textView.text
        }

        func textViewDidChangeSelection(_ textView: UITextView) {
            if let range = textView.selectedTextRange, !range.isEmpty {
                parent.selectedText = textView.text(in: range) ?? ""
            } else {
                parent.selectedText = ""
            }
        }
    }
}
