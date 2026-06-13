import SwiftUI

/// 탭하면 일본어 TTS로 읽어주는 스피커 버튼.
struct SpeakerButton: View {
    let text: String

    var body: some View {
        Button {
            SpeechService.shared.speakJapanese(text)
        } label: {
            Image(systemName: "speaker.wave.2.fill")
                .font(speakerFont)
                .foregroundStyle(Theme.slate400)
                .padding(6)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("발음 듣기")
    }

    private var speakerFont: Font {
        #if os(watchOS)
        .footnote
        #else
        .title3
        #endif
    }
}
