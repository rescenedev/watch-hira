import Foundation

/// 가나가 들어간 자주 쓰는 예시 단어.
public struct KanaWord: Hashable, Sendable {
    public let word: String
    public let meaning: String

    public init(word: String, meaning: String) {
        self.word = word
        self.meaning = meaning
    }
}

/// 가나별 예시 단어 사전.
public enum KanaWordBank {

    /// 해당 가나가 들어간 예시 단어 전체.
    public static func words(for kana: Kana) -> [KanaWord] {
        switch kana.script {
        case .hiragana: return hiraganaWordTable[kana.character] ?? []
        case .katakana: return katakanaWordTable[kana.character] ?? []
        }
    }

    /// 가나 한 글자로 예시 단어를 찾는다. 히라가나·가타카나 표를 모두 확인한다.
    public static func words(forCharacter character: String) -> [KanaWord] {
        hiraganaWordTable[character] ?? katakanaWordTable[character] ?? []
    }

    /// 예시 단어 중 무작위로 최대 `count`개를 고른다. 호출할 때마다 달라진다.
    public static func randomWords(for kana: Kana, count: Int) -> [KanaWord] {
        var generator = SystemRandomNumberGenerator()
        return randomWords(for: kana, count: count, using: &generator)
    }

    public static func randomWords<G: RandomNumberGenerator>(
        for kana: Kana,
        count: Int,
        using generator: inout G
    ) -> [KanaWord] {
        Array(words(for: kana).shuffled(using: &generator).prefix(count))
    }
}
