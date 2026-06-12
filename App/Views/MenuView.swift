import SwiftUI
import KanaCore

/// 루트 메뉴: 문자 체계를 고른다.
struct MenuView: View {
    var body: some View {
        List {
            NavigationLink(value: KanaScript.hiragana) {
                ScriptRow(title: "히라가나", sample: "あいう")
            }
            NavigationLink(value: KanaScript.katakana) {
                ScriptRow(title: "가타카나", sample: "アイウ")
            }
        }
        .navigationTitle("가나 학습")
        .navigationDestination(for: KanaScript.self) { script in
            ScriptHomeView(script: script)
        }
    }
}

private struct ScriptRow: View {
    let title: String
    let sample: String

    var body: some View {
        VStack(alignment: .leading, spacing: 2) {
            Text(title)
                .font(.headline)
            Text(sample)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}
