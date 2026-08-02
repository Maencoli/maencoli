import SwiftUI
import SwiftData

struct BookshelfView: View {
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    @Query(filter: #Predicate<Highlight> { $0.book == nil }, sort: \Highlight.createdAt, order: .reverse)
    private var unassignedHighlights: [Highlight]

    @State private var showCaptureFlow = false

    private var shelfItems: [ShelfItem] {
        let bookItems = books.map(ShelfItem.book)
        let grouped = Dictionary(grouping: unassignedHighlights) { ISOWeekHelper.groupKey(for: $0.createdAt) }
        let weekItems = grouped.map { key, highlights in
            ShelfItem.weekGroup(
                key: key,
                title: ISOWeekHelper.displayTitle(for: highlights.first?.createdAt ?? Date()),
                highlights: highlights
            )
        }
        return (bookItems + weekItems).sorted { $0.title < $1.title }
    }

    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                ScrollView {
                    let rows = ShelfRowBuilder.rows(for: shelfItems, rowWidth: geometry.size.width - 32, spacing: 10)
                    VStack(spacing: 0) {
                        if rows.isEmpty {
                            EmptyShelfView()
                        } else {
                            ForEach(Array(rows.enumerated()), id: \.offset) { _, row in
                                ShelfRowView(items: row)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .navigationTitle("내 책장")
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showCaptureFlow = true
                    } label: {
                        Label("촬영", systemImage: "camera.fill")
                    }
                }
            }
            .fullScreenCover(isPresented: $showCaptureFlow) {
                CaptureFlowView()
            }
        }
    }
}

private struct ShelfRowView: View {
    let items: [ShelfItem]

    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .bottom, spacing: 10) {
                ForEach(items) { item in
                    NavigationLink {
                        destination(for: item)
                    } label: {
                        BookSpineView(item: item)
                    }
                    .buttonStyle(.plain)
                }
                Spacer(minLength: 0)
            }
            Rectangle()
                .fill(Color.brown.opacity(0.6))
                .frame(height: 10)
        }
        .padding(.bottom, 20)
    }

    @ViewBuilder
    private func destination(for item: ShelfItem) -> some View {
        switch item.kind {
        case .book(let book):
            BookDetailView(book: book)
        case .weekGroup(let key, _):
            WeekGroupDetailView(groupKey: key, title: item.title)
        }
    }
}

private struct EmptyShelfView: View {
    var body: some View {
        VStack(spacing: 12) {
            Image(systemName: "books.vertical")
                .font(.system(size: 40))
                .foregroundStyle(.secondary)
            Text("아직 저장된 하이라이트가 없어요.\n카메라 버튼을 눌러 책 페이지를 촬영해보세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 80)
    }
}
