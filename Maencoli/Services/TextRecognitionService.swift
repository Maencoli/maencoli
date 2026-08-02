import Foundation
import Vision
import UIKit

struct RecognizedLine: Identifiable {
    let id = UUID()
    let text: String
    /// Normalized bounding box in Vision's coordinate space (origin bottom-left).
    let boundingBox: CGRect
}

struct PageRecognitionResult {
    let lines: [RecognizedLine]
    let fullText: String
    let guessedPageNumber: Int?
}

enum TextRecognitionError: Error {
    case invalidImage
}

/// Wraps Vision's on-device text recognition to turn a photographed book page
/// into editable text plus a best-effort guess at the printed page number.
enum TextRecognitionService {
    static func recognizeText(in image: UIImage, completion: @escaping (Result<PageRecognitionResult, Error>) -> Void) {
        guard let cgImage = image.cgImage else {
            completion(.failure(TextRecognitionError.invalidImage))
            return
        }

        let request = VNRecognizeTextRequest { request, error in
            if let error {
                completion(.failure(error))
                return
            }
            guard let observations = request.results as? [VNRecognizedTextObservation] else {
                completion(.success(PageRecognitionResult(lines: [], fullText: "", guessedPageNumber: nil)))
                return
            }

            let lines: [RecognizedLine] = observations.compactMap { observation in
                guard let candidate = observation.topCandidates(1).first else { return nil }
                return RecognizedLine(text: candidate.string, boundingBox: observation.boundingBox)
            }
            // Vision's origin is bottom-left, so a higher normalized Y is higher on the page.
            let sortedLines = lines.sorted { $0.boundingBox.origin.y > $1.boundingBox.origin.y }
            let fullText = sortedLines.map(\.text).joined(separator: "\n")
            let guessedPageNumber = guessPageNumber(from: sortedLines)

            completion(.success(PageRecognitionResult(lines: sortedLines, fullText: fullText, guessedPageNumber: guessedPageNumber)))
        }

        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        request.recognitionLanguages = ["ko-KR", "en-US"]

        let handler = VNImageRequestHandler(cgImage: cgImage, orientation: cgOrientation(for: image), options: [:])
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    completion(.failure(error))
                }
            }
        }
    }

    /// Looks for a short, isolated numeric line near the top or bottom edge of
    /// the page — the typical position of a printed page number.
    private static func guessPageNumber(from lines: [RecognizedLine]) -> Int? {
        let edgeCandidate = lines.first { line in
            let isEdgePosition = line.boundingBox.origin.y > 0.85 || line.boundingBox.origin.y < 0.15
            let trimmed = line.text.trimmingCharacters(in: .whitespaces)
            let isShortNumeric = trimmed.count <= 4 && Int(trimmed) != nil
            return isEdgePosition && isShortNumeric
        }
        guard let edgeCandidate else { return nil }
        return Int(edgeCandidate.text.trimmingCharacters(in: .whitespaces))
    }

    private static func cgOrientation(for image: UIImage) -> CGImagePropertyOrientation {
        switch image.imageOrientation {
        case .up: return .up
        case .down: return .down
        case .left: return .left
        case .right: return .right
        case .upMirrored: return .upMirrored
        case .downMirrored: return .downMirrored
        case .leftMirrored: return .leftMirrored
        case .rightMirrored: return .rightMirrored
        @unknown default: return .up
        }
    }
}
