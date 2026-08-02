import Foundation
import CoreGraphics

/// Maps a book's page count to a relative spine width so the shelf reads as
/// "real" book thicknesses rather than uniform placeholder blocks.
enum SpineWidthCalculator {
    private static let minWidth: CGFloat = 14
    private static let maxWidth: CGFloat = 60
    private static let pointsPerPage: CGFloat = 0.09
    private static let baseWidth: CGFloat = 10

    static var defaultUnknownWidth: CGFloat { 24 }

    static func width(forPageCount pageCount: Int?) -> CGFloat {
        guard let pageCount, pageCount > 0 else { return defaultUnknownWidth }
        let raw = baseWidth + CGFloat(pageCount) * pointsPerPage
        return min(max(raw, minWidth), maxWidth)
    }

    /// Used for the ISO-week pseudo-book spine, sized by how many highlights it holds.
    static func width(forHighlightCount count: Int) -> CGFloat {
        let raw = baseWidth + CGFloat(count) * 4
        return min(max(raw, minWidth), maxWidth)
    }
}
