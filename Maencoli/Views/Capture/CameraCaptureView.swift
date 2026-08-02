import SwiftUI
import UIKit

/// Step 1 of the capture flow: take (or pick) a photo of a book page.
struct CameraCaptureView: View {
    var onCapture: (UIImage) -> Void

    var body: some View {
        ImagePicker(
            sourceType: UIImagePickerController.isSourceTypeAvailable(.camera) ? .camera : .photoLibrary,
            onPick: onCapture
        )
        .ignoresSafeArea()
    }
}

private struct ImagePicker: UIViewControllerRepresentable {
    let sourceType: UIImagePickerController.SourceType
    var onPick: (UIImage) -> Void

    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = sourceType
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}

    func makeCoordinator() -> Coordinator {
        Coordinator(onPick: onPick)
    }

    final class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let onPick: (UIImage) -> Void

        init(onPick: @escaping (UIImage) -> Void) {
            self.onPick = onPick
        }

        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                onPick(image)
            }
        }
    }
}
