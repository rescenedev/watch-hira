import XCTest
@testable import KanaCore

final class StudyLogTests: XCTestCase {

    private let calendar = Calendar(identifier: .gregorian)

    private func date(_ string: String) -> Date {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        formatter.timeZone = .current
        guard let date = formatter.date(from: string) else {
            fatalError("잘못된 날짜: \(string)")
        }
        return date
    }

    func testEmptyLogHasZeroStreak() {
        XCTAssertEqual(StudyLog().streak(asOf: date("2026-06-13"), calendar: calendar), 0)
    }

    func testRecordingTodayGivesStreakOfOne() {
        var log = StudyLog()
        log.record(date: date("2026-06-13"))
        XCTAssertEqual(log.streak(asOf: date("2026-06-13"), calendar: calendar), 1)
    }

    func testConsecutiveDaysAccumulate() {
        var log = StudyLog()
        log.record(date: date("2026-06-11"))
        log.record(date: date("2026-06-12"))
        log.record(date: date("2026-06-13"))
        XCTAssertEqual(log.streak(asOf: date("2026-06-13"), calendar: calendar), 3)
    }

    func testYesterdayStreakStillCountsWhenTodayNotStudiedYet() {
        var log = StudyLog()
        log.record(date: date("2026-06-11"))
        log.record(date: date("2026-06-12"))
        XCTAssertEqual(
            log.streak(asOf: date("2026-06-13"), calendar: calendar), 2,
            "오늘 아직 공부 안 했어도 어제까지의 연속 기록은 유지되어야 합니다"
        )
    }

    func testGapBreaksStreak() {
        var log = StudyLog()
        log.record(date: date("2026-06-10"))
        log.record(date: date("2026-06-13"))
        XCTAssertEqual(log.streak(asOf: date("2026-06-13"), calendar: calendar), 1)
    }

    func testTwoDayGapMeansZeroStreak() {
        var log = StudyLog()
        log.record(date: date("2026-06-10"))
        XCTAssertEqual(log.streak(asOf: date("2026-06-13"), calendar: calendar), 0)
    }

    func testCountAccumulatesPerDay() {
        var log = StudyLog()
        log.record(date: date("2026-06-13"))
        log.record(date: date("2026-06-13"), count: 4)
        XCTAssertEqual(log.cardCount(on: date("2026-06-13"), calendar: calendar), 5)
    }

    func testCodableRoundTrip() throws {
        var log = StudyLog()
        log.record(date: date("2026-06-13"), count: 10)
        let data = try JSONEncoder().encode(log)
        let decoded = try JSONDecoder().decode(StudyLog.self, from: data)
        XCTAssertEqual(decoded, log)
    }
}
