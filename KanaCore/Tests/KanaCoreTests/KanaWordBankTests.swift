import XCTest
@testable import KanaCore

final class KanaWordBankTests: XCTestCase {

    // MARK: - 데이터 커버리지

    func testEveryBasicKanaHasAtLeastTwoWords() {
        for script in KanaScript.allCases {
            for kana in KanaData.kana(script: script, groups: [.basic]) {
                XCTAssertGreaterThanOrEqual(
                    KanaWordBank.words(for: kana).count, 2,
                    "\(kana.character)의 예시 단어가 2개 미만입니다"
                )
            }
        }
    }

    func testEveryWordContainsItsKanaCharacter() {
        for kana in KanaData.all {
            for word in KanaWordBank.words(for: kana) {
                XCTAssertTrue(
                    word.word.contains(kana.character),
                    "단어 '\(word.word)'에 \(kana.character)가 없습니다"
                )
            }
        }
    }

    func testEveryWordHasNonEmptyMeaning() {
        for kana in KanaData.all {
            for word in KanaWordBank.words(for: kana) {
                XCTAssertFalse(word.meaning.isEmpty, "'\(word.word)'의 뜻이 비어 있습니다")
            }
        }
    }

    func testWordsWithinAKanaAreUnique() {
        for kana in KanaData.all {
            let words = KanaWordBank.words(for: kana).map(\.word)
            XCTAssertEqual(words.count, Set(words).count, "\(kana.character)의 단어가 중복됩니다")
        }
    }

    // MARK: - 무작위 선택

    func testRandomWordsReturnsAtMostRequestedCount() {
        for kana in KanaData.all {
            let picked = KanaWordBank.randomWords(for: kana, count: 2)
            XCTAssertLessThanOrEqual(picked.count, 2)
        }
    }

    func testRandomWordsAreUnique() {
        guard let kana = KanaData.all.first(where: { $0.character == "あ" }) else {
            return XCTFail("あ를 찾을 수 없습니다")
        }
        for _ in 0..<50 {
            let picked = KanaWordBank.randomWords(for: kana, count: 2)
            XCTAssertEqual(picked.count, Set(picked.map(\.word)).count)
        }
    }

    func testRandomWordsVaryAcrossCalls() {
        guard let kana = KanaData.all.first(where: { $0.character == "あ" }),
              KanaWordBank.words(for: kana).count >= 3 else {
            return XCTFail("단어가 3개 이상인 가나가 필요합니다")
        }
        let selections = (0..<30).map {
            _ in KanaWordBank.randomWords(for: kana, count: 2).map(\.word)
        }
        XCTAssertGreaterThan(Set(selections).count, 1, "무작위 선택이 매번 동일합니다")
    }
}
