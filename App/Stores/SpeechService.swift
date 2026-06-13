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
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.42
        synthesizer.speak(utterance)
    }
}
