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

            HStack(spacing: 6) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(studyLogStore.streak > 0 ? .orange : Theme.slate400)
                Text(streakMessage)
                    .font(.caption)
                    .foregroundStyle(Theme.slate400)
                Spacer()
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
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

    private var streakMessage: String {
        let streak = studyLogStore.streak
        let today = studyLogStore.todayCount
        if streak == 0 && today == 0 {
            return "오늘 첫 카드를 넘겨보세요"
        }
        return "연속 \(streak)일 · 오늘 \(today)장"
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
