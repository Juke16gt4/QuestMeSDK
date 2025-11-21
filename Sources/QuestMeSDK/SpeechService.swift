//
//  SpeechService.swift
//  QuestMeSDK
//
//  👤 Author: 津村 淳一
//  📅 Created: 2025/10/29
//  🔗 Related Files:
//      - LocalizationManager.swift
//      - QuestMeSDK.swift
//

import Foundation
import Speech

public final class SpeechService {
    private var recognizer: SFSpeechRecognizer?

    public init(languageCode: String) {
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: languageCode))
    }

    public func updateLanguage(_ code: String) {
        self.recognizer = SFSpeechRecognizer(locale: Locale(identifier: code))
    }

    // 音声認識（URLベース）
    public func transcribe(audioURL: URL, completion: @escaping (String?) -> Void) {
        guard let recognizer = recognizer else { completion(nil); return }
        let request = SFSpeechURLRecognitionRequest(url: audioURL)
        recognizer.recognitionTask(with: request) { result, error in
            completion(result?.bestTranscription.formattedString)
        }
    }

    // 音声認証（声紋照合のプレースホルダ）
    public func verifyUserVoice(sampleURL: URL, registeredVoiceprint: Data) -> Bool {
        // 実運用では ML モデル/外部API での声紋比較を実装
        return true
    }
}
