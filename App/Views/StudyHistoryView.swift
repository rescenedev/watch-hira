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
        VStack(spacing: 8) {
            Image(systemName: "book.closed")
                .font(.system(size: 36))
                .foregroundStyle(Theme.mint)
            Text("카드를 넘기면\n날짜별로 모아서 보여드려요")
                .font(.footnote)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
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
        HStack(alignment: .top, spacing: 10) {
            VStack(alignment: .leading, spacing: 4) {
                HStack(alignment: .firstTextBaseline, spacing: 6) {
                    Text(item.front)
                        .font(.headline)
                    if let reading = item.reading {
                        Text(reading)
                            .font(.caption)
                            .foregroundStyle(Theme.mint)
                    }
                }
                Text(item.meaning)
                    .font(.caption)
                    .foregroundStyle(Theme.slate400)

                #if os(iOS)
                if let example {
                    VStack(alignment: .leading, spacing: 1) {
                        Text(example.japanese)
                            .font(.caption)
                            .foregroundStyle(Theme.slate300)
                        if let korean = example.korean {
                            Text(korean)
                                .font(.caption2)
                                .foregroundStyle(Theme.slate400)
                        }
                    }
                    .padding(.top, 2)
                }
                #endif
            }
            Spacer(minLength: 8)
            SpeakerButton(text: item.reading ?? item.front)
        }
        .padding(.vertical, 2)
    }

    #if os(iOS)
    /// 단어에는 짧은 예문을 붙인다. 가나(한 글자)는 예문 없이 글자만 보여준다.
    private var example: ExampleSentence? {
        guard !item.id.hasPrefix("kana:") else { return nil }
        return ExampleSentenceBank.sentence(forWord: item.front)
    }
    #endif
}

#Preview {
    NavigationStack {
        StudyHistoryView()
    }
}
