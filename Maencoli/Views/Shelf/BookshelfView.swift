import SwiftUI
import SwiftData
import UIKit

struct BookshelfView: View {
    @Query(sort: \Book.createdAt, order: .reverse) private var books: [Book]
    @Query(filter: #Predicate<Highlight> { $0.book == nil }, sort: \Highlight.createdAt, order: .reverse)
    private var unassignedHighlights: [Highlight]

    @State private var showAddChoice = false
    @State private var pendingAddMode: AddFlowMode?

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
                        AddHighlightWidget { showAddChoice = true }
                            .padding(.top, 12)
                            .padding(.bottom, 28)
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                }
            }
            .background(Color(.systemBackground))
            .navigationTitle("내 책장")
            .confirmationDialog("새 하이라이트", isPresented: $showAddChoice, titleVisibility: .visible) {
                Button("사진으로 추가") { pendingAddMode = .photo }
                Button("직접 입력하기") { pendingAddMode = .manual }
                Button("책만 등록하기") { pendingAddMode = .bookOnly }
                Button("취소", role: .cancel) {}
            }
            .fullScreenCover(item: $pendingAddMode) { mode in
                switch mode {
                case .photo:
                    CaptureFlowView(preselectedBook: nil)
                case .manual:
                    ManualEntryView(preselectedBook: nil)
                case .bookOnly:
                    BookOnlyEntryView()
                case .memoOnly:
                    EmptyView()
                }
            }
        }
    }
}

/// Home-screen entry point for adding a highlight — a pen-and-notebook style
/// affordance sitting below the shelf (spec: "책장 앞에 펜과 노트같은게 있는
/// 것처럼"). Uses an SF Symbol rather than a custom illustration for now.
private struct AddHighlightWidget: View {
    var onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 10) {
                Image(systemName: "square.and.pencil")
                    .font(.title3)
                    .foregroundStyle(Color.accentColor)
                    .frame(width: 40, height: 40)
                    .background(Color.accentColor.opacity(0.12))
                    .clipShape(RoundedRectangle(cornerRadius: 10))
                VStack(alignment: .leading, spacing: 1) {
                    Text("새 하이라이트").font(.subheadline.weight(.semibold))
                    Text("사진 · 직접 입력 · 책 등록").font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
            }
            .padding(12)
            .background(Color(.secondarySystemBackground))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: .black.opacity(0.06), radius: 6, x: 0, y: 3)
        }
        .buttonStyle(.plain)
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
            Text("아직 저장된 하이라이트가 없어요.\n아래 버튼으로 책 페이지를 촬영하거나 책을 등록해보세요.")
                .multilineTextAlignment(.center)
                .foregroundStyle(.secondary)
        }
        .padding(.top, 80)
    }
}
