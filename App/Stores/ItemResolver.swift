import Foundation
import KanaCore

/// 복습·즐겨찾기 카드 표시용 항목.
struct ReviewDisplay: Identifiable, Hashable {
    let id: String
    let prompt: String
    let reading: String?
    let answer: String
}

/// "kana:あ" / "jlptN3:経験" / "custom:<uuid>:<단어>" 형태의 id를 표시용 항목으로 되돌린다.
enum ItemResolver {
    @MainActor
    static func resolve(id: String) -> ReviewDisplay? {
        let parts = id.split(separator: ":", maxSplits: 1).map(String.init)
        guard parts.count == 2 else { return nil }
        let kind = parts[0]
        let key = parts[1]

        #if os(iOS)
        if kind == "custom" {
            let customParts = key.split(separator: ":", maxSplits: 1).map(String.init)
            guard customParts.count == 2,
                  let deckID = UUID(uuidString: customParts[0]),
                  let word = CustomDeckStore.shared.word(deckID: deckID, word: customParts[1]) else {
                return nil
            }
            return ReviewDisplay(
                id: id,
                prompt: word.word,
                reading: word.hasDistinctReading ? word.reading : nil,
                answer: word.meaning
            )
        }
        #endif

        if kind == "kana" {
            guard let kana = KanaData.all.first(where: { $0.character == key }) else { return nil }
            return ReviewDisplay(id: id, prompt: kana.character, reading: nil, answer: kana.romaji)
        }

        guard let deck = VocabDeckKind(rawValue: kind),
              let word = VocabData.words(for: deck).first(where: { $0.word == key }) else {
            return nil
        }
        return ReviewDisplay(
            id: id,
            prompt: word.word,
            reading: word.hasDistinctReading ? word.reading : nil,
            answer: word.meaning
        )
    }
}
