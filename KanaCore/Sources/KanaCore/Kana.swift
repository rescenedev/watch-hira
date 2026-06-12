import Foundation

/// 가나 문자 체계 종류.
public enum KanaScript: String, CaseIterable, Codable, Sendable {
    case hiragana
    case katakana
}

/// 발음 그룹: 청음(기본 46자), 탁음, 반탁음.
public enum KanaGroup: String, CaseIterable, Codable, Sendable {
    case basic
    case dakuon
    case handakuon
}

/// 가나 한 글자와 로마자 표기.
public struct Kana: Hashable, Identifiable, Sendable {
    public let character: String
    public let romaji: String
    public let script: KanaScript
    public let group: KanaGroup

    public var id: String { character }

    public init(character: String, romaji: String, script: KanaScript, group: KanaGroup) {
        self.character = character
        self.romaji = romaji
        self.script = script
        self.group = group
    }
}
