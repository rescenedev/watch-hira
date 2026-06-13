import Foundation
import KanaCore

/// 오답 복습 상자의 영속화 래퍼. 퀴즈 오답이 쌓이고, 정답 2번이면 졸업한다.
@MainActor
final class ReviewStore: ObservableObject {
    static let shared = ReviewStore()

    private static let storageKey = "reviewBox"

    @Published private(set) var box: ReviewBox

    private init() {
        if let data = UserDefaults.standard.data(forKey: Self.storageKey),
           let decoded = try? JSONDecoder().decode(ReviewBox.self, from: data) {
            box = decoded
        } else {
            box = ReviewBox()
        }
    }

    var dueCount: Int { box.dueCount }

    var dueItems: [ReviewDisplay] {
        box.dueIDs.compactMap(ItemResolver.resolve)
    }

    func recordWrong(id: String) {
        box.recordWrong(id: id)
        save()
    }

    func recordCorrect(id: String) {
        box.recordCorrect(id: id)
        save()
    }

    private func save() {
        guard let data = try? JSONEncoder().encode(box) else { return }
        UserDefaults.standard.set(data, forKey: Self.storageKey)
    }
}
