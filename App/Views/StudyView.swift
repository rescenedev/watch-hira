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
                KanaCardView(kana: kana, onAdvance: advance, onRetreat: retreat)
                    .tag(index)
            }
        }
        .pagingTabViewStyle()
        .slateScreen()
        .progressNavigationTitle(progressTitle)
        .onAppear(perform: prepareDeck)
    }

    private var progressTitle: String {
        deck.isEmpty ? title : "\(currentIndex + 1)/\(deck.count)"
    }

    private func prepareDeck() {
        guard deck.isEmpty else { return }
        deck = kanaList.shuffled()
        StudyLogStore.shared.record()
    }

    private func advance() {
        guard !deck.isEmpty else { return }
        StudyLogStore.shared.record()
        withAnimation {
            currentIndex = (currentIndex + 1) % deck.count
        }
    }

    private func retreat() {
        guard !deck.isEmpty else { return }
        withAnimation {
            currentIndex = (currentIndex - 1 + deck.count) % deck.count
        }
    }
}

/// 화면을 세로(watchOS)/가로(iOS)로 넘기는 페이지 스타일.
private extension View {
    @ViewBuilder
    func pagingTabViewStyle() -> some View {
        #if os(watchOS)
        tabViewStyle(.verticalPage)
        #else
        tabViewStyle(.page(indexDisplayMode: .never))
        #endif
    }

    /// 진행 카운터는 watchOS에서만 타이틀로 보여준다 (iOS에서는 숨김).
    @ViewBuilder
    func progressNavigationTitle(_ title: String) -> some View {
        #if os(watchOS)
        navigationTitle(title)
        #else
        self
        #endif
    }
}

/// 카드 한 장: 가나 문자와 발음, 예시 단어를 바로 보여준다.
/// 오른쪽 절반을 탭하면 다음 글자, 왼쪽 절반을 탭하면 이전 글자.
struct KanaCardView: View {
    let kana: Kana
    var onAdvance: () -> Void = {}
    var onRetreat: () -> Void = {}

    @AppStorage("autoSpeak") private var autoSpeak = false
    @State private var exampleWords: [KanaWord] = []

    #if os(watchOS)
    private let glyphSize: CGFloat = 46
    private let cardSpacing: CGFloat = 6
    #else
    private let glyphSize: CGFloat = 140
    private let cardSpacing: CGFloat = 16
    #endif

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: cardSpacing) {
                Text(kana.character)
                    .font(.system(size: glyphSize, weight: .bold))
                    .minimumScaleFactor(0.5)

                Text(kana.romaji)
                    .font(romajiFont)
                    .foregroundStyle(Theme.mint)

                wordList

                HStack {
                    SpeakerButton(text: kana.character)
                    Spacer()
                    StarButton(itemID: kana.quizItem.id)
                }
                .padding(.horizontal, 24)
            }
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .cardTapNavigation(width: geometry.size.width, onAdvance: onAdvance, onRetreat: onRetreat)
        }
        .onAppear {
            pickWords()
            if autoSpeak {
                SpeechService.shared.speakJapanese(kana.character)
            }
        }
    }

    private var romajiFont: Font {
        #if os(watchOS)
        .title3.bold()
        #else
        .largeTitle.bold()
        #endif
    }

    private var wordFont: Font {
        #if os(watchOS)
        .footnote
        #else
        .title3
        #endif
    }

    private var wordList: some View {
        VStack(spacing: 2) {
            ForEach(exampleWords, id: \.word) { example in
                HStack(spacing: 4) {
                    Text(example.word)
                        .font(wordFont.bold())
                    Text(example.meaning)
                        .font(wordFont)
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
