import SwiftUI
import KanaCore

/// 선택한 문자 체계의 홈: 학습/퀴즈 진입과 범위 설정.
struct ScriptHomeView: View {
    let script: KanaScript

    @AppStorage("includeVoiced") private var includeVoiced = false

    private var pool: [Kana] {
        let groups: Set<KanaGroup> = includeVoiced
            ? Set(KanaGroup.allCases)
            : [.basic]
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
                QuizView(script: script, pool: pool)
            } label: {
                Label("퀴즈", systemImage: "questionmark.circle")
            }
            .slateRow()
            .noSeparatorOnIOS()

            Toggle("탁음·반탁음 포함", isOn: $includeVoiced)
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
