#if os(iOS)
import SwiftUI
import KanaCore

/// 가져온 사용자 덱 홈: 공부하기 / 목록 / 퀴즈 / 삭제.
struct CustomDeckHomeView: View {
    let deck: CustomDeck

    @Environment(\.dismiss) private var dismiss
    @State private var isDeleteConfirmPresented = false

    var body: some View {
        List {
            NavigationLink {
                VocabStudyView(title: deck.name, words: deck.words)
            } label: {
                Label("공부하기", systemImage: "shuffle")
            }
            .slateRow()
            .noSeparatorOnIOS()

            NavigationLink {
                VocabListView(title: deck.name, words: deck.words)
            } label: {
                Label("목록 보기", systemImage: "list.bullet")
            }
            .slateRow()
            .noSeparatorOnIOS()

            NavigationLink {
                QuizView(
                    title: "단어 퀴즈",
                    items: deck.words.map { word in
                        QuizItem(
                            id: "custom:\(deck.id.uuidString):\(word.word)",
                            prompt: word.word,
                            answer: word.meaning
                        )
                    },
                    scoreKey: "bestScore.custom.\(deck.id.uuidString)"
                )
            } label: {
                Label("단어 퀴즈", systemImage: "questionmark.circle")
            }
            .slateRow()
            .noSeparatorOnIOS()

            HStack {
                Text("단어 수")
                Spacer()
                Text("\(deck.words.count)개")
                    .foregroundStyle(Theme.slate400)
            }
            .slateRow()
            .noSeparatorOnIOS()

            Button(role: .destructive) {
                isDeleteConfirmPresented = true
            } label: {
                Label("덱 삭제", systemImage: "trash")
            }
            .slateRow()
            .noSeparatorOnIOS()
        }
        .spacedListOnIOS()
        .slateScreen()
        .navigationTitle(deck.name)
        .confirmationDialog(
            "'\(deck.name)' 덱을 삭제할까요?",
            isPresented: $isDeleteConfirmPresented,
            titleVisibility: .visible
        ) {
            Button("삭제", role: .destructive) {
                CustomDeckStore.shared.remove(id: deck.id)
                dismiss()
            }
        }
    }
}
#endif
