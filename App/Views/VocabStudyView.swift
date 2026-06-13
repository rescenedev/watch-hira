import SwiftUI
import KanaCore

/// 단어 플래시카드. 들어갈 때마다 순서가 섞이고,
/// 오른쪽 절반 탭 = 다음 단어, 왼쪽 절반 탭 = 이전 단어. 스와이프도 가능.
struct VocabStudyView: View {
    let title: String
    let words: [VocabWord]
    var deckKind: VocabDeckKind?

    @State private var deck: [VocabWord] = []
    @State private var currentIndex = 0

    var body: some View {
        TabView(selection: $currentIndex) {
            ForEach(Array(deck.enumerated()), id: \.element.id) { index, word in
                VocabCardView(
                    word: word,
                    deckKind: deckKind,
                    onAdvance: advance,
                    onRetreat: retreat
                )
                .tag(index)
            }
        }
        .vocabPagingStyle()
        .slateScreen()
        .vocabProgressTitle(deck.isEmpty ? title : "\(currentIndex + 1)/\(deck.count)")
        .onAppear(perform: prepareDeck)
    }

    private func prepareDeck() {
        guard deck.isEmpty else { return }
        deck = words.shuffled()
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

private extension View {
    @ViewBuilder
    func vocabPagingStyle() -> some View {
        #if os(watchOS)
        tabViewStyle(.verticalPage)
        #else
        tabViewStyle(.page(indexDisplayMode: .never))
        #endif
    }

    @ViewBuilder
    func vocabProgressTitle(_ title: String) -> some View {
        #if os(watchOS)
        navigationTitle(title)
        #else
        self
        #endif
    }
}

/// 단어 카드 한 장: 단어, 읽기, 뜻을 바로 보여준다.
struct VocabCardView: View {
    let word: VocabWord
    var deckKind: VocabDeckKind?
    var onAdvance: () -> Void = {}
    var onRetreat: () -> Void = {}

    @AppStorage("autoSpeak") private var autoSpeak = false

    #if os(watchOS)
    private let wordSize: CGFloat = 34
    private let spacing: CGFloat = 6
    #else
    private let wordSize: CGFloat = 72
    private let spacing: CGFloat = 14
    #endif

    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: spacing) {
                Text(word.word)
                    .font(.system(size: wordSize, weight: .bold))
                    .minimumScaleFactor(0.4)
                    .lineLimit(1)

                if word.hasDistinctReading {
                    Text(word.reading)
                        .font(readingFont)
                        .foregroundStyle(Theme.mint)
                        .minimumScaleFactor(0.6)
                }

                Text(word.meaning)
                    .font(meaningFont)
                    .foregroundStyle(Theme.slate300)
                    .multilineTextAlignment(.center)

                HStack(spacing: 4) {
                    SpeakerButton(text: word.reading)
                    if let deckKind {
                        StarButton(itemID: word.quizItem(deck: deckKind).id)
                    }
                }
            }
            .padding(.horizontal, 8)
            .frame(width: geometry.size.width, height: geometry.size.height)
            .contentShape(Rectangle())
            .cardTapNavigation(width: geometry.size.width, onAdvance: onAdvance, onRetreat: onRetreat)
        }
        .onAppear {
            if autoSpeak {
                SpeechService.shared.speakJapanese(word.reading)
            }
        }
    }

    private var readingFont: Font {
        #if os(watchOS)
        .footnote.bold()
        #else
        .title2.bold()
        #endif
    }

    private var meaningFont: Font {
        #if os(watchOS)
        .footnote
        #else
        .title3
        #endif
    }
}

#Preview {
    NavigationStack {
        VocabStudyView(title: "JLPT N3", words: VocabData.words(for: .jlptN3))
    }
}
