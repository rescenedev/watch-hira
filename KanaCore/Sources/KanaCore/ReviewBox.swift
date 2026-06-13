import Foundation

/// 오답 복습 상자 (라이트너 라이트).
/// 틀리면 복습 카운트가 2 쌓이고, 맞힐 때마다 1씩 줄어 0이 되면 졸업한다.
public struct ReviewBox: Codable, Equatable, Sendable {

    private var counts: [String: Int]

    public init() {
        self.counts = [:]
    }

    /// 복습이 필요한 항목 id 목록 (정렬 고정).
    public var dueIDs: [String] {
        counts.keys.sorted()
    }

    public var dueCount: Int { counts.count }

    public func isDue(id: String) -> Bool {
        counts[id] != nil
    }

    public mutating func recordWrong(id: String) {
        counts[id, default: 0] += 2
    }

    public mutating func recordCorrect(id: String) {
        guard let remaining = counts[id] else { return }
        if remaining <= 1 {
            counts[id] = nil
        } else {
            counts[id] = remaining - 1
        }
    }
}
