import XCTest
@testable import KanaCore

final class QuizEngineTests: XCTestCase {

    private let hiragana = KanaData.kana(script: .hiragana, groups: [.basic])

    // MARK: - 단일 문제

    func testQuestionHasFourChoices() throws {
        for _ in 0..<50 {
            let question = try QuizEngine.makeQuestion(from: hiragana)
            XCTAssertEqual(question.choices.count, 4)
        }
    }

    func testChoicesAreUniqueRomaji() throws {
        for _ in 0..<50 {
            let question = try QuizEngine.makeQuestion(from: hiragana)
            XCTAssertEqual(question.choices.count, Set(question.choices).count)
        }
    }

    func testAnswerIsAlwaysAmongChoices() throws {
        for _ in 0..<50 {
            let question = try QuizEngine.makeQuestion(from: hiragana)
            XCTAssertTrue(question.choices.contains(question.answer))
        }
    }

    func testAnswerMatchesPromptRomaji() throws {
        let question = try QuizEngine.makeQuestion(from: hiragana)
        XCTAssertEqual(question.answer, question.prompt.romaji)
    }

    // MARK: - 퀴즈 세트

    func testQuizHasRequestedQuestionCount() throws {
        let quiz = try QuizEngine.makeQuiz(from: hiragana, questionCount: 10)
        XCTAssertEqual(quiz.count, 10)
    }

    func testQuizPromptsAreUnique() throws {
        for _ in 0..<20 {
            let quiz = try QuizEngine.makeQuiz(from: hiragana, questionCount: 10)
            let prompts = quiz.map(\.prompt.character)
            XCTAssertEqual(prompts.count, Set(prompts).count)
        }
    }

    func testQuizCountIsClampedToPoolSize() throws {
        let smallPool = Array(hiragana.prefix(6))
        let quiz = try QuizEngine.makeQuiz(from: smallPool, questionCount: 10)
        XCTAssertEqual(quiz.count, 6)
    }

    // MARK: - 오류 처리

    func testInsufficientPoolThrows() {
        let tinyPool = Array(hiragana.prefix(3))
        XCTAssertThrowsError(try QuizEngine.makeQuestion(from: tinyPool)) { error in
            XCTAssertEqual(error as? QuizEngineError, .insufficientPool)
        }
    }

    func testEmptyPoolThrows() {
        XCTAssertThrowsError(try QuizEngine.makeQuiz(from: [], questionCount: 5))
    }

    // MARK: - 중복 로마자 풀 (ぢ/じ → ji)

    func testDuplicateRomajiPoolStillProducesUniqueChoices() throws {
        let fullPool = KanaData.kana(script: .hiragana)
        for _ in 0..<100 {
            let question = try QuizEngine.makeQuestion(from: fullPool)
            XCTAssertEqual(question.choices.count, Set(question.choices).count)
            XCTAssertTrue(question.choices.contains(question.answer))
        }
    }
}
