import Foundation
import Observation
import UIKit

/// In-progress state for a single capture session (one photo -> one or more
/// highlights), shared across the capture flow's steps.
@Observable
final class CaptureDraft {
    var image: UIImage?
    var recognition: PageRecognitionResult?
    var pageNumberText: String = ""
    var isPageNumberManuallyEdited = false
    var pendingHighlightTexts: [String] = []
}
