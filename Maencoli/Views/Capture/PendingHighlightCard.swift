import SwiftUI
import UIKit

/// One not-yet-saved highlight in the composition list, with an inline,
/// optional memo field.
struct PendingHighlightCard: View {
    @Binding var pending: PendingHighlight
    var onRemove: () -> Void

    @State private var isEditingMemo = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(pending.quote)
                .font(.callout)

            if isEditingMemo || !pending.memo.isEmpty {
                TextField("메모", text: $pending.memo, axis: .vertical)
                    .font(.caption)
                    .textFieldStyle(.roundedBorder)
            } else {
                Button("✎ 메모 추가") { isEditingMemo = true }
                    .font(.caption.weight(.semibold))
            }

            HStack {
                Spacer()
                Button("삭제", role: .destructive, action: onRemove)
                    .font(.caption)
            }
        }
        .padding(10)
        .background(Color(.secondarySystemBackground))
        .clipShape(RoundedRectangle(cornerRadius: 10))
    }
}
