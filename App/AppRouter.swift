import SwiftUI

/// 알림 딥링크 등 외부 진입에서 네비게이션을 제어하는 라우터.
@MainActor
final class AppRouter: ObservableObject {
    static let shared = AppRouter()

    @Published var path = NavigationPath()

    /// 딥링크로 열 수 있는 화면.
    enum Route: Hashable {
        case studyHistory
    }

    private init() {}

    /// 배운 단어(복습) 화면으로 이동한다. 기존 스택은 비우고 새로 연다.
    func openStudyHistory() {
        path = NavigationPath()
        path.append(Route.studyHistory)
    }
}
