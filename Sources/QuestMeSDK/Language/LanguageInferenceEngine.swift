//
//  LanguageInferenceEngine.swift
//  QuestMeSDK
//
//  🎯 音声認識結果から言語を推定し、母国語として設定する
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月30日
//  🔗 関連ファイル:
//      - AppLanguageManager.swift
//

import Foundation
import NaturalLanguage

public struct LanguageInferenceEngine {
    public static func inferLanguage(from text: String) -> String {
        let recognizer = NLLanguageRecognizer()
        recognizer.processString(text)
        let language = recognizer.dominantLanguage ?? .undetermined
        return language.rawValue
    }

    public static func setInferredLanguage(from text: String) {
        let code = inferLanguage(from: text)
        AppLanguageManager.shared.confirmLanguage(code: "ja")
        print("🌐 母国語を '\(code)' に設定しました")
    }
}
