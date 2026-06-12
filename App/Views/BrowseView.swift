import SwiftUI
import KanaCore

/// 순서대로 보기: 오십음도 순서 리스트. 발음과 예시 단어가 바로 보이고 스크롤로 훑는다.
struct BrowseView: View {
    let title: String
    let kanaList: [Kana]

    var body: some View {
        List(kanaList) { kana in
            BrowseRow(kana: kana)
                .slateRow()
        }
        .slateScreen()
        .navigationTitle(title)
    }
}

/// 리스트 한 줄: 문자·로마자·예시 단어를 한눈에.
private struct BrowseRow: View {
    let kana: Kana

    @State private var exampleWords: [KanaWord] = []

    var body: some View {
        HStack(alignment: .center, spacing: 10) {
            Text(kana.character)
                .font(.title3.bold())

            VStack(alignment: .leading, spacing: 2) {
                Text(kana.romaji)
                    .font(.footnote.bold())
                    .foregroundStyle(Theme.mint)

                ForEach(exampleWords, id: \.word) { example in
                    Text("\(example.word) \(example.meaning)")
                        .font(.system(size: 12))
                        .foregroundStyle(Theme.slate400)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding(.vertical, 2)
        .onAppear(perform: pickWords)
    }

    private func pickWords() {
        guard exampleWords.isEmpty else { return }
        exampleWords = KanaWordBank.randomWords(for: kana, count: 1)
    }
}

#Preview {
    NavigationStack {
        BrowseView(
            title: "히라가나",
            kanaList: KanaData.kana(script: .hiragana, groups: [.basic])
        )
    }
}
