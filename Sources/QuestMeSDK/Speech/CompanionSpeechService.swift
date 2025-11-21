//
//  CompanionSpeechService.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Speech/CompanionSpeechService.swift
//
//  🎯 目的:
//      - 音声認識の起動・停止・結果取得
//      - AppLanguageManager に基づく言語設定（MainActor隔離）
//
//  🔗 関連/連動ファイル:
//      - AppLanguageManager.swift
//      - SpeechRecognizer.swift
//
//  👤 作成者: 津村 淳一
//  📅 修正日: 2025年10月31日
//

import Foundation
import UIKit

@MainActor
final class CompanionSpeechService: NSObject {
    private var recognizer: SpeechRecognizer?

    public func start() {
        let code = AppLanguageManager.shared.languageCode
        do {
            recognizer = try SpeechRecognizer(code: code)
            try recognizer?.startRecognition { result in
                print("🗣️ 認識結果: \(result)")
            }
        } catch {
            print("❌ 音声認識エラー: \(error.localizedDescription)")
        }
    }

    public func stop() {
        recognizer?.stopRecognition()
    }
}
