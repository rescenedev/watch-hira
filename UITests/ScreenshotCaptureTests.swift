import XCTest

/// 문서화용 스크린샷 캡처 (CI 검증 대상 아님).
final class ScreenshotCaptureTests: XCTestCase {

    func testCaptureScreens() throws {
        let app = XCUIApplication()
        app.launch()

        save(screenshot: XCUIScreen.main.screenshot(), name: "1_menu")

        app.staticTexts["히라가나"].tap()
        XCTAssertTrue(app.staticTexts["공부하기"].waitForExistence(timeout: 10))
        save(screenshot: XCUIScreen.main.screenshot(), name: "2_home")

        app.staticTexts["공부하기"].tap()
        let card = app.staticTexts.matching(
            NSPredicate(format: "label MATCHES %@", "^[ぁ-ゖァ-ヶ]$")
        ).firstMatch
        XCTAssertTrue(card.waitForExistence(timeout: 10))
        card.tap()
        save(screenshot: XCUIScreen.main.screenshot(), name: "3_study")

        app.terminate()
        app.launch()
        app.staticTexts["히라가나"].tap()
        let quizLink = app.staticTexts["퀴즈"]
        XCTAssertTrue(quizLink.waitForExistence(timeout: 10))
        quizLink.tap()
        XCTAssertTrue(app.staticTexts["1/10"].waitForExistence(timeout: 10))
        save(screenshot: XCUIScreen.main.screenshot(), name: "4_quiz")
    }

    private func save(screenshot: XCUIScreenshot, name: String) {
        let attachment = XCTAttachment(screenshot: screenshot)
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}
