import Foundation

/// 히라가나·가타카나 전체 데이터 소스.
public enum KanaData {

    private static let basicRomaji: [String] = [
        "a", "i", "u", "e", "o",
        "ka", "ki", "ku", "ke", "ko",
        "sa", "shi", "su", "se", "so",
        "ta", "chi", "tsu", "te", "to",
        "na", "ni", "nu", "ne", "no",
        "ha", "hi", "fu", "he", "ho",
        "ma", "mi", "mu", "me", "mo",
        "ya", "yu", "yo",
        "ra", "ri", "ru", "re", "ro",
        "wa", "wo", "n",
    ]

    private static let dakuonRomaji: [String] = [
        "ga", "gi", "gu", "ge", "go",
        "za", "ji", "zu", "ze", "zo",
        "da", "ji", "zu", "de", "do",
        "ba", "bi", "bu", "be", "bo",
    ]

    private static let handakuonRomaji: [String] = ["pa", "pi", "pu", "pe", "po"]

    private static let hiraganaBasic = "あいうえおかきくけこさしすせそたちつてとなにぬねのはひふへほまみむめもやゆよらりるれろわをん"
    private static let hiraganaDakuon = "がぎぐげござじずぜぞだぢづでどばびぶべぼ"
    private static let hiraganaHandakuon = "ぱぴぷぺぽ"

    private static let katakanaBasic = "アイウエオカキクケコサシスセソタチツテトナニヌネノハヒフヘホマミムメモヤユヨラリルレロワヲン"
    private static let katakanaDakuon = "ガギグゲゴザジズゼゾダヂヅデドバビブベボ"
    private static let katakanaHandakuon = "パピプペポ"

    /// 두 문자 체계의 모든 가나 (스크립트별 71자, 총 142자).
    public static let all: [Kana] = KanaScript.allCases.flatMap(makeScript)

    /// 스크립트와 그룹으로 필터링한 가나 목록.
    public static func kana(
        script: KanaScript,
        groups: Set<KanaGroup> = Set(KanaGroup.allCases)
    ) -> [Kana] {
        all.filter { $0.script == script && groups.contains($0.group) }
    }

    private static func makeScript(_ script: KanaScript) -> [Kana] {
        let sources: [(characters: String, romaji: [String], group: KanaGroup)]
        switch script {
        case .hiragana:
            sources = [
                (hiraganaBasic, basicRomaji, .basic),
                (hiraganaDakuon, dakuonRomaji, .dakuon),
                (hiraganaHandakuon, handakuonRomaji, .handakuon),
            ]
        case .katakana:
            sources = [
                (katakanaBasic, basicRomaji, .basic),
                (katakanaDakuon, dakuonRomaji, .dakuon),
                (katakanaHandakuon, handakuonRomaji, .handakuon),
            ]
        }
        return sources.flatMap { source in
            precondition(
                source.characters.count == source.romaji.count,
                "문자 수와 로마자 수가 일치해야 합니다"
            )
            return zip(source.characters, source.romaji).map { character, romaji in
                Kana(
                    character: String(character),
                    romaji: romaji,
                    script: script,
                    group: source.group
                )
            }
        }
    }
}
