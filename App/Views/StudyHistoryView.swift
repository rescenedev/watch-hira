import SwiftUI
import KanaCore

/// 배운 단어를 날짜별로 정리해 보여준다. 오늘이 맨 위, 그 아래로 지난 날들.
struct StudyHistoryView: View {
    @ObservedObject private var store = StudyLogStore.shared

    var body: some View {
        Group {
            if store.history.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(store.history, id: \.day) { day, items in
                        Section {
                            ForEach(items) { item in
                                StudyHistoryRow(item: item)
                                    .slateRow()
                                    .noSeparatorOnIOS()
                            }
                        } header: {
                            Text(Self.sectionTitle(for: day, count: items.count))
                                .foregroundStyle(Theme.slate300)
                        }
                    }
                }
                .spacedListOnIOS()
            }
        }
        .slateScreen()
        .navigationTitle("배운 단어")
    }

    private var emptyState: some View {
        Text("카드를 넘기면\n날짜별로 모아서 보여드려요")
            .font(.footnote)
            .foregroundStyle(.secondary)
            .multilineTextAlignment(.center)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .padding()
    }

    private static func sectionTitle(for day: Date, count: Int) -> String {
        let calendar = Calendar.current
        let label: String
        if calendar.isDateInToday(day) {
            label = "오늘"
        } else if calendar.isDateInYesterday(day) {
            label = "어제"
        } else {
            label = dateFormatter.string(from: day)
        }
        return "\(label) · \(count)개"
    }

    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "ko_KR")
        formatter.setLocalizedDateFormatFromTemplate("Md")
        return formatter
    }()
}

private struct StudyHistoryRow: View {
    let item: StudiedItem

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            // 글자
            VStack(alignment: .leading, spacing: 2) {
                HStack(alignment: .firstTextBaseline, spacing: 5) {
                    Text(item.front)
                        .font(.headline)
                    if let reading = item.reading {
                        Text(reading)
                            .font(.caption2)
                            .foregroundStyle(Theme.mint)
                    }
                }
                Text(item.meaning)
                    .font(.caption2)
                    .foregroundStyle(Theme.slate400)
            }
            .frame(width: 96, alignment: .leading)

            // 문장 (글자와 소리 사이 가운데)
            #if os(iOS)
            if let example {
                VStack(alignment: .center, spacing: 1) {
                    Text(example.japanese)
                        .font(.caption)
                        .foregroundStyle(Theme.slate300)
                    if let korean = example.korean {
                        Text(korean)
                            .font(.caption2)
                            .foregroundStyle(Theme.slate400)
                    }
                }
                .multilineTextAlignment(.center)
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Spacer(minLength: 0)
            }
            #else
            Spacer(minLength: 0)
            #endif

            // 소리
            SpeakerButton(text: item.reading ?? item.front)
        }
        .padding(.vertical, 2)
    }

    #if os(iOS)
    /// 단어에는 짧은 예문을, 가나에는 그 글자가 든 예시 단어 하나를 보여준다.
    private var example: ExampleSentence? {
        if item.id.hasPrefix("kana:") {
            // 가나는 그 글자가 든 예시 단어로 짧은 문장을 보여준다.
            guard let word = KanaWordBank.words(forCharacter: item.front).first else { return nil }
            return ExampleSentenceBank.sentence(forWord: word.word)
        }
        return ExampleSentenceBank.sentence(forWord: item.front)
    }
    #endif
}

#Preview {
    NavigationStack {
        StudyHistoryView()
    }
}
