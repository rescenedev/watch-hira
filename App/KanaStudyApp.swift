import SwiftUI
import KanaCore
#if os(iOS)
import UserNotifications
#endif

@main
struct KanaStudyApp: App {
    private let launchRoute = LaunchRoute.parse()
    @ObservedObject private var router = AppRouter.shared

    var body: some Scene {
        WindowGroup {
            NavigationStack(path: $router.path) {
                rootView
                    .navigationDestination(for: AppRouter.Route.self) { route in
                        switch route {
                        case .studyHistory: StudyHistoryView()
                        }
                    }
            }
            #if os(iOS)
            .task {
                UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
                await NotificationService.shared.refreshIfEnabled()
            }
            #endif
        }
    }

    @ViewBuilder
    private var rootView: some View {
        switch launchRoute {
        case .study(let script):
            StudyView(
                title: script == .hiragana ? "히라가나" : "가타카나",
                kanaList: KanaData.kana(script: script, groups: [.basic])
            )
        case .browse(let script):
            BrowseView(
                title: script == .hiragana ? "히라가나" : "가타카나",
                kanaList: KanaData.kana(script: script, groups: [.basic])
            )
        case .quiz(let script, let reveal):
            QuizView(
                title: "퀴즈",
                items: KanaData.kana(script: script, groups: [.basic]).map(\.quizItem),
                scoreKey: "bestScore.\(script.rawValue)",
                revealDemo: reveal
            )
        case .vocab(let kind):
            VocabStudyView(title: kind.title, words: VocabData.words(for: kind), deckKind: kind)
        case nil:
            MenuView()
        }
    }
}
