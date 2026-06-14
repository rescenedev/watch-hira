import Foundation

/// 목록에 보여줄 학습 항목 한 건 (오늘 배운 단어 등).
public struct StudiedItem: Codable, Equatable, Sendable, Identifiable {
    /// 중복 제거용 안정 식별자 (예: "kana:あ", "jlptN3:水").
    public let id: String
    /// 카드 앞면에 보이던 글자/단어.
    public let front: String
    /// 읽기(후리가나). 표기와 같으면 nil.
    public let reading: String?
    /// 뜻(단어) 또는 로마자(가나).
    public let meaning: String

    public init(id: String, front: String, reading: String? = nil, meaning: String) {
        self.id = id
        self.front = front
        self.reading = reading
        self.meaning = meaning
    }
}

public extension Kana {
    /// 가나 한 글자를 학습 기록 항목으로.
    var studiedItem: StudiedItem {
        StudiedItem(id: quizItem.id, front: character, reading: nil, meaning: romaji)
    }
}

public extension VocabWord {
    /// 단어 하나를 학습 기록 항목으로.
    func studiedItem(deck: VocabDeckKind) -> StudiedItem {
        StudiedItem(
            id: quizItem(deck: deck).id,
            front: word,
            reading: hasDistinctReading ? reading : nil,
            meaning: meaning
        )
    }
}

/// 날짜별 학습량 기록과 연속 학습일(streak) 계산, 그리고 그날 본 항목 목록.
public struct StudyLog: Codable, Equatable, Sendable {

    /// "yyyy-MM-dd" → 그날 넘긴 카드 수.
    private var days: [String: Int]

    /// "yyyy-MM-dd" → 그날 본 항목들(중복 제거, 최근 본 것이 앞).
    private var items: [String: [StudiedItem]]

    public init() {
        self.days = [:]
        self.items = [:]
    }

    private enum CodingKeys: String, CodingKey {
        case days
        case items
    }

    /// 기존(항목 없던) 저장본도 깨지지 않게 디코딩한다.
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        days = try container.decodeIfPresent([String: Int].self, forKey: .days) ?? [:]
        items = try container.decodeIfPresent([String: [StudiedItem]].self, forKey: .items) ?? [:]
    }

    public mutating func record(date: Date, count: Int = 1, calendar: Calendar = .current) {
        let key = Self.key(for: date, calendar: calendar)
        days[key, default: 0] += count
    }

    /// 그날 본 항목을 기록한다. 같은 항목은 한 번만 남기되 가장 최근에 본 순서로 앞당긴다.
    public mutating func record(item: StudiedItem, date: Date, calendar: Calendar = .current) {
        let key = Self.key(for: date, calendar: calendar)
        var dayItems = items[key] ?? []
        dayItems.removeAll { $0.id == item.id }
        dayItems.insert(item, at: 0)
        items[key] = dayItems
    }

    public func cardCount(on date: Date, calendar: Calendar = .current) -> Int {
        days[Self.key(for: date, calendar: calendar)] ?? 0
    }

    /// 해당 날짜에 본 항목들(최근 본 것이 앞).
    public func studiedItems(on date: Date, calendar: Calendar = .current) -> [StudiedItem] {
        items[Self.key(for: date, calendar: calendar)] ?? []
    }

    /// 지금까지 본 서로 다른 항목의 총수(같은 단어를 여러 날 봐도 한 번만).
    public func totalStudiedCount() -> Int {
        var ids = Set<String>()
        for dayItems in items.values {
            for item in dayItems {
                ids.insert(item.id)
            }
        }
        return ids.count
    }

    /// 항목이 있는 날들을 최신순으로 (날짜, 그날 본 항목들)로 묶어 돌려준다.
    public func studiedHistory(calendar: Calendar = .current) -> [(day: Date, items: [StudiedItem])] {
        items.compactMap { key, value -> (day: Date, items: [StudiedItem])? in
            guard !value.isEmpty, let day = Self.date(fromKey: key, calendar: calendar) else { return nil }
            return (day, value)
        }
        .sorted { $0.day > $1.day }
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

    private static func date(fromKey key: String, calendar: Calendar) -> Date? {
        let parts = key.split(separator: "-").compactMap { Int($0) }
        guard parts.count == 3 else { return nil }
        var components = DateComponents()
        components.year = parts[0]
        components.month = parts[1]
        components.day = parts[2]
        return calendar.date(from: components)
    }
}
