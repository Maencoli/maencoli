import SwiftUI

struct BookSpineView: View {
    let item: ShelfItem
    static let height: CGFloat = 170

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 3)
                .fill(item.spineColor.gradient)
                .frame(width: item.spineWidth, height: Self.height)
                .shadow(color: .black.opacity(0.25), radius: 2, x: 1, y: 1)

            Text(item.title)
                .font(.caption2.weight(.semibold))
                .foregroundStyle(.white)
                .lineLimit(1)
                .fixedSize()
                .rotationEffect(.degrees(-90))
                .frame(width: item.spineWidth, height: Self.height)
        }
    }
}

#Preview {
    HStack(alignment: .bottom, spacing: 10) {
        BookSpineView(item: .book(Book(title: "인간 실격", pageCount: 180)))
        BookSpineView(item: .book(Book(title: "코스모스", pageCount: 700)))
        BookSpineView(item: .weekGroup(key: "2026-W32", title: "2026년 32주", highlights: []))
    }
    .padding()
}
