import SwiftUI
import KanaCore

/// 배운 단어를 날짜별로 정리해 보여준다. 오늘이 맨 위, 그 아래로 지난 날들.
struct StudyHistoryView: View {
    @ObservedObject private var store = StudyLogStore.shared
    @ObservedObject private var reviewSchedule = ReviewScheduleStore.shared
    @State private var toast: String?
    @State private var showArchive = false

    /// 스누즈로 미뤄둔(아직 안 떠야 하는) 단어를 뺀 복습 목록.
    private var history: [(day: Date, items: [StudiedItem])] {
        store.history.compactMap { day, items in
            let visible = items.filter { reviewSchedule.isDue($0.id) }
            return visible.isEmpty ? nil : (day, visible)
        }
    }

    /// 보관함: 지금 복습 목록에 없는(스누즈 중 D-N, 또는 다 외운 완료) 단어(중복 제거).
    private var archivedEntries: [ArchivedEntry] {
        var seen = Set<String>()
        return store.history
            .flatMap { $0.items }
            .filter { !reviewSchedule.isDue($0.id) && seen.insert($0.id).inserted }
            .map { item in
                let badge: String
                if reviewSchedule.isMastered(item.id) {
                    badge = "완료"
                } else if let days = reviewSchedule.daysUntilDue(item.id) {
                    badge = "D-\(days)"
                } else {
                    badge = ""
                }
                return ArchivedEntry(item: item, badge: badge)
            }
    }

    var body: some View {
        Group {
            if history.isEmpty && archivedEntries.isEmpty {
                emptyState
            } else {
                List {
                    ForEach(history, id: \.day) { day, items in
                        Section {
                            ForEach(items) { item in
                                StudyHistoryRow(item: item)
                                    .slateRow()
                                    .noSeparatorOnIOS()
                                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                        Button {
                                            withAnimation { toast = reviewSchedule.snooze(item.id) }
                                            dismissToastSoon()
                                        } label: {
                                            Label("외웠어요", systemImage: "checkmark.circle.fill")
                                        }
                                        .tint(Theme.mint)
                                    }
                            }
                        } header: {
                            Text(Self.sectionTitle(for: day, count: items.count))
                                .foregroundStyle(Theme.slate300)
                        }
                    }

                    #if os(watchOS)
                    // 워치는 칸이 좁아 보관함을 줄(행)로 보여준다.
                    if !archivedEntries.isEmpty {
                        Section {
                            Button {
                                showArchive = true
                            } label: {
                                HStack(spacing: 8) {
                                    Image(systemName: "archivebox.fill")
                                    Text("보관함")
                                    Text("\(archivedEntries.count)")
                                        .foregroundStyle(Theme.slate400)
                                    Spacer()
                                }
                                .font(.subheadline)
                                .foregroundStyle(Theme.slate300)
                            }
                            .buttonStyle(.plain)
                        }
                    }
                    #endif
                }
                .spacedListOnIOS()
            }
        }
        .slateScreen()
        .navigationTitle("배운 단어")
        .overlay(alignment: .bottom) { toastView }
        #if os(iOS)
        .safeAreaInset(edge: .bottom) { archiveBar }
        #endif
        .sheet(isPresented: $showArchive) {
            ArchiveSheet(entries: archivedEntries)
        }
    }

    #if os(iOS)
    /// 화면 제일 하단 가운데에 떠 있는 작은 보관함 박스. 누르면 보관함 시트가 열린다.
    @ViewBuilder
    private var archiveBar: some View {
        if !archivedEntries.isEmpty {
            Button {
                showArchive = true
            } label: {
                HStack(spacing: 7) {
                    Image(systemName: "archivebox.fill")
                    Text("보관함 \(archivedEntries.count)")
                }
                .font(.body.weight(.medium))
                .foregroundStyle(Theme.slate300)
                .padding(.horizontal, 26)
                .padding(.vertical, 15)
                .background(Theme.rowGradient, in: RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
            .frame(maxWidth: .infinity)
            .padding(.bottom, 8)
        }
    }
    #endif

    @ViewBuilder
    private var toastView: some View {
        if let toast {
            Text(toast)
                .font(.caption)
                .foregroundStyle(Theme.slate300)
                .padding(.horizontal, 14)
                .padding(.vertical, 8)
                .background(Theme.slate800, in: Capsule())
                .padding(.bottom, 24)
                .transition(.move(edge: .bottom).combined(with: .opacity))
        }
    }

    private func dismissToastSoon() {
        Task {
            try? await Task.sleep(nanoseconds: 2_200_000_000)
            withAnimation { toast = nil }
        }
    }

    private var emptyState: some View {
        Text("복습할 단어가 없어요\n카드를 넘기면 여기에 모여요")
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
        if let kanaWord {
            VStack(alignment: .center, spacing: 1) {
                Text(kanaWord.word)
                    .font(.body)
                    .foregroundStyle(Theme.slate300)
                    .lineLimit(1)
                    .minimumScaleFactor(0.7)
                Text(kanaWord.meaning)
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
        return kanaWord?.word
        #else
        return nil
        #endif
    }

    /// 가나의 예시 단어(저장된 것 우선, 없으면 다시 계산).
    private var kanaWord: (word: String, meaning: String)? {
        if let example = item.example, let word = example.word {
            return (word, example.wordMeaning ?? "")
        }
        guard item.id.hasPrefix("kana:"),
              let word = KanaWordBank.words(forCharacter: item.front).first else { return nil }
        return (word.word, word.meaning)
    }

    #if os(iOS)
    /// 본 그대로 저장된 예문 우선, 없으면(옛 기록) 다시 계산.
    private var example: ExampleSentence? {
        if let example = item.example {
            return ExampleSentence(japanese: example.japanese, korean: example.korean)
        }
        if let kanaWord {
            return ExampleSentenceBank.sentence(forWord: kanaWord.word)
        }
        return ExampleSentenceBank.sentence(forWord: item.front)
    }
    #endif
}

/// 보관함 항목: 단어 + 배지(D-N 또는 완료).
private struct ArchivedEntry: Identifiable {
    let item: StudiedItem
    let badge: String
    var id: String { item.id }
}

/// 보관함 시트: 스누즈 중(D-N)이거나 다 외운(완료) 단어 목록.
private struct ArchiveSheet: View {
    let entries: [ArchivedEntry]
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            List {
                ForEach(entries) { entry in
                    ArchiveRow(entry: entry)
                        .slateRow()
                        .noSeparatorOnIOS()
                }
            }
            .spacedListOnIOS()
            .slateScreen()
            .navigationTitle("보관함")
            #if os(iOS)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("닫기") { dismiss() }
                }
            }
            #endif
        }
    }
}

/// 보관함 행: 작게 한 줄 + 오른쪽에 D-N / 완료 배지.
/// 가나(한 글자)는 그 글자가 든 예시 단어로 보여준다.
private struct ArchiveRow: View {
    let entry: ArchivedEntry

    var body: some View {
        HStack(alignment: .center, spacing: 12) {
            #if os(iOS)
            // iOS: 글자 + 초록 보조 / 예문 가운데
            VStack(alignment: .leading, spacing: 1) {
                Text(entry.item.front)
                    .font(.headline)
                if let secondary = secondaryText {
                    Text(secondary)
                        .font(.caption)
                        .foregroundStyle(Theme.mint)
                        .lineLimit(1)
                }
            }
            .frame(width: 72, alignment: .leading)

            if let sentence = exampleSentence {
                VStack(alignment: .leading, spacing: 2) {
                    Text(sentence.japanese)
                        .font(.subheadline)
                        .foregroundStyle(Theme.slate300)
                        .lineLimit(2)
                    if let korean = sentence.korean {
                        Text(korean)
                            .font(.caption)
                            .foregroundStyle(Theme.slate400)
                            .lineLimit(2)
                    }
                }
                .frame(maxWidth: .infinity, alignment: .leading)
            } else {
                Spacer(minLength: 0)
            }
            #else
            // 워치: 학습(배운 단어) 행과 동일 — 글자+읽기/뜻, 가운데 가나 예시단어. 예문 없음.
            VStack(alignment: .leading, spacing: 1) {
                HStack(alignment: .firstTextBaseline, spacing: 4) {
                    Text(entry.item.front)
                        .font(.headline)
                    if let reading = entry.item.reading {
                        Text(reading)
                            .font(.caption2)
                            .foregroundStyle(Theme.mint)
                            .lineLimit(1)
                    }
                }
                Text(entry.item.meaning)
                    .font(.caption2)
                    .foregroundStyle(Theme.slate400)
                    .lineLimit(1)
            }
            if let kanaWord {
                VStack(alignment: .center, spacing: 1) {
                    Text(kanaWord.word)
                        .font(.body)
                        .foregroundStyle(Theme.slate300)
                        .lineLimit(1)
                        .minimumScaleFactor(0.7)
                    Text(kanaWord.meaning)
                        .font(.caption2)
                        .foregroundStyle(Theme.slate400)
                        .lineLimit(1)
                }
                .frame(maxWidth: .infinity, alignment: .center)
            } else {
                Spacer(minLength: 0)
            }
            #endif

            // 배지 (완료 / D-N)
            if !entry.badge.isEmpty {
                Text(entry.badge)
                    .font(.caption2.weight(.semibold))
                    .foregroundStyle(entry.badge == "완료" ? Theme.mint : Theme.slate300)
                    .padding(.horizontal, 7)
                    .padding(.vertical, 3)
                    .background(Theme.slate800, in: Capsule())
            }
        }
        .padding(.vertical, 2)
    }

    #if os(iOS)
    /// 글자 옆 초록 보조: 단어는 읽기, 가나는 예시 단어(저장된 것 우선). (iOS 전용)
    private var secondaryText: String? {
        if let reading = entry.item.reading { return reading }
        if let example = entry.item.example, let word = example.word { return word }
        if entry.item.id.hasPrefix("kana:") {
            return KanaWordBank.words(forCharacter: entry.item.front).first?.word
        }
        return nil
    }
    #endif

    #if os(watchOS)
    /// 가나의 예시 단어(저장된 것 우선). (워치 전용)
    private var kanaWord: (word: String, meaning: String)? {
        if let example = entry.item.example, let word = example.word {
            return (word, example.wordMeaning ?? "")
        }
        guard entry.item.id.hasPrefix("kana:"),
              let word = KanaWordBank.words(forCharacter: entry.item.front).first else { return nil }
        return (word.word, word.meaning)
    }
    #endif

    #if os(iOS)
    /// 저장된 예문 우선, 없으면(옛 기록) 다시 계산. (iOS 전용)
    private var exampleSentence: (japanese: String, korean: String?)? {
        let item = entry.item
        if let example = item.example {
            return (example.japanese, example.korean)
        }
        if item.id.hasPrefix("kana:"), let word = KanaWordBank.words(forCharacter: item.front).first {
            let sentence = ExampleSentenceBank.sentence(forWord: word.word)
            return (sentence.japanese, sentence.korean)
        }
        let sentence = ExampleSentenceBank.sentence(forWord: item.front)
        return (sentence.japanese, sentence.korean)
    }
    #endif
}

#Preview {
    NavigationStack {
        StudyHistoryView()
    }
}
