#if os(iOS)
import Foundation
import UserNotifications
import KanaCore

/// 매일 아침 '오늘의 단어' 로컬 알림. 7일치를 서로 다른 단어로 예약하고
/// 앱을 열 때마다 다시 채운다.
@MainActor
final class NotificationService: ObservableObject {
    static let shared = NotificationService()

    private static let enabledKey = "dailyReminderEnabled"
    private static let reminderHour = 9

    @Published private(set) var isEnabled: Bool

    private init() {
        isEnabled = UserDefaults.standard.bool(forKey: Self.enabledKey)
    }

    func setEnabled(_ enabled: Bool) async {
        if enabled {
            let granted = await requestPermission()
            isEnabled = granted
            UserDefaults.standard.set(granted, forKey: Self.enabledKey)
            if granted {
                await scheduleWeek()
            }
        } else {
            isEnabled = false
            UserDefaults.standard.set(false, forKey: Self.enabledKey)
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        }
    }

    /// 앱 실행 시 호출: 켜져 있으면 7일치 알림을 새 단어로 갱신.
    func refreshIfEnabled() async {
        guard isEnabled else { return }
        await scheduleWeek()
    }

    private func requestPermission() async -> Bool {
        do {
            return try await UNUserNotificationCenter.current()
                .requestAuthorization(options: [.alert, .sound, .badge])
        } catch {
            return false
        }
    }

    private func scheduleWeek() async {
        let center = UNUserNotificationCenter.current()
        center.removeAllPendingNotificationRequests()

        let pool = VocabData.words(for: .jlptN3) + VocabData.words(for: .travel)
        let studied = Self.uniqueStudiedItems()
        let calendar = Calendar.current
        let now = Date()

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: now) else { continue }

            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = Self.reminderHour

            guard let fireDate = calendar.date(from: components), fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.sound = .default

            // 발화 시점에 복습할 단어(스누즈 만료 포함)가 있으면 그중 하나를, 없으면 새 단어 한 개.
            let due = studied.filter { ReviewScheduleStore.shared.isDue($0.id, now: fireDate) }

            if let item = due.randomElement() {
                content.title = "복습할 단어"
                content.body = Self.reviewLine(for: item)
                content.userInfo = ["deepLink": "studyHistory"]
            } else if let word = pool.randomElement() {
                content.title = "오늘의 단어"
                content.body = word.hasDistinctReading
                    ? "\(word.word) (\(word.reading)) — \(word.meaning)"
                    : "\(word.word) — \(word.meaning)"
            } else {
                continue
            }

            let trigger = UNCalendarNotificationTrigger(
                dateMatching: calendar.dateComponents([.year, .month, .day, .hour], from: fireDate),
                repeats: false
            )
            let request = UNNotificationRequest(
                identifier: "dailyWord-\(offset)",
                content: content,
                trigger: trigger
            )
            try? await center.add(request)
        }
    }

    /// 지금까지 배운 항목을 중복 없이 모은다.
    private static func uniqueStudiedItems() -> [StudiedItem] {
        var seen = Set<String>()
        return StudyLogStore.shared.history
            .flatMap { $0.items }
            .filter { seen.insert($0.id).inserted }
    }

    /// 복습 알림 본문: "水(みず) 뜻이 기억나요? 눌러서 복습".
    private static func reviewLine(for item: StudiedItem) -> String {
        let head = item.reading.map { "\(item.front)(\($0))" } ?? item.front
        return "\(head) 기억나요? 눌러서 복습하기"
    }
}

/// 알림 탭을 받아 딥링크로 라우팅하는 델리게이트.
final class NotificationDelegate: NSObject, UNUserNotificationCenterDelegate {
    static let shared = NotificationDelegate()

    /// 앱이 떠 있을 때도 배너를 보여준다.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        completionHandler([.banner, .sound])
    }

    /// 알림을 누르면 배운 단어(복습) 화면으로 이동한다.
    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let userInfo = response.notification.request.content.userInfo
        if userInfo["deepLink"] as? String == "studyHistory" {
            Task { @MainActor in AppRouter.shared.openStudyHistory() }
        }
        completionHandler()
    }
}
#endif
