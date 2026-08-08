import Foundation
import Observation
import UIKit

/// A highlight the user has selected on this page but not yet saved, along
/// with its own optional memo.
struct PendingHighlight: Identifiable {
    let id = UUID()
    var quote: String
    var memo: String = ""
}

/// In-progress state for a single photo capture session. `image` only ever
/// lives here in memory — it is never written to disk, so there's nothing to
/// delete when the session ends (saved or cancelled), it's simply released.
@Observable
final class CaptureDraft {
    var image: UIImage?
    var recognition: PageRecognitionResult?
    var pageNumberText: String = ""
    var isPageNumberManuallyEdited = false
    var pendingHighlights: [PendingHighlight] = []
    var selectedBook: Book?
}
