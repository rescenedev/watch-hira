#if os(iOS)
import Foundation
import KanaCore

/// Anki 등에서 가져온 사용자 단어 덱.
struct CustomDeck: Codable, Identifiable, Hashable {
    let id: UUID
    var name: String
    var words: [VocabWord]
}

/// 사용자 덱의 영속화 래퍼 (Documents/custom_decks.json).
@MainActor
final class CustomDeckStore: ObservableObject {
    static let shared = CustomDeckStore()

    @Published private(set) var decks: [CustomDeck]

    private static var fileURL: URL {
        FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            .appendingPathComponent("custom_decks.json")
    }

    private init() {
        if let data = try? Data(contentsOf: Self.fileURL),
           let decoded = try? JSONDecoder().decode([CustomDeck].self, from: data) {
            decks = decoded
        } else {
            decks = []
        }
    }

    func deck(id: UUID) -> CustomDeck? {
        decks.first { $0.id == id }
    }

    func word(deckID: UUID, word: String) -> VocabWord? {
        deck(id: deckID)?.words.first { $0.word == word }
    }

    func add(name: String, words: [VocabWord]) {
        decks.append(CustomDeck(id: UUID(), name: name, words: words))
        save()
    }

    func remove(id: UUID) {
        decks.removeAll { $0.id == id }
        save()
    }

    private func save() {
        do {
            let data = try JSONEncoder().encode(decks)
            try data.write(to: Self.fileURL, options: .atomic)
        } catch {
            assertionFailure("커스텀 덱 저장 실패: \(error)")
        }
    }
}
#endif
