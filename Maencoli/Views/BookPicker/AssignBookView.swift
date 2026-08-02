import SwiftUI
import SwiftData

/// Shared "책 연결하기" flow used both right after a capture (spec 4) and
/// when merging a weekly pseudo-book into a real book later.
struct AssignBookView: View {
    var onConfirm: (Book?) -> Void

    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    @Environment(\.modelContext) private var modelContext

    @State private var searchText = ""
    @State private var showAladinSearch = false
    @State private var showManualEntry = false

    private var filteredBooks: [Book] {
        guard !searchText.isEmpty else { return books }
        return books.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        VStack(spacing: 0) {
            TextField("책 제목으로 검색", text: $searchText)
                .textFieldStyle(.roundedBorder)
                .padding()

            List {
                Section {
                    Button {
                        showAladinSearch = true
                    } label: {
                        Label("도서 검색해서 추가", systemImage: "magnifyingglass")
                    }
                    Button {
                        showManualEntry = true
                    } label: {
                        Label("직접 입력해서 추가", systemImage: "square.and.pencil")
                    }
                }

                if !filteredBooks.isEmpty {
                    Section("기존 책") {
                        ForEach(filteredBooks) { book in
                            Button {
                                onConfirm(book)
                            } label: {
                                VStack(alignment: .leading) {
                                    Text(book.title).foregroundStyle(.primary)
                                    if let author = book.author {
                                        Text(author).font(.caption).foregroundStyle(.secondary)
                                    }
                                }
                            }
                        }
                    }
                }

                Section {
                    Button("나중에 책 정하기 (이번 주 기록으로 저장)") {
                        onConfirm(nil)
                    }
                }
            }
            .listStyle(.insetGrouped)
        }
        .navigationTitle("책 연결하기")
        .navigationBarTitleDisplayMode(.inline)
        .sheet(isPresented: $showAladinSearch) {
            AladinSearchView { result in
                let book = Book(
                    title: result.title,
                    author: result.author,
                    isbn: result.id,
                    pageCount: result.pageCount,
                    coverImageURLString: result.coverURLString,
                    addedManually: false
                )
                modelContext.insert(book)
                showAladinSearch = false
                onConfirm(book)
            }
        }
        .sheet(isPresented: $showManualEntry) {
            ManualBookEntryView { title, author, pageCount in
                let book = Book(title: title, author: author, pageCount: pageCount, addedManually: true)
                modelContext.insert(book)
                showManualEntry = false
                onConfirm(book)
            }
        }
    }
}
