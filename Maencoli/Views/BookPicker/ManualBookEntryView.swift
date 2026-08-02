import SwiftUI

struct ManualBookEntryView: View {
    var onSave: (_ title: String, _ author: String?, _ pageCount: Int?) -> Void

    @State private var title = ""
    @State private var author = ""
    @State private var pageCountText = ""
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            Form {
                TextField("책 제목", text: $title)
                TextField("저자 (선택)", text: $author)
                TextField("전체 페이지 수 (선택)", text: $pageCountText)
                    .keyboardType(.numberPad)
            }
            .navigationTitle("직접 추가")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("저장") {
                        onSave(
                            title.trimmingCharacters(in: .whitespaces),
                            author.isEmpty ? nil : author,
                            Int(pageCountText)
                        )
                    }
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }
}
