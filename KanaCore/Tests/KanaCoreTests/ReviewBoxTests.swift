import XCTest
@testable import KanaCore

final class ReviewBoxTests: XCTestCase {

    func testStartsEmpty() {
        XCTAssertTrue(ReviewBox().dueIDs.isEmpty)
    }

    func testWrongAnswerAddsToDue() {
        var box = ReviewBox()
        box.recordWrong(id: "kana:あ")
        XCTAssertEqual(box.dueIDs, ["kana:あ"])
    }

    func testNeedsTwoCorrectAnswersToGraduate() {
        var box = ReviewBox()
        box.recordWrong(id: "kana:あ")

        box.recordCorrect(id: "kana:あ")
        XCTAssertEqual(box.dueIDs, ["kana:あ"], "정답 1번으로는 졸업하면 안 됩니다")

        box.recordCorrect(id: "kana:あ")
        XCTAssertTrue(box.dueIDs.isEmpty, "정답 2번이면 졸업해야 합니다")
    }

    func testRepeatedWrongAnswersAccumulate() {
        var box = ReviewBox()
        box.recordWrong(id: "n3:経験")
        box.recordWrong(id: "n3:経験")

        (0..<3).forEach { _ in box.recordCorrect(id: "n3:経験") }
        XCTAssertEqual(box.dueIDs, ["n3:経験"], "오답 2번이면 정답 4번이 필요합니다")

        box.recordCorrect(id: "n3:経験")
        XCTAssertTrue(box.dueIDs.isEmpty)
    }

    func testCorrectAnswerForUnknownIDIsNoOp() {
        var box = ReviewBox()
        box.recordCorrect(id: "kana:ん")
        XCTAssertTrue(box.dueIDs.isEmpty)
    }

    func testDueIDsAreSortedForStability() {
        var box = ReviewBox()
        box.recordWrong(id: "b")
        box.recordWrong(id: "a")
        XCTAssertEqual(box.dueIDs, ["a", "b"])
    }

    func testCodableRoundTrip() throws {
        var box = ReviewBox()
        box.recordWrong(id: "kana:あ")
        box.recordWrong(id: "travel:駅")

        let data = try JSONEncoder().encode(box)
        let decoded = try JSONDecoder().decode(ReviewBox.self, from: data)
        XCTAssertEqual(decoded, box)
    }
}
