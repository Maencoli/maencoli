import Foundation
import UIKit

/// Saves captured page photos to disk (outside the SwiftData store) and hands
/// back a relative filename to persist on the Highlight model.
enum PhotoStorage {
    static func save(_ image: UIImage) -> String? {
        guard let data = image.jpegData(compressionQuality: 0.8) else { return nil }
        let filename = "\(UUID().uuidString).jpg"
        let url = directory.appendingPathComponent(filename)
        do {
            try data.write(to: url)
            return filename
        } catch {
            return nil
        }
    }

    static func url(for relativePath: String) -> URL {
        directory.appendingPathComponent(relativePath)
    }

    private static var directory: URL {
        let dir = FileManager.default
            .urls(for: .applicationSupportDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("Photos", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir
    }
}
