//
//  AppLanguageManager.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Language/AppLanguageManager.swift
//
//  🎯 目的:
//      - 現在の言語設定を管理
//      - ISO準拠の言語コードを提供（音声認識などで使用）
//      - 並行安全性を確保（@MainActor）
//
//  🔗 関連/連動ファイル:
//      - CompanionSpeechService.swift
//      - SpeechRecognizer.swift
//      - LanguageCode.swift（定義があれば）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月31日
//

import Foundation

@MainActor
public final class AppLanguageManager {
    public static let shared = AppLanguageManager()

    /// アプリ内で選択された言語（ISO 639-1）
    public var currentLanguage: String = "ja"

    /// 音声認識やCoreMLで使用するISO準拠の言語コード
    public var languageCode: String {
        switch currentLanguage {
        case "ja": return "ja-JP"
        case "en": return "en-US"
        case "fr": return "fr-FR"
        case "de": return "de-DE"
        case "zh": return "zh-CN"
        default: return "en-US"
        }
    }

    private init() {}
}
