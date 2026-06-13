import SwiftUI
import KanaCore

/// 단어집 홈: 공부하기(랜덤 카드)와 목록 보기.
struct VocabHomeView: View {
    let kind: VocabDeckKind

    private var words: [VocabWord] {
        VocabData.words(for: kind)
    }

    var body: some View {
        List {
            NavigationLink {
                VocabStudyView(title: kind.title, words: words)
            } label: {
                Label("공부하기", systemImage: "shuffle")
            }
            .slateRow()
            .noSeparatorOnIOS()

            NavigationLink {
                VocabListView(title: kind.title, words: words)
            } label: {
                Label("목록 보기", systemImage: "list.bullet")
            }
            .slateRow()
            .noSeparatorOnIOS()

            HStack {
                Text("단어 수")
                Spacer()
                Text("\(words.count)개")
                    .foregroundStyle(Theme.slate400)
            }
            .slateRow()
            .noSeparatorOnIOS()
        }
        .spacedListOnIOS()
        .slateScreen()
        .navigationTitle(kind.title)
    }
}

#Preview {
    NavigationStack {
        VocabHomeView(kind: .jlptN3)
    }
}
