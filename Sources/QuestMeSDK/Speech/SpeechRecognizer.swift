//
//  SpeechRecognizer.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Speech/SpeechRecognizer.swift
//
//  🎯 目的:
//      - 音声認識の初期化・開始・停止・結果取得を管理
//      - 言語コードに基づくローカライズ対応
//
//  🔗 関連/連動ファイル:
//      - SpeechRecognitionManager.swift
//      - SpeechAuthorizationService.swift
//      - QuestMeSDK/Localization/LanguageCode.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月31日
//

import Foundation
import Speech

public final class SpeechRecognizer {
    private let recognizer: SFSpeechRecognizer
    private var recognitionTask: SFSpeechRecognitionTask?
    private let audioEngine = AVAudioEngine()

    public init(code languageCode: String) throws {
        guard let recognizer = SFSpeechRecognizer(locale: Locale(identifier: languageCode)) else {
            throw NSError(domain: "SpeechRecognizer", code: -1, userInfo: [NSLocalizedDescriptionKey: "Unsupported language code: \(languageCode)"])
        }
        self.recognizer = recognizer
    }

    public func startRecognition(resultHandler: @escaping (String) -> Void) throws {
        let request = SFSpeechAudioBufferRecognitionRequest()
        let inputNode = audioEngine.inputNode

        request.shouldReportPartialResults = true

        recognitionTask = recognizer.recognitionTask(with: request) { result, error in
            if let result = result {
                resultHandler(result.bestTranscription.formattedString)
            } else if let error = error {
                print("❌ Recognition error: \(error.localizedDescription)")
            }
        }

        let recordingFormat = inputNode.outputFormat(forBus: 0)
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: recordingFormat) { buffer, _ in
            request.append(buffer)
        }

        audioEngine.prepare()
        try audioEngine.start()
    }

    public func stopRecognition() {
        audioEngine.stop()
        audioEngine.inputNode.removeTap(onBus: 0)
        recognitionTask?.cancel()
        recognitionTask = nil
    }
}
