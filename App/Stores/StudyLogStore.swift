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

    func record(count: Int = 1) {
        log.record(date: Date(), count: count)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(log) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
