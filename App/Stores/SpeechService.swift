import AVFoundation

/// 일본어 TTS 발음 서비스. 오프라인 시스템 음성을 사용한다.
/// watchOS에서는 재생 전에 오디오 세션을 활성화해야 소리가 난다.
final class SpeechService {
    static let shared = SpeechService()

    private let synthesizer = AVSpeechSynthesizer()

    private init() {}

    func speakJapanese(_ text: String) {
        guard !text.isEmpty else { return }

        activateAudioSession()

        if synthesizer.isSpeaking {
            synthesizer.stopSpeaking(at: .immediate)
        }
        let utterance = AVSpeechUtterance(string: text)
        utterance.voice = AVSpeechSynthesisVoice(language: "ja-JP")
        utterance.rate = 0.42
        synthesizer.speak(utterance)
    }

    /// iOS·watchOS 모두 재생 전에 오디오 세션을 활성화한다.
    /// `.playback` 카테고리는 무음 스위치를 무시하고 소리를 낸다.
    private func activateAudioSession() {
        #if os(iOS) || os(watchOS)
        let session = AVAudioSession.sharedInstance()
        try? session.setCategory(.playback, mode: .default, options: [.duckOthers])
        try? session.setActive(true, options: [])
        #endif
    }
}
