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

    private static let yoonRomaji: [String] = [
        "kya", "kyu", "kyo",
        "sha", "shu", "sho",
        "cha", "chu", "cho",
        "nya", "nyu", "nyo",
        "hya", "hyu", "hyo",
        "mya", "myu", "myo",
        "rya", "ryu", "ryo",
        "gya", "gyu", "gyo",
        "ja", "ju", "jo",
        "bya", "byu", "byo",
        "pya", "pyu", "pyo",
    ]

    private static let hiraganaYoon: [String] = [
        "きゃ", "きゅ", "きょ", "しゃ", "しゅ", "しょ", "ちゃ", "ちゅ", "ちょ",
        "にゃ", "にゅ", "にょ", "ひゃ", "ひゅ", "ひょ", "みゃ", "みゅ", "みょ",
        "りゃ", "りゅ", "りょ", "ぎゃ", "ぎゅ", "ぎょ", "じゃ", "じゅ", "じょ",
        "びゃ", "びゅ", "びょ", "ぴゃ", "ぴゅ", "ぴょ",
    ]

    private static let katakanaYoon: [String] = [
        "キャ", "キュ", "キョ", "シャ", "シュ", "ショ", "チャ", "チュ", "チョ",
        "ニャ", "ニュ", "ニョ", "ヒャ", "ヒュ", "ヒョ", "ミャ", "ミュ", "ミョ",
        "リャ", "リュ", "リョ", "ギャ", "ギュ", "ギョ", "ジャ", "ジュ", "ジョ",
        "ビャ", "ビュ", "ビョ", "ピャ", "ピュ", "ピョ",
    ]

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
        let sources: [(characters: [String], romaji: [String], group: KanaGroup)]
        switch script {
        case .hiragana:
            sources = [
                (hiraganaBasic.map(String.init), basicRomaji, .basic),
                (hiraganaDakuon.map(String.init), dakuonRomaji, .dakuon),
                (hiraganaHandakuon.map(String.init), handakuonRomaji, .handakuon),
                (hiraganaYoon, yoonRomaji, .yoon),
            ]
        case .katakana:
            sources = [
                (katakanaBasic.map(String.init), basicRomaji, .basic),
                (katakanaDakuon.map(String.init), dakuonRomaji, .dakuon),
                (katakanaHandakuon.map(String.init), handakuonRomaji, .handakuon),
                (katakanaYoon, yoonRomaji, .yoon),
            ]
        }
        return sources.flatMap { source in
            precondition(
                source.characters.count == source.romaji.count,
                "문자 수와 로마자 수가 일치해야 합니다"
            )
            return zip(source.characters, source.romaji).map { character, romaji in
                Kana(
                    character: character,
                    romaji: romaji,
                    script: script,
                    group: source.group
                )
            }
        }
    }
}
