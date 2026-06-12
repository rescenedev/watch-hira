import WidgetKit
import SwiftUI
import KanaCore

/// 매시간 바뀌는 "오늘의 가나" 항목.
struct KanaEntry: TimelineEntry {
    let date: Date
    let kana: Kana
    let exampleWord: KanaWord?
}

struct KanaProvider: TimelineProvider {

    private static let pool =
        KanaData.kana(script: .hiragana, groups: [.basic])
        + KanaData.kana(script: .katakana, groups: [.basic])

    func placeholder(in context: Context) -> KanaEntry {
        makeEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (KanaEntry) -> Void) {
        completion(makeEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<KanaEntry>) -> Void) {
        let calendar = Calendar.current
        let now = Date()
        let hourStart = calendar.dateInterval(of: .hour, for: now)?.start ?? now

        let entries = (0..<24).map { offset in
            makeEntry(date: calendar.date(byAdding: .hour, value: offset, to: hourStart) ?? hourStart)
        }
        completion(Timeline(entries: entries, policy: .atEnd))
    }

    private func makeEntry(date: Date) -> KanaEntry {
        let kana = Self.pool.randomElement()
            ?? Kana(character: "あ", romaji: "a", script: .hiragana, group: .basic)
        return KanaEntry(
            date: date,
            kana: kana,
            exampleWord: KanaWordBank.randomWords(for: kana, count: 1).first
        )
    }
}

/// 워치 페이스 크기별 표시.
struct KanaWidgetView: View {
    let entry: KanaEntry

    @Environment(\.widgetFamily) private var family

    var body: some View {
        Group {
            switch family {
            case .accessoryCircular:
                circularView
            case .accessoryCorner:
                cornerView
            case .accessoryRectangular:
                rectangularView
            default:
                inlineView
            }
        }
        .containerBackground(.clear, for: .widget)
    }

    private var circularView: some View {
        Text(entry.kana.character)
            .font(.system(size: 30, weight: .bold))
            .minimumScaleFactor(0.5)
    }

    private var cornerView: some View {
        Text(entry.kana.character)
            .font(.system(size: 26, weight: .bold))
            .widgetLabel(entry.kana.romaji)
    }

    private var rectangularView: some View {
        HStack(spacing: 10) {
            Text(entry.kana.character)
                .font(.system(size: 50, weight: .heavy))
                .minimumScaleFactor(0.6)

            VStack(alignment: .leading, spacing: 1) {
                Text(entry.kana.romaji)
                    .font(.system(size: 17, weight: .bold))
                    .foregroundStyle(.green)

                if let example = entry.exampleWord {
                    Text("\(example.word) \(example.meaning)")
                        .font(.system(size: 12))
                        .foregroundStyle(.secondary)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                }
            }
            Spacer(minLength: 0)
        }
        .frame(maxHeight: .infinity)
    }

    private var inlineView: some View {
        Text("\(entry.kana.character) \(entry.kana.romaji)")
    }
}

@main
struct KanaWidget: Widget {
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: "KanaWidget", provider: KanaProvider()) { entry in
            KanaWidgetView(entry: entry)
        }
        .configurationDisplayName("오늘의 가나")
        .description("매시간 새로운 가나 한 글자를 보여줍니다.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryCorner,
            .accessoryRectangular,
            .accessoryInline,
        ])
    }
}

#Preview(as: .accessoryRectangular) {
    KanaWidget()
} timeline: {
    KanaEntry(
        date: .now,
        kana: Kana(character: "ぬ", romaji: "nu", script: .hiragana, group: .basic),
        exampleWord: KanaWord(word: "いぬ", meaning: "개")
    )
}
