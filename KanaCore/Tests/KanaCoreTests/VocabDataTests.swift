import XCTest
@testable import KanaCore

final class VocabDataTests: XCTestCase {

    func testJLPTN3DeckHasEnoughWords() {
        XCTAssertGreaterThanOrEqual(VocabData.words(for: .jlptN3).count, 100)
    }

    func testTravelDeckHasEnoughWords() {
        XCTAssertGreaterThanOrEqual(VocabData.words(for: .travel).count, 60)
    }

    func testWordsAreUniqueWithinEachDeck() {
        for kind in VocabDeckKind.allCases {
            let words = VocabData.words(for: kind).map(\.word)
            XCTAssertEqual(words.count, Set(words).count, "\(kind) 덱에 중복 단어가 있습니다")
        }
    }

    func testAllFieldsAreNonEmpty() {
        for kind in VocabDeckKind.allCases {
            for entry in VocabData.words(for: kind) {
                XCTAssertFalse(entry.word.isEmpty)
                XCTAssertFalse(entry.reading.isEmpty, "\(entry.word)의 읽기가 비어 있습니다")
                XCTAssertFalse(entry.meaning.isEmpty, "\(entry.word)의 뜻이 비어 있습니다")
            }
        }
    }

    func testEveryDeckKindHasTitle() {
        for kind in VocabDeckKind.allCases {
            XCTAssertFalse(kind.title.isEmpty)
        }
    }
}
