import SwiftUI
import UIKit

/// Shared visual for a single memo's text + creation date, tappable to edit.
struct MemoBubble: View {
    var text: String
    var date: Date
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(alignment: .top, spacing: 7) {
                Image(systemName: "pencil.and.scribble")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                VStack(alignment: .leading, spacing: 2) {
                    Text(text)
                        .font(.caption)
                        .foregroundStyle(.primary)
                    Text(date, style: .date)
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
                Spacer(minLength: 0)
            }
            .padding(8)
            .background(Color(.tertiarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .buttonStyle(.plain)
    }
}
