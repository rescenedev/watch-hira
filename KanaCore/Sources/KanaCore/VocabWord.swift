import Foundation

/// 단어집의 단어 하나: 표기, 읽기(후리가나), 한국어 뜻.
public struct VocabWord: Hashable, Identifiable, Sendable, Codable {
    public let word: String
    public let reading: String
    public let meaning: String

    public var id: String { word }

    /// 표기와 읽기가 같으면(가타카나 외래어 등) 읽기를 따로 보여줄 필요가 없다.
    public var hasDistinctReading: Bool { word != reading }

    public init(word: String, reading: String, meaning: String) {
        self.word = word
        self.reading = reading
        self.meaning = meaning
    }
}

/// 단어집 종류.
public enum VocabDeckKind: String, CaseIterable, Codable, Sendable, Hashable {
    case jlptN3
    case travel
    case jlptN5
    case jlptN4

    public var title: String {
        switch self {
        case .jlptN3: return "JLPT N3"
        case .travel: return "여행"
        case .jlptN5: return "JLPT N5"
        case .jlptN4: return "JLPT N4"
        }
    }

    public var subtitle: String {
        switch self {
        case .jlptN3: return "시험 대비 핵심 단어"
        case .travel: return "여행에서 바로 쓰는 단어"
        case .jlptN5: return "입문 필수 단어"
        case .jlptN4: return "초급 핵심 단어"
        }
    }
}

/// 단어집 데이터 소스.
public enum VocabData {
    public static func words(for kind: VocabDeckKind) -> [VocabWord] {
        switch kind {
        case .jlptN3: return jlptN3Words
        case .travel: return travelWords
        case .jlptN5: return jlptN5Words
        case .jlptN4: return jlptN4Words
        }
    }
}
