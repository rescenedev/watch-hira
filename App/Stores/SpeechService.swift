import AVFoundation

/// 일본어 TTS 발음 서비스. 오프라인 시스템 음성을 사용한다.
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speakJapanese(_ text: String) {
        guard !text.isEmpty else { return }

        #if os(watchOS)
        // watchOS는 세션 활성화가 비동기다. 콜백이 success로 돌아온 뒤
        // 재생해야 내장 스피커/블루투스로 소리가 나간다.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default)
        session.activate(options: []) { [weak self] success, _ in
            guard success else { return }
            DispatchQueue.main.async {
                self?.speakNow(text)
            }
        }
        #else
        // iOS는 동기 활성화. .playback 카테고리로 무음 스위치를 무시한다.
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try? session.setActive(true, options: [])
        speakNow(text)
        #endif
    }

    private func speakNow(_ text: String) {
        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: Self.voiceLanguage(for: text))
        utterance.rate = 0.42
        synthesizer.speak(utterance)
    }

    /// 텍스트에 일본어(가나·한자)가 있으면 일본어 음성, 아니면(라틴 알파벳 등) 영어 음성으로 읽는다.
    /// ja-JP 음성은 영어 단어를 발음하지 못하므로 커스텀 덱 등 영어 항목은 en-US로 읽어야 한다.
    private static func voiceLanguage(for text: String) -> String {
        for scalar in text.unicodeScalars {
            let value = scalar.value
            let isJapanese =
                (0x3040...0x30FF).contains(value) ||   // 히라가나 + 가타카나
                (0x4E00...0x9FFF).contains(value) ||   // 한자(CJK 통합)
                (0xFF66...0xFF9D).contains(value)      // 반각 가타카나
            if isJapanese {
                return "ja-JP"
            }
        }
        return "en-US"
    }
}
