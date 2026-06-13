import Foundation

/// 날짜별 학습량 기록과 연속 학습일(streak) 계산.
public struct StudyLog: Codable, Equatable, Sendable {

    /// "yyyy-MM-dd" → 그날 본 카드 수.
    private var days: [String: Int]

    public init() {
        self.days = [:]
    }

    public mutating func record(date: Date, count: Int = 1, calendar: Calendar = .current) {
        let key = Self.key(for: date, calendar: calendar)
        days[key, default: 0] += count
    }

    public func cardCount(on date: Date, calendar: Calendar = .current) -> Int {
        days[Self.key(for: date, calendar: calendar)] ?? 0
    }

    /// 기준일까지의 연속 학습일.
    /// 기준일에 아직 학습하지 않았다면 어제까지 이어진 연속 기록을 반환한다.
    public func streak(asOf date: Date, calendar: Calendar = .current) -> Int {
        var cursor = calendar.startOfDay(for: date)

        // 오늘 학습 기록이 없으면 어제부터 센다.
        if days[Self.key(for: cursor, calendar: calendar)] == nil {
            guard let yesterday = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                return 0
            }
            cursor = yesterday
        }

        var streak = 0
        while days[Self.key(for: cursor, calendar: calendar)] != nil {
            streak += 1
            guard let previous = calendar.date(byAdding: .day, value: -1, to: cursor) else {
                break
            }
            cursor = previous
        }
        return streak
    }

    private static func key(for date: Date, calendar: Calendar) -> String {
        let parts = calendar.dateComponents([.year, .month, .day], from: date)
        return String(format: "%04d-%02d-%02d", parts.year ?? 0, parts.month ?? 0, parts.day ?? 0)
    }
}
