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
    @State private var expanded = false

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            glyphColumn
            middle
            SpeakerButton(text: item.reading ?? item.front)
        }
        .padding(.vertical, 2)
    }

    /// 글자 컬럼. iOS는 글자 + 그 아래 초록 보조 표기(한글 뜻 없음),
    /// 워치는 글자(+읽기) + 뜻.
    private var glyphColumn: some View {
        #if os(iOS)
        VStack(alignment: .leading, spacing: 1) {
            Text(item.front)
                .font(.headline)
            if let secondary = secondaryText {
                Text(secondary)
                    .font(.caption)
                    .foregroundStyle(Theme.mint)
                    .lineLimit(1)
            }
        }
        .frame(width: 72, alignment: .leading)
        #else
        VStack(alignment: .leading, spacing: 1) {
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(item.front)
                    .font(.headline)
                if let reading = item.reading {
                    Text(reading)
                        .font(.caption2)
                        .foregroundStyle(Theme.mint)
                        .lineLimit(1)
                }
            }
            Text(item.meaning)
                .font(.caption2)
                .foregroundStyle(Theme.slate400)
                .lineLimit(1)
        }
        #endif
    }

    /// 글자와 소리 사이. iOS는 예문(한 줄, 누르면 펼침), 워치는 가나의 예시 단어.
    @ViewBuilder
    private var middle: some View {
        #if os(iOS)
        if let example {
            VStack(alignment: .leading, spacing: 2) {
                Text(example.japanese)
                    .font(.subheadline)
                    .foregroundStyle(Theme.slate300)
                    .lineLimit(expanded ? nil : 1)
                    .truncationMode(.tail)
                if let korean = example.korean {
                    Text(korean)
                        .font(.caption)
                        .foregroundStyle(Theme.slate400)
                        .lineLimit(expanded ? nil : 1)
                        .truncationMode(.tail)
                }
            }
            .frame(maxWidth: .infinity, alignment: .leading)
            .contentShape(Rectangle())
            .onTapGesture { withAnimation(.easeInOut(duration: 0.15)) { expanded.toggle() } }
        } else {
            Spacer(minLength: 0)
        }
        #else
        if let kanaExample {
            VStack(alignment: .center, spacing: 1) {
                Text(kanaExample.word)
                    .font(.body)
                    .foregroundStyle(Theme.slate300)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(kanaExample.meaning)
                    .font(.caption2)
                    .foregroundStyle(Theme.slate400)
                    .lineLimit(1)
            }
            .frame(maxWidth: .infinity, alignment: .center)
        } else {
            Spacer(minLength: 0)
        }
        #endif
    }

    /// 글자 옆 보조 표기: 단어는 읽기, 가나는(iOS) 예시 단어.
    private var secondaryText: String? {
        if let reading = item.reading { return reading }
        #if os(iOS)
        return kanaExample?.word
        #else
        return nil
        #endif
    }

    /// 가나(한 글자)의 대표 예시 단어.
    private var kanaExample: KanaWord? {
        guard item.id.hasPrefix("kana:") else { return nil }
        return KanaWordBank.words(forCharacter: item.front).first
    }

    #if os(iOS)
    /// 단어에는 짧은 예문을, 가나에는 그 예시 단어로 만든 문장을 보여준다.
    private var example: ExampleSentence? {
        if let kanaExample {
            return ExampleSentenceBank.sentence(forWord: kanaExample.word)
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
