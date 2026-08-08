import SwiftUI
import SwiftData

/// Shared "책 연결하기" sheet used by every entry screen's book chip: pick an
/// existing book, search/add via Aladin, or quick-add a new book by title.
struct BookPickerView: View {
    @Binding var selectedBook: Book?

    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    @Environment(\.modelContext) private var modelContext
    @Environment(\.dismiss) private var dismiss

    @State private var searchText = ""
    @State private var showAladinSearch = false
    @State private var newBookTitle = ""

    private var filteredBooks: [Book] {
        guard !searchText.isEmpty else { return books }
        return books.filter { $0.title.localizedCaseInsensitiveContains(searchText) }
    }

    var body: some View {
        NavigationStack {
            List {
                Section {
                    Button {
                        showAladinSearch = true
                    } label: {
                        Label("도서 검색해서 추가", systemImage: "magnifyingglass")
                    }
                }

                if !filteredBooks.isEmpty {
                    Section("기존 책") {
                        ForEach(filteredBooks) { book in
                            Button {
                                selectedBook = book
                                dismiss()
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

                Section("새 책 추가") {
                    HStack {
                        TextField("새 책 제목", text: $newBookTitle)
                        Button("추가", action: addNewBook)
                            .disabled(newBookTitle.trimmingCharacters(in: .whitespaces).isEmpty)
                    }
                }
            }
            .searchable(text: $searchText, prompt: "책 제목으로 검색")
            .navigationTitle("책 연결하기")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("닫기") { dismiss() }
                }
            }
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
                    selectedBook = book
                    showAladinSearch = false
                    dismiss()
                }
            }
        }
    }

    private func addNewBook() {
        let title = newBookTitle.trimmingCharacters(in: .whitespaces)
        guard !title.isEmpty else { return }
        let book = Book(title: title, addedManually: true)
        modelContext.insert(book)
        selectedBook = book
        dismiss()
    }
}
