import SwiftUI
import KanaCore

/// 즐겨찾기 목록: 별표한 글자·단어를 한눈에.
struct FavoritesView: View {
    @ObservedObject private var store = FavoritesStore.shared

    var body: some View {
        Group {
            if store.items.isEmpty {
                emptyState
            } else {
                List(store.items) { item in
                    FavoriteRow(item: item)
                        .slateRow()
                        .noSeparatorOnIOS()
                }
                .spacedListOnIOS()
            }
        }
        .slateScreen()
        .navigationTitle("즐겨찾기")
    }

    private var emptyState: some View {
        VStack(spacing: 8) {
            Image(systemName: "star")
                .font(.system(size: 36))
                .foregroundStyle(.yellow)
            Text("카드의 별표를 눌러\n헷갈리는 항목을 모아보세요")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
    }
}

private struct FavoriteRow: View {
    let item: ReviewDisplay

    var body: some View {
        HStack(spacing: 8) {
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(item.prompt)
                        .font(.headline)
                    if let reading = item.reading {
                        Text(reading)
                            .font(.caption)
                            .foregroundStyle(Theme.mint)
                    }
                }
                Text(item.answer)
                    .font(.caption)
                    .foregroundStyle(Theme.slate400)
            }
            Spacer()
            StarButton(itemID: item.id)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        FavoritesView()
    }
}
