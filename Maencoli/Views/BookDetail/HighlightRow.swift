import SwiftUI

struct HighlightRow: View {
    @Bindable var highlight: Highlight
    @State private var isEditingPage = false
    @State private var pageDraft: String = ""

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(highlight.text)
                .font(.body)

            HStack {
                if isEditingPage {
                    TextField("페이지", text: $pageDraft)
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                        .frame(width: 70)
                        .onSubmit(commitPageEdit)
                    Button("완료", action: commitPageEdit)
                        .font(.caption)
                } else {
                    Button {
                        pageDraft = highlight.pageNumber.map(String.init) ?? ""
                        isEditingPage = true
                    } label: {
                        Text(highlight.pageNumber.map { "\($0)쪽" } ?? "페이지 입력")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                }
                Spacer()
                Text(highlight.createdAt, style: .date)
                    .font(.caption2)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding(.vertical, 4)
    }

    private func commitPageEdit() {
        highlight.pageNumber = Int(pageDraft)
        highlight.isPageNumberManuallyEdited = true
        isEditingPage = false
    }
}
