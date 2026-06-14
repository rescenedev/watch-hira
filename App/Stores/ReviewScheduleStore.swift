import Foundation

/// 배운 단어 복습 스누즈 일정.
/// 복습 목록에서 스와이프로 미루면 다음 알림 간격이 늘어난다(3일 → 1주 → 1달),
/// 마지막 단계에서 또 미루면 영구히 사라진다.
@MainActor
final class ReviewScheduleStore: ObservableObject {
    static let shared = ReviewScheduleStore()

    private static let storageKey = "reviewSchedule.v1"

    struct Entry: Codable, Equatable {
        var stage: Int       // 1: +3일, 2: +1주, 3: +1달
        var dueDate: Date
    }

    private struct Persisted: Codable, Equatable {
        var entries: [String: Entry] = [:]
        var mastered: [String] = []
    }

    @Published private var state = Persisted()

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(Persisted.self, from: data) {
            state = decoded
        }
    }

    /// 지금 복습 목록에 보여야 하는가(영구 제거 X, 스누즈 만료 O).
    func isDue(_ id: String, now: Date = Date()) -> Bool {
        if state.mastered.contains(id) { return false }
        guard let entry = state.entries[id] else { return true }
        return entry.dueDate <= now
    }

    /// 스와이프로 미루기: 단계 상승. 마지막(1달) 다음이면 영구 제거.
    /// 반환값은 사용자에게 보여줄 안내 문구.
    @discardableResult
    func snooze(_ id: String, now: Date = Date()) -> String {
        let nextStage = (state.entries[id]?.stage ?? 0) + 1
        if nextStage > 3 {
            state.entries[id] = nil
            if !state.mastered.contains(id) { state.mastered.append(id) }
            save()
            return "다 외웠어요! 이제 안 보여드려요"
        }
        let days = Self.intervalDays(for: nextStage)
        state.entries[id] = Entry(
            stage: nextStage,
            dueDate: Calendar.current.date(byAdding: .day, value: days, to: now) ?? now
        )
        save()
        return "\(days)일 뒤에 다시 알려드릴게요"
    }

    private static func intervalDays(for stage: Int) -> Int {
        switch stage {
        case 1: return 3
        case 2: return 7
        default: return 30
        }
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(state) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
