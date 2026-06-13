import SwiftUI

/// 탭하면 일본어 TTS로 읽어주는 스피커 버튼.
struct SpeakerButton: View {
    let text: String
    var pointSize: CGFloat? = nil

    var body: some View {
        Button {
            SpeechService.shared.speakJapanese(text)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(resolvedFont)
                .foregroundStyle(Theme.slate400)
                .padding(6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("발음 듣기")
    }

    private var resolvedFont: Font {
        if let pointSize {
            return .system(size: pointSize)
        }
        #if os(watchOS)
        return .footnote
        #else
        return .title3
        #endif
    }
}
