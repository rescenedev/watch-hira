import SwiftUI

/// slate 팔레트 기반 앱 테마.
enum Theme {
    static let slate950 = Color(red: 0.008, green: 0.024, blue: 0.090)
    static let slate900 = Color(red: 0.059, green: 0.090, blue: 0.165)
    static let slate800 = Color(red: 0.118, green: 0.161, blue: 0.231)
    static let slate700 = Color(red: 0.200, green: 0.255, blue: 0.333)
    static let slate400 = Color(red: 0.580, green: 0.639, blue: 0.722)
    static let slate300 = Color(red: 0.796, green: 0.835, blue: 0.882)
    static let mint = Color(red: 0.42, green: 0.92, blue: 0.60)

    static var backgroundGradient: LinearGradient {
        LinearGradient(
            colors: [slate950, slate900, slate800],
            startPoint: .top,
            endPoint: .bottom
        )
    }

    static var rowGradient: LinearGradient {
        LinearGradient(
            colors: [slate800, slate700.opacity(0.85)],
            startPoint: .topLeading,
            endPoint: .bottomTrailing
        )
    }
}

extension View {
    /// 화면 전체에 slate 그라데이션 배경을 깐다.
    func slateScreen() -> some View {
        #if os(iOS)
        return scrollContentBackground(.hidden)
            .background(Theme.backgroundGradient.ignoresSafeArea())
            .preferredColorScheme(.dark)
        #else
        return background(Theme.backgroundGradient.ignoresSafeArea())
        #endif
    }

    /// 리스트 행에 slate 카드 배경을 깐다.
    func slateRow() -> some View {
        listRowBackground(
            Theme.rowGradient
                .clipShape(RoundedRectangle(cornerRadius: 12))
        )
    }

    /// iOS에서만 slate 배경을 깐다 (watchOS는 시스템 기본 유지).
    @ViewBuilder
    func slateScreenOnIOS() -> some View {
        #if os(iOS)
        slateScreen()
        #else
        self
        #endif
    }
}
