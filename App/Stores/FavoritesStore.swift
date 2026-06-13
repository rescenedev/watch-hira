import Foundation
import KanaCore

/// 즐겨찾기(별표) 항목의 영속화 래퍼.
@MainActor
final class FavoritesStore: ObservableObject {
    static let shared = FavoritesStore()

    private static let storageKey = "favoriteIDs"

    @Published private(set) var ids: Set<String>

    private init() {
        let stored = UserDefaults.standard.stringArray(forKey: Self.storageKey) ?? []
        ids = Set(stored)
    }

    var count: Int { ids.count }

    var items: [ReviewDisplay] {
        ids.sorted().compactMap(ItemResolver.resolve)
    }

    func contains(id: String) -> Bool {
        ids.contains(id)
    }

    func toggle(id: String) {
        if ids.contains(id) {
            ids.remove(id)
        } else {
            ids.insert(id)
        }
        UserDefaults.standard.set(Array(ids), forKey: Self.storageKey)
    }
}
