import SwiftUI
import KanaCore

/// 4지선다 퀴즈: 가나를 보고 로마자를 고른다.
struct QuizView: View {
    let script: KanaScript
    let pool: [Kana]

    private static let questionCount = 10

    @State private var questions: [QuizQuestion] = []
    @State private var currentIndex = 0
    @State private var score = 0
    @State private var selectedChoice: String?
    @State private var isFinished = false
    @State private var loadFailed = false

    var body: some View {
        Group {
            if loadFailed {
                Text("퀴즈를 만들 수 없습니다.\n학습 범위를 확인해 주세요.")
                    .multilineTextAlignment(.center)
            } else if isFinished {
                QuizResultView(
                    score: score,
                    total: questions.count,
                    script: script,
                    onRestart: startQuiz
                )
            } else if let question = currentQuestion {
                questionView(question)
            } else {
                ProgressView()
            }
        }
        .navigationTitle(isFinished ? "결과" : "퀴즈")
        .onAppear(perform: startQuiz)
    }

    private var currentQuestion: QuizQuestion? {
        questions.indices.contains(currentIndex) ? questions[currentIndex] : nil
    }

    private func questionView(_ question: QuizQuestion) -> some View {
        ScrollView {
            VStack(spacing: 8) {
                Text("\(currentIndex + 1)/\(questions.count)")
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Text(question.prompt.character)
                    .font(.system(size: 48, weight: .bold))

                ForEach(question.choices, id: \.self) { choice in
                    ChoiceButton(
                        label: choice,
                        state: buttonState(for: choice, in: question)
                    ) {
                        select(choice, in: question)
                    }
                }
            }
        }
    }

    private func buttonState(for choice: String, in question: QuizQuestion) -> ChoiceButton.State {
        guard let selected = selectedChoice else { return .idle }
        if choice == question.answer { return .correct }
        if choice == selected { return .wrong }
        return .idle
    }

    private func select(_ choice: String, in question: QuizQuestion) {
        guard selectedChoice == nil else { return }
        selectedChoice = choice
        if choice == question.answer {
            score += 1
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
            advance()
        }
    }

    private func advance() {
        selectedChoice = nil
        if currentIndex + 1 < questions.count {
            currentIndex += 1
        } else {
            isFinished = true
        }
    }

    private func startQuiz() {
        do {
            questions = try QuizEngine.makeQuiz(from: pool, questionCount: Self.questionCount)
            currentIndex = 0
            score = 0
            selectedChoice = nil
            isFinished = false
            loadFailed = false
        } catch {
            loadFailed = true
        }
    }
}

/// 정답/오답 상태에 따라 색이 바뀌는 보기 버튼.
struct ChoiceButton: View {
    enum State {
        case idle, correct, wrong
    }

    let label: String
    let state: State
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(label)
                .font(.body)
                .frame(maxWidth: .infinity)
        }
        .tint(tint)
        .buttonStyle(.borderedProminent)
    }

    private var tint: Color {
        switch state {
        case .idle: return .gray
        case .correct: return .green
        case .wrong: return .red
        }
    }
}

#Preview {
    NavigationStack {
        QuizView(
            script: .hiragana,
            pool: KanaData.kana(script: .hiragana, groups: [.basic])
        )
    }
}
