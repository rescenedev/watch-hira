import SwiftUI
import KanaCore

/// 선택한 문자 체계의 홈: 학습/퀴즈 진입과 범위 설정.
struct ScriptHomeView: View {
    let script: KanaScript

    @AppStorage("includeVoiced") private var includeVoiced = false
    @AppStorage("includeYoon") private var includeYoon = false
    @AppStorage("autoSpeak") private var autoSpeak = false

    private var pool: [Kana] {
        var groups: Set<KanaGroup> = [.basic]
        if includeVoiced {
            groups.formUnion([.dakuon, .handakuon])
        }
        if includeYoon {
            groups.insert(.yoon)
        }
        return KanaData.kana(script: script, groups: groups)
    }

    private var bestScoreKey: String { "bestScore.\(script.rawValue)" }

    var body: some View {
        List {
            NavigationLink {
                StudyView(title: title, kanaList: pool)
            } label: {
                Label("공부하기", systemImage: "shuffle")
            }
            .slateRow()
            .noSeparatorOnIOS()

            NavigationLink {
                BrowseView(title: title, kanaList: pool)
            } label: {
                Label("순서대로 보기", systemImage: "list.bullet")
            }
            .slateRow()
            .noSeparatorOnIOS()

            NavigationLink {
                QuizView(
                    title: "퀴즈",
                    items: pool.map(\.quizItem),
                    scoreKey: bestScoreKey
                )
            } label: {
                Label("퀴즈", systemImage: "questionmark.circle")
            }
            .slateRow()
            .noSeparatorOnIOS()

            Toggle("탁음·반탁음 포함", isOn: $includeVoiced)
                .slateRow()
                .noSeparatorOnIOS()

            Toggle("요음 포함 (きゃ 등)", isOn: $includeYoon)
                .slateRow()
                .noSeparatorOnIOS()

            Toggle("자동 발음", isOn: $autoSpeak)
                .slateRow()
                .noSeparatorOnIOS()

            BestScoreRow(key: bestScoreKey)
                .slateRow()
            .noSeparatorOnIOS()
        }
        .spacedListOnIOS()
        .slateScreen()
        .navigationTitle(title)
    }

    private var title: String {
        script == .hiragana ? "히라가나" : "가타카나"
    }
}

private struct BestScoreRow: View {
    let key: String

    var body: some View {
        let best = UserDefaults.standard.integer(forKey: key)
        if best > 0 {
            HStack {
                Text("최고 점수")
                Spacer()
                Text("\(best)점")
                    .foregroundStyle(.secondary)
            }
        }
    }
}

#Preview {
    NavigationStack {
        ScriptHomeView(script: .hiragana)
    }
}
