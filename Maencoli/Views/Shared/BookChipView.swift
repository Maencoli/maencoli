import SwiftUI
import UIKit

/// Tappable chip showing the currently-linked book (or an unset/required
/// state), used across the capture/manual/memo entry screens.
struct BookChipView: View {
    var book: Book?
    var requiresBook: Bool = false
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text(requiresBook ? "책 (필수)" : "책")
                        .font(.caption2.weight(.semibold))
                        .textCase(.uppercase)
                        .foregroundStyle(.secondary)
                    Text(subtitle)
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(book == nil ? .secondary : .primary)
                        .lineLimit(1)
                }
                Spacer()
                Text(book == nil ? "선택" : "변경")
                    .font(.caption.weight(.semibold))
                    .foregroundStyle(Color.accentColor)
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
        .buttonStyle(.plain)
    }

    private var subtitle: String {
        if let book { return book.title }
        return requiresBook ? "메모를 저장하려면 책을 선택하세요" : "탭하여 책 선택 (안 하면 이번 주 기록)"
    }
}
