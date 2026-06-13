import Foundation

/// 퀴즈에 들어가는 항목: 문제로 보여줄 텍스트와 정답 텍스트.
public struct QuizItem: Hashable, Sendable, Identifiable {
    public let id: String
    public let prompt: String
    public let answer: String

    public init(id: String, prompt: String, answer: String) {
        self.id = id
        self.prompt = prompt
        self.answer = answer
    }
}

public extension Kana {
    /// 가나 → 로마자 발음 맞추기 문제.
    var quizItem: QuizItem {
        QuizItem(id: "kana:\(character)", prompt: character, answer: romaji)
    }
}

public extension VocabWord {
    /// 단어 → 한국어 뜻 맞추기 문제.
    func quizItem(deck: VocabDeckKind) -> QuizItem {
        QuizItem(id: "\(deck.rawValue):\(word)", prompt: word, answer: meaning)
    }
}

/// 퀴즈 한 문제: 항목을 보고 올바른 답을 고른다.
public struct QuizQuestion: Hashable, Sendable {
    public let item: QuizItem
    public let choices: [String]

    public var answer: String { item.answer }

    public init(item: QuizItem, choices: [String]) {
        self.item = item
        self.choices = choices
    }
}

public enum QuizEngineError: Error, Equatable {
    /// 보기 수를 채울 만큼 서로 다른 답이 풀에 없음.
    case insufficientPool
}

/// 불변 데이터를 기반으로 퀴즈를 생성하는 순수 함수 모음.
public enum QuizEngine {

    public static let defaultChoiceCount = 4

    /// 풀에서 무작위 한 문제를 생성한다.
    public static func makeQuestion(
        from pool: [QuizItem],
        choiceCount: Int = defaultChoiceCount
    ) throws -> QuizQuestion {
        var generator = SystemRandomNumberGenerator()
        return try makeQuestion(from: pool, choiceCount: choiceCount, using: &generator)
    }

    public static func makeQuestion<G: RandomNumberGenerator>(
        from pool: [QuizItem],
        choiceCount: Int = defaultChoiceCount,
        using generator: inout G
    ) throws -> QuizQuestion {
        guard let item = pool.randomElement(using: &generator) else {
            throw QuizEngineError.insufficientPool
        }
        return try makeQuestion(item: item, pool: pool, choiceCount: choiceCount, using: &generator)
    }

    /// 풀에서 서로 다른 항목을 골라 `questionCount`문제 퀴즈를 만든다.
    /// 풀이 더 작으면 풀 크기만큼만 생성한다.
    public static func makeQuiz(
        from pool: [QuizItem],
        questionCount: Int,
        choiceCount: Int = defaultChoiceCount
    ) throws -> [QuizQuestion] {
        var generator = SystemRandomNumberGenerator()
        return try makeQuiz(
            from: pool,
            questionCount: questionCount,
            choiceCount: choiceCount,
            using: &generator
        )
    }

    public static func makeQuiz<G: RandomNumberGenerator>(
        from pool: [QuizItem],
        questionCount: Int,
        choiceCount: Int = defaultChoiceCount,
        using generator: inout G
    ) throws -> [QuizQuestion] {
        guard !pool.isEmpty else { throw QuizEngineError.insufficientPool }
        let items = pool.shuffled(using: &generator).prefix(questionCount)
        return try items.map { item in
            try makeQuestion(item: item, pool: pool, choiceCount: choiceCount, using: &generator)
        }
    }

    private static func makeQuestion<G: RandomNumberGenerator>(
        item: QuizItem,
        pool: [QuizItem],
        choiceCount: Int,
        using generator: inout G
    ) throws -> QuizQuestion {
        let distractors = Set(pool.map(\.answer)).subtracting([item.answer])
        guard distractors.count >= choiceCount - 1 else {
            throw QuizEngineError.insufficientPool
        }
        let picked = distractors
            .shuffled(using: &generator)
            .prefix(choiceCount - 1)
        let choices = ([item.answer] + picked).shuffled(using: &generator)
        return QuizQuestion(item: item, choices: choices)
    }
}
