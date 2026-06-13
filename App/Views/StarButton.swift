import SwiftUI

/// 즐겨찾기 토글 별표 버튼.
struct StarButton: View {
    let itemID: String

    @ObservedObject private var store = FavoritesStore.shared

    var body: some View {
        Button {
            store.toggle(id: itemID)
        } label: {
            Image(systemName: store.contains(id: itemID) ? "star.fill" : "star")
                .font(starFont)
                .foregroundStyle(store.contains(id: itemID) ? .yellow : Theme.slate400)
                .padding(6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("즐겨찾기")
    }

    private var starFont: Font {
        #if os(watchOS)
        .footnote
        #else
        .title3
        #endif
    }
}
