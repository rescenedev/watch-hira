import XCTest

final class KanaStudyUITests: XCTestCase {

    private let kanaCardPredicate = NSPredicate(format: "label MATCHES %@", "^[ぁ-ゖァ-ヶ]$")
    private let romajiPredicate = NSPredicate(format: "label MATCHES %@", "^[a-z]{1,3}$")

    override func setUpWithError() throws {
        continueAfterFailure = false
    }

    func testStudyCardShowsEverythingAndAdvancesOnTap() throws {
        let app = XCUIApplication()
        app.launch()

        app.staticTexts["히라가나"].tap()

        let studyLink = app.staticTexts["공부하기"]
        XCTAssertTrue(studyLink.waitForExistence(timeout: 10))
        studyLink.tap()

        let card = app.staticTexts.matching(kanaCardPredicate).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 10))
        let firstCharacter = card.label

        let romaji = app.staticTexts.matching(romajiPredicate).firstMatch
        XCTAssertTrue(romaji.waitForExistence(timeout: 10), "발음은 탭 없이 바로 보여야 합니다")

        app.staticTexts[firstCharacter].tap()

        let nextCard = app.staticTexts.matching(kanaCardPredicate).firstMatch
        XCTAssertTrue(nextCard.waitForExistence(timeout: 10))
        XCTAssertNotEqual(nextCard.label, firstCharacter, "탭하면 다음 글자로 넘어가야 합니다")
    }

    func testBrowseListShowsRomajiWithoutTapping() throws {
        let app = XCUIApplication()
        app.launch()

        app.staticTexts["히라가나"].tap()

        let browseLink = app.staticTexts["순서대로 보기"]
        XCTAssertTrue(browseLink.waitForExistence(timeout: 10))
        browseLink.tap()

        let firstRow = app.staticTexts["あ"]
        XCTAssertTrue(firstRow.waitForExistence(timeout: 10), "순서대로 보기는 あ부터 시작해야 합니다")

        XCTAssertTrue(
            app.staticTexts["a"].waitForExistence(timeout: 10),
            "발음은 탭 없이 리스트에 바로 보여야 합니다"
        )
    }

    func testQuizFlowShowsQuestionAndAcceptsAnswer() throws {
        let app = XCUIApplication()
        app.launch()

        app.staticTexts["가타카나"].tap()

        let quizLink = app.staticTexts["퀴즈"]
        XCTAssertTrue(quizLink.waitForExistence(timeout: 10))
        quizLink.tap()

        let progress = app.staticTexts["1/10"]
        XCTAssertTrue(progress.waitForExistence(timeout: 10))

        let firstChoice = app.buttons.matching(romajiPredicate).firstMatch
        XCTAssertTrue(firstChoice.waitForExistence(timeout: 10))
        firstChoice.tap()

        let nextProgress = app.staticTexts["2/10"]
        XCTAssertTrue(nextProgress.waitForExistence(timeout: 10))
    }
}
