import Foundation
import KanaCore

/// 학습량·연속 학습일 기록의 영속화 래퍼.
@MainActor
final class StudyLogStore: ObservableObject {
    static let shared = StudyLogStore()

    private static let storageKey = "studyLog"

    @Published private(set) var log: StudyLog

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(StudyLog.self, from: data) {
            log = decoded
        } else {
            log = StudyLog()
        }
    }

    var streak: Int { log.streak(asOf: Date()) }
    var todayCount: Int { log.cardCount(on: Date()) }

    /// 오늘 본 항목들(최근 본 것이 앞).
    var todayItems: [StudiedItem] { log.studiedItems(on: Date()) }

    /// 항목이 있는 날들을 최신순으로 묶은 학습 기록.
    var history: [(day: Date, items: [StudiedItem])] { log.studiedHistory() }

    /// 지금까지 본 서로 다른 단어의 총수.
    var totalLearnedCount: Int { log.totalStudiedCount() }

    /// 특정 날짜에 본 항목들.
    func studiedItems(on date: Date) -> [StudiedItem] { log.studiedItems(on: date) }

    func record(count: Int = 1) {
        log.record(date: Date(), count: count)
        save()
    }

    /// 오늘 본 항목을 기록한다.
    func record(item: StudiedItem) {
        log.record(item: item, date: Date())
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(log) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
