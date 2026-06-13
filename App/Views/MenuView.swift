import SwiftUI
import KanaCore

/// 루트 메뉴: 문자 체계를 고른다.
struct MenuView: View {
    var body: some View {
        List {
            NavigationLink(value: KanaScript.hiragana) {
                ScriptRow(title: "히라가나", sample: "あいう")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            NavigationLink(value: KanaScript.katakana) {
                ScriptRow(title: "가타카나", sample: "アイウ")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            NavigationLink(value: VocabDeckKind.jlptN3) {
                ScriptRow(title: "JLPT N3", sample: "시험 대비 핵심 단어")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
            NavigationLink(value: VocabDeckKind.travel) {
                ScriptRow(title: "여행", sample: "여행에서 바로 쓰는 단어")
            }
            .slateRowOnIOS()
            .noSeparatorOnIOS()
        }
        .spacedListOnIOS()
        .slateScreenOnIOS()
        .navigationTitle("가나 학습")
        .navigationDestination(for: KanaScript.self) { script in
            ScriptHomeView(script: script)
        }
        .navigationDestination(for: VocabDeckKind.self) { kind in
            VocabHomeView(kind: kind)
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
                .foregroundStyle(Theme.slate400)
        }
        .padding(.vertical, 4)
    }
}

#Preview {
    NavigationStack {
        MenuView()
    }
}
