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
        let calendar = Calendar.current
        let now = Date()

        for offset in 0..<7 {
            guard let day = calendar.date(byAdding: .day, value: offset, to: now),
                  let word = pool.randomElement() else { continue }

            var components = calendar.dateComponents([.year, .month, .day], from: day)
            components.hour = Self.reminderHour

            guard let fireDate = calendar.date(from: components), fireDate > now else { continue }

            let content = UNMutableNotificationContent()
            content.title = "오늘의 단어"
            content.body = word.hasDistinctReading
                ? "\(word.word) (\(word.reading)) — \(word.meaning)"
                : "\(word.word) — \(word.meaning)"
            content.sound = .default

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
}
#endif
