import SwiftUI
import KanaCore

/// 퀴즈 종료 화면: 점수 표시, 최고 점수 갱신, 재도전.
struct QuizResultView: View {
    let score: Int
    let total: Int
    let script: KanaScript
    let onRestart: () -> Void

    private var bestScoreKey: String { "bestScore.\(script.rawValue)" }

    var body: some View {
        ScrollView {
            VStack(spacing: 10) {
                Image(systemName: symbolName)
                    .font(.system(size: 36))
                    .foregroundStyle(score == total ? .yellow : .blue)

                Text("\(score) / \(total)")
                    .font(.title2.bold())

                Text(message)
                    .font(.footnote)
                    .foregroundStyle(.secondary)

                Button("다시 풀기", action: onRestart)
                    .buttonStyle(.borderedProminent)
            }
        }
        .onAppear(perform: updateBestScore)
    }

    private var symbolName: String {
        score == total ? "trophy.fill" : "checkmark.circle.fill"
    }

    private var message: String {
        switch Double(score) / Double(max(total, 1)) {
        case 1.0: return "완벽해요!"
        case 0.7...: return "잘했어요!"
        case 0.4...: return "조금만 더!"
        default: return "다시 도전해 보세요"
        }
    }

    private func updateBestScore() {
        let defaults = UserDefaults.standard
        if score > defaults.integer(forKey: bestScoreKey) {
            defaults.set(score, forKey: bestScoreKey)
        }
    }
}

#Preview {
    NavigationStack {
        QuizResultView(score: 8, total: 10, script: .hiragana, onRestart: {})
    }
}
