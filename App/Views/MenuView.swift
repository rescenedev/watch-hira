import SwiftUI
import KanaCore

/// 루트 메뉴: 문자 체계와 단어집, 복습을 고른다.
struct MenuView: View {
    @ObservedObject private var reviewStore = ReviewStore.shared
    @ObservedObject private var favoritesStore = FavoritesStore.shared
    @ObservedObject private var studyLogStore = StudyLogStore.shared
    #if os(iOS)
    @ObservedObject private var customDeckStore = CustomDeckStore.shared
    #endif

    var body: some View {
        List {
            #if os(iOS)
            StudyProgressHeader(
                streak: studyLogStore.streak,
                today: studyLogStore.todayItems.count,
                total: studyLogStore.totalLearnedCount
            )
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            #endif

            NavigationLink {
                StudyHistoryView()
            } label: {
                ScriptRow(
                    title: "오늘 배운 단어",
                    sample: todayItemsSample
                )
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()

            NavigationLink(value: KanaScript.hiragana) {
                ScriptRow(title: "히라가나", sample: "あいう")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            NavigationLink(value: KanaScript.katakana) {
                ScriptRow(title: "가타카나", sample: "アイウ")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            NavigationLink(value: VocabDeckKind.jlptN3) {
                ScriptRow(title: "JLPT N3", sample: "시험 대비 핵심 단어")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            NavigationLink(value: VocabDeckKind.travel) {
                ScriptRow(title: "여행", sample: "여행에서 바로 쓰는 단어")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            NavigationLink(value: VocabDeckKind.jlptN5) {
                ScriptRow(title: "JLPT N5", sample: "입문 필수 단어")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            NavigationLink(value: VocabDeckKind.jlptN4) {
                ScriptRow(title: "JLPT N4", sample: "초급 핵심 단어")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()

            if reviewStore.dueCount > 0 {
                NavigationLink {
                    ReviewSessionView()
                } label: {
                    ScriptRow(
                        title: "복습",
                        sample: "틀린 항목 \(reviewStore.dueCount)개"
                    )
                }
                .slateRowOnIOS()
                .noSeparatorOnIOS()
            }

            if favoritesStore.count > 0 {
                NavigationLink {
                    FavoritesView()
                } label: {
                    ScriptRow(
                        title: "즐겨찾기",
                        sample: "별표한 항목 \(favoritesStore.count)개"
                    )
                }
                .slateRowOnIOS()
                .noSeparatorOnIOS()
            }

            #if os(iOS)
            ForEach(customDeckStore.decks) { deck in
                NavigationLink {
                    CustomDeckHomeView(deck: deck)
                } label: {
                    ScriptRow(title: deck.name, sample: "내 덱 · \(deck.words.count)단어")
                }
                .slateRowOnIOS()
                .noSeparatorOnIOS()
            }

            NavigationLink {
                AnkiImportView()
            } label: {
                ScriptRow(title: "Anki 가져오기", sample: ".apkg 덱을 내 덱으로")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()

            DailyReminderToggle()
                .slateRowOnIOS()
                .noSeparatorOnIOS()
            #endif
        }
        .spacedListOnIOS()
        .slateScreenOnIOS()
        .navigationTitle("일본어공부")
        .navigationDestination(for: KanaScript.self) { script in
            ScriptHomeView(script: script)
        }
        .navigationDestination(for: VocabDeckKind.self) { kind in
            VocabHomeView(kind: kind)
        }
    }

    private var todayItemsSample: String {
        let today = studyLogStore.todayItems.count
        if today > 0 {
            return "오늘 \(today)개 · 날짜별로 정리"
        }
        return studyLogStore.history.isEmpty
            ? "아직 없어요 · 카드를 넘겨보세요"
            : "날짜별로 정리"
    }

}

/// 진도 요약: 연속 학습일·오늘 본 단어·누적 학습 단어를 한눈에.
private struct StudyProgressHeader: View {
    let streak: Int
    let today: Int
    let total: Int

    var body: some View {
        HStack(spacing: 0) {
            stat(value: "\(streak)일", label: "연속", systemImage: "flame.fill", tint: streak > 0 ? .orange : Theme.slate400)
            divider
            stat(value: "\(today)개", label: "오늘", systemImage: "book.fill", tint: Theme.mint)
            divider
            stat(value: "\(total)개", label: "누적", systemImage: "checkmark.seal.fill", tint: Theme.slate300)
        }
        .padding(.vertical, 6)
    }

    private func stat(value: String, label: String, systemImage: String, tint: Color) -> some View {
        VStack(spacing: 3) {
            Image(systemName: systemImage)
                .font(.subheadline)
                .foregroundStyle(tint)
            Text(value)
                .font(.headline)
                .monospacedDigit()
            Text(label)
                .font(.caption2)
                .foregroundStyle(Theme.slate400)
        }
        .frame(maxWidth: .infinity)
    }

    private var divider: some View {
        Rectangle()
            .fill(Theme.slate700.opacity(0.6))
            .frame(width: 1, height: 28)
    }
}

#if os(iOS)
/// 매일 아침 9시 '오늘의 단어' 알림 토글.
private struct DailyReminderToggle: View {
    @ObservedObject private var service = NotificationService.shared
    @State private var isOn = false

    var body: some View {
        Toggle("매일 9시 단어 알림", isOn: $isOn)
            .onAppear { isOn = service.isEnabled }
            .onChange(of: isOn) { _, newValue in
                guard newValue != service.isEnabled else { return }
                Task {
                    await service.setEnabled(newValue)
                    isOn = service.isEnabled
                }
            }
    }
}
#endif

private struct ScriptRow: View {
    let title: String
    let sample: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
            Text(sample)
                .font(.caption)
                .foregroundStyle(Theme.slate400)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}
