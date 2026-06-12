import Foundation
import KanaCore

/// 실행 인자로 시작 화면을 지정하는 자동화 훅.
/// 예: `--screen study --script hiragana`
enum LaunchRoute: Equatable {
    case study(KanaScript)
    case browse(KanaScript)
    case quiz(KanaScript)

    static func parse(
        arguments: [String] = ProcessInfo.processInfo.arguments
    ) -> LaunchRoute? {
        guard let screen = Self.value(of: "--screen", in: arguments) else { return nil }

        let script = Self.value(of: "--script", in: arguments)
            .flatMap(KanaScript.init(rawValue:)) ?? .hiragana

        switch screen {
        case "study": return .study(script)
        case "browse": return .browse(script)
        case "quiz": return .quiz(script)
        default: return nil
        }
    }

    private static func value(of flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag),
              arguments.indices.contains(index + 1) else { return nil }
        return arguments[index + 1]
    }
}
