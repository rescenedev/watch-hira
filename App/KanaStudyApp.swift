import SwiftUI
import KanaCore

@main
struct KanaStudyApp: App {
    private let launchRoute = LaunchRoute.parse()

    var body: some Scene {
        WindowGroup {
            NavigationStack {
                rootView
            }
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
        case .quiz(let script):
            QuizView(script: script, pool: KanaData.kana(script: script, groups: [.basic]))
        case .vocab(let kind):
            VocabStudyView(title: kind.title, words: VocabData.words(for: kind))
        case nil:
            MenuView()
        }
    }
}
