import SwiftUI
import KanaCore

/// 단어집 목록: 단어·읽기·뜻을 한눈에 스크롤로 훑는다.
struct VocabListView: View {
    let title: String
    let words: [VocabWord]

    var body: some View {
        List(words) { word in
            VocabRow(word: word)
                .slateRow()
        }
        .slateScreen()
        .navigationTitle(title)
    }
}

private struct VocabRow: View {
    let word: VocabWord

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            HStack(alignment: .firstTextBaseline, spacing: 6) {
                Text(word.word)
                    .font(.headline)

                if word.hasDistinctReading {
                    Text(word.reading)
                        .font(.caption)
                        .foregroundStyle(Theme.mint)
                }
            }

            Text(word.meaning)
                .font(.caption)
                .foregroundStyle(Theme.slate400)
        }
        .padding(.vertical, 2)
    }
}

#Preview {
    NavigationStack {
        VocabListView(title: "여행", words: VocabData.words(for: .travel))
    }
}
