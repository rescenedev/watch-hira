import XCTest
@testable import KanaCore

final class KanaDataTests: XCTestCase {

    // MARK: - 개수 검증

    func testHiraganaTotalCount() {
        XCTAssertEqual(KanaData.kana(script: .hiragana).count, 104)
    }

    func testKatakanaTotalCount() {
        XCTAssertEqual(KanaData.kana(script: .katakana).count, 104)
    }

    func testBasicGroupCountPerScript() {
        for script in KanaScript.allCases {
            XCTAssertEqual(
                KanaData.kana(script: script, groups: [.basic]).count, 46,
                "\(script) 청음은 46자여야 합니다"
            )
        }
    }

    func testDakuonGroupCountPerScript() {
        for script in KanaScript.allCases {
            XCTAssertEqual(KanaData.kana(script: script, groups: [.dakuon]).count, 20)
        }
    }

    func testHandakuonGroupCountPerScript() {
        for script in KanaScript.allCases {
            XCTAssertEqual(KanaData.kana(script: script, groups: [.handakuon]).count, 5)
        }
    }

    func testYoonGroupCountPerScript() {
        for script in KanaScript.allCases {
            XCTAssertEqual(KanaData.kana(script: script, groups: [.yoon]).count, 33)
        }
    }

    // MARK: - 무결성 검증

    func testAllCharactersAreUnique() {
        let characters = KanaData.all.map(\.character)
        XCTAssertEqual(characters.count, Set(characters).count)
    }

    func testAllEntriesHaveNonEmptyRomaji() {
        for kana in KanaData.all {
            XCTAssertFalse(kana.romaji.isEmpty, "\(kana.character)의 로마자가 비어 있습니다")
        }
    }

    func testCharacterLengthMatchesGroup() {
        for kana in KanaData.all {
            let expected = kana.group == .yoon ? 2 : 1
            XCTAssertEqual(kana.character.count, expected, "\(kana.character)")
        }
    }

    // MARK: - 표본 검증

    func testSpotChecks() {
        XCTAssertEqual(romaji(of: "あ"), "a")
        XCTAssertEqual(romaji(of: "ん"), "n")
        XCTAssertEqual(romaji(of: "し"), "shi")
        XCTAssertEqual(romaji(of: "つ"), "tsu")
        XCTAssertEqual(romaji(of: "ふ"), "fu")
        XCTAssertEqual(romaji(of: "を"), "wo")
        XCTAssertEqual(romaji(of: "が"), "ga")
        XCTAssertEqual(romaji(of: "ぢ"), "ji")
        XCTAssertEqual(romaji(of: "ぱ"), "pa")
        XCTAssertEqual(romaji(of: "ア"), "a")
        XCTAssertEqual(romaji(of: "ン"), "n")
        XCTAssertEqual(romaji(of: "ヲ"), "wo")
        XCTAssertEqual(romaji(of: "ヅ"), "zu")
        XCTAssertEqual(romaji(of: "ポ"), "po")
        XCTAssertEqual(romaji(of: "きゃ"), "kya")
        XCTAssertEqual(romaji(of: "じゃ"), "ja")
        XCTAssertEqual(romaji(of: "シャ"), "sha")
        XCTAssertEqual(romaji(of: "ピョ"), "pyo")
    }

    func testHiraganaAndKatakanaShareRomajiSequence() {
        let hiragana = KanaData.kana(script: .hiragana).map(\.romaji)
        let katakana = KanaData.kana(script: .katakana).map(\.romaji)
        XCTAssertEqual(hiragana, katakana)
    }

    private func romaji(of character: String) -> String? {
        KanaData.all.first { $0.character == character }?.romaji
    }
}
