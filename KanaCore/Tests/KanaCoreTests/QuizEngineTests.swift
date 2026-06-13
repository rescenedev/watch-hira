import XCTest
@testable import KanaCore

final class QuizEngineTests: XCTestCase {

    private let kanaItems = KanaData.kana(script: .hiragana, groups: [.basic]).map(\.quizItem)
    private let vocabItems = VocabData.words(for: .jlptN3).map { $0.quizItem(deck: .jlptN3) }

    // MARK: - 단일 문제 (가나)

    func testQuestionHasFourChoices() throws {
        for _ in 0..<50 {
            let question = try QuizEngine.makeQuestion(from: kanaItems)
            XCTAssertEqual(question.choices.count, 4)
        }
    }

    func testChoicesAreUnique() throws {
        for _ in 0..<50 {
            let question = try QuizEngine.makeQuestion(from: kanaItems)
            XCTAssertEqual(question.choices.count, Set(question.choices).count)
        }
    }

    func testAnswerIsAlwaysAmongChoices() throws {
        for _ in 0..<50 {
            let question = try QuizEngine.makeQuestion(from: kanaItems)
            XCTAssertTrue(question.choices.contains(question.answer))
        }
    }

    func testAnswerMatchesItemAnswer() throws {
        let question = try QuizEngine.makeQuestion(from: kanaItems)
        XCTAssertEqual(question.answer, question.item.answer)
    }

    // MARK: - 단어 퀴즈

    func testVocabQuestionUsesMeaningsAsChoices() throws {
        let meanings = Set(vocabItems.map(\.answer))
        for _ in 0..<30 {
            let question = try QuizEngine.makeQuestion(from: vocabItems)
            for choice in question.choices {
                XCTAssertTrue(meanings.contains(choice), "보기 '\(choice)'가 덱의 뜻이 아닙니다")
            }
        }
    }

    func testVocabQuizWorksWithFullDeck() throws {
        let quiz = try QuizEngine.makeQuiz(from: vocabItems, questionCount: 10)
        XCTAssertEqual(quiz.count, 10)
        for question in quiz {
            XCTAssertEqual(question.choices.count, Set(question.choices).count)
            XCTAssertTrue(question.choices.contains(question.answer))
        }
    }

    // MARK: - 퀴즈 세트

    func testQuizHasRequestedQuestionCount() throws {
        let quiz = try QuizEngine.makeQuiz(from: kanaItems, questionCount: 10)
        XCTAssertEqual(quiz.count, 10)
    }

    func testQuizPromptsAreUnique() throws {
        for _ in 0..<20 {
            let quiz = try QuizEngine.makeQuiz(from: kanaItems, questionCount: 10)
            let prompts = quiz.map(\.item.id)
            XCTAssertEqual(prompts.count, Set(prompts).count)
        }
    }

    func testQuizCountIsClampedToPoolSize() throws {
        let smallPool = Array(kanaItems.prefix(6))
        let quiz = try QuizEngine.makeQuiz(from: smallPool, questionCount: 10)
        XCTAssertEqual(quiz.count, 6)
    }

    // MARK: - 오류 처리

    func testInsufficientPoolThrows() {
        let tinyPool = Array(kanaItems.prefix(3))
        XCTAssertThrowsError(try QuizEngine.makeQuestion(from: tinyPool)) { error in
            XCTAssertEqual(error as? QuizEngineError, .insufficientPool)
        }
    }

    func testEmptyPoolThrows() {
        XCTAssertThrowsError(try QuizEngine.makeQuiz(from: [], questionCount: 5))
    }

    // MARK: - 중복 답(ぢ/じ → ji 등) 풀

    func testDuplicateAnswerPoolStillProducesUniqueChoices() throws {
        let fullPool = KanaData.kana(script: .hiragana).map(\.quizItem)
        for _ in 0..<100 {
            let question = try QuizEngine.makeQuestion(from: fullPool)
            XCTAssertEqual(question.choices.count, Set(question.choices).count)
            XCTAssertTrue(question.choices.contains(question.answer))
        }
    }

    // MARK: - 매핑

    func testKanaQuizItemMapping() {
        guard let a = KanaData.all.first(where: { $0.character == "あ" }) else {
            return XCTFail("あ 없음")
        }
        let item = a.quizItem
        XCTAssertEqual(item.prompt, "あ")
        XCTAssertEqual(item.answer, "a")
        XCTAssertEqual(item.id, "kana:あ")
    }

    func testVocabQuizItemMapping() {
        guard let word = VocabData.words(for: .travel).first(where: { $0.word == "駅" }) else {
            return XCTFail("駅 없음")
        }
        let item = word.quizItem(deck: .travel)
        XCTAssertEqual(item.prompt, "駅")
        XCTAssertEqual(item.answer, "역")
        XCTAssertEqual(item.id, "travel:駅")
    }
}
