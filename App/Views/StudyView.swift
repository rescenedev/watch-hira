import SwiftUI
import KanaCore

/// 플래시카드 공부하기. 들어갈 때마다 순서가 섞여 매번 다른 글자부터 시작한다.
/// 발음과 예시 단어는 바로 표시되고, 탭하면 다음 글자. 세로 스와이프도 가능.
struct StudyView: View {
    let title: String
    let kanaList: [Kana]

    @State private var deck: [Kana] = []
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(deck.enumerated()), id: \.element.id) { index, kana in
                KanaCardView(kana: kana, onAdvance: advance)
                    .tag(index)
            }
        }
        .tabViewStyle(.verticalPage)
        .navigationTitle(progressTitle)
        .onAppear(perform: prepareDeck)
    }

    private var progressTitle: String {
        deck.isEmpty ? title : "\(currentIndex + 1)/\(deck.count)"
    }

    private func prepareDeck() {
        guard deck.isEmpty else { return }
        deck = kanaList.shuffled()
    }

    private func advance() {
        guard !deck.isEmpty else { return }
        withAnimation {
            currentIndex = (currentIndex + 1) % deck.count
        }
    }
}

/// 카드 한 장: 가나 문자와 발음, 예시 단어를 바로 보여준다. 탭하면 다음 글자.
struct KanaCardView: View {
    let kana: Kana
    var onAdvance: () -> Void = {}

    @State private var exampleWords: [KanaWord] = []

    var body: some View {
        VStack(spacing: 6) {
            Text(kana.character)
                .font(.system(size: 46, weight: .bold))
                .minimumScaleFactor(0.5)

            Text(kana.romaji)
                .font(.title3.bold())
                .foregroundStyle(.green)

            wordList
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .contentShape(Rectangle())
        .onTapGesture(perform: onAdvance)
        .onAppear(perform: pickWords)
    }

    private var wordList: some View {
        VStack(spacing: 2) {
            ForEach(exampleWords, id: \.word) { example in
                HStack(spacing: 4) {
                    Text(example.word)
                        .font(.footnote.bold())
                    Text(example.meaning)
                        .font(.footnote)
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                }
                .minimumScaleFactor(0.7)
            }
        }
    }

    private func pickWords() {
        exampleWords = KanaWordBank.randomWords(for: kana, count: 2)
    }
}

#Preview {
    NavigationStack {
        StudyView(
            title: "히라가나",
            kanaList: KanaData.kana(script: .hiragana, groups: [.basic])
        )
    }
}
