import SwiftUI

struct AladinSearchView: View {
    var onSelect: (AladinBookSearchResult) -> Void

    @State private var query = ""
    @State private var results: [AladinBookSearchResult] = []
    @State private var isLoading = false
    @State private var errorMessage: String?
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                if let errorMessage {
                    Text(errorMessage).foregroundStyle(.red)
                }
                ForEach(results) { result in
                    Button {
                        onSelect(result)
                    } label: {
                        HStack(alignment: .top, spacing: 12) {
                            AsyncImage(url: result.coverURLString.flatMap(URL.init)) { image in
                                image.resizable().scaledToFit()
                            } placeholder: {
                                Color.secondary.opacity(0.2)
                            }
                            .frame(width: 44, height: 60)
                            .clipShape(RoundedRectangle(cornerRadius: 4))

                            VStack(alignment: .leading) {
                                Text(result.title).foregroundStyle(.primary)
                                Text(result.author).font(.caption).foregroundStyle(.secondary)
                                if let pageCount = result.pageCount {
                                    Text("\(pageCount)쪽").font(.caption2).foregroundStyle(.secondary)
                                }
                            }
                        }
                    }
                }
            }
            .searchable(text: $query, prompt: "책 제목 검색")
            .onSubmit(of: .search, search)
            .overlay {
                if isLoading { ProgressView() }
            }
            .navigationTitle("도서 검색")
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("취소") { dismiss() }
                }
            }
        }
    }

    private func search() {
        guard !query.trimmingCharacters(in: .whitespaces).isEmpty else { return }
        isLoading = true
        errorMessage = nil
        Task {
            do {
                results = try await AladinBookService.shared.search(query: query)
            } catch AladinBookServiceError.missingAPIKey {
                errorMessage = "알라딘 API 키가 설정되지 않았어요. Info.plist의 AladinTTBKey를 확인해주세요."
            } catch {
                errorMessage = "검색에 실패했어요: \(error.localizedDescription)"
            }
            isLoading = false
        }
    }
}
