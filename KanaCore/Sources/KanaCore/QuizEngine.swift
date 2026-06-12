import Foundation

/// 퀴즈 한 문제: 가나 문자를 보고 올바른 로마자를 고른다.
public struct QuizQuestion: Hashable, Sendable {
    public let prompt: Kana
    public let choices: [String]

    public var answer: String { prompt.romaji }

    public init(prompt: Kana, choices: [String]) {
        self.prompt = prompt
        self.choices = choices
    }
}

public enum QuizEngineError: Error, Equatable {
    /// 보기 수를 채울 만큼 서로 다른 로마자가 풀에 없음.
    case insufficientPool
}

/// 불변 데이터를 기반으로 퀴즈를 생성하는 순수 함수 모음.
public enum QuizEngine {

    public static let defaultChoiceCount = 4

    /// 풀에서 무작위 한 문제를 생성한다.
    public static func makeQuestion(
        from pool: [Kana],
        choiceCount: Int = defaultChoiceCount
    ) throws -> QuizQuestion {
        var generator = SystemRandomNumberGenerator()
        return try makeQuestion(from: pool, choiceCount: choiceCount, using: &generator)
    }

    public static func makeQuestion<G: RandomNumberGenerator>(
        from pool: [Kana],
        choiceCount: Int = defaultChoiceCount,
        using generator: inout G
    ) throws -> QuizQuestion {
        guard let prompt = pool.randomElement(using: &generator) else {
            throw QuizEngineError.insufficientPool
        }
        return try makeQuestion(prompt: prompt, pool: pool, choiceCount: choiceCount, using: &generator)
    }

    /// 풀에서 서로 다른 문자를 골라 `questionCount`문제 퀴즈를 만든다.
    /// 풀이 더 작으면 풀 크기만큼만 생성한다.
    public static func makeQuiz(
        from pool: [Kana],
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
        from pool: [Kana],
        questionCount: Int,
        choiceCount: Int = defaultChoiceCount,
        using generator: inout G
    ) throws -> [QuizQuestion] {
        guard !pool.isEmpty else { throw QuizEngineError.insufficientPool }
        let prompts = pool.shuffled(using: &generator).prefix(questionCount)
        return try prompts.map { prompt in
            try makeQuestion(prompt: prompt, pool: pool, choiceCount: choiceCount, using: &generator)
        }
    }

    private static func makeQuestion<G: RandomNumberGenerator>(
        prompt: Kana,
        pool: [Kana],
        choiceCount: Int,
        using generator: inout G
    ) throws -> QuizQuestion {
        let distractorRomaji = Set(pool.map(\.romaji)).subtracting([prompt.romaji])
        guard distractorRomaji.count >= choiceCount - 1 else {
            throw QuizEngineError.insufficientPool
        }
        let distractors = distractorRomaji
            .shuffled(using: &generator)
            .prefix(choiceCount - 1)
        let choices = ([prompt.romaji] + distractors).shuffled(using: &generator)
        return QuizQuestion(prompt: prompt, choices: choices)
    }
}
