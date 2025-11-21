//
//  CompanionPromptService.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Shared/CompanionPromptService.swift
//
//  🎯 目的:
//      ユーザーへの案内メッセージを一元管理（音声＋テキスト）。
//      開始時に「終了／閉じる」の明示的な終了方法を促す。
//      Swift Concurrency に対して @unchecked Sendable で安全性を明示。
//
//  🔗 関連/連動ファイル:
//      - CompanionSpeechService.swift（音声読み上げ）
//      - OpeningFlowView.swift（表示統合）
//      - NavigationSessionManager.swift / RecordingSessionManager.swift / InterpretationSessionManager.swift（各セッション）
//
//  👤 修正者: 津村 淳一
//  📅 修正日: 2025年10月31日
//

import Foundation

public final class CompanionPromptService: @unchecked Sendable {
    public static let shared = CompanionPromptService()
    private init() {}

    /// ユーザーに案内（音声＋テキスト想定）
    public func promptUser(message: String) {
        // ✅ ここで音声読み上げ＋UI表示を行う
        print("🤖 Companion: \(message)")
        // 例: CompanionSpeechService.shared.speak(message)
        // 例: UIにバナー表示
    }

    /// セッション開始時の定型案内（終了方法の促し）
    public func promptSessionStart(kind: String) {
        let msg = "\(kind)を開始しました。終了する場合は「終了」または「閉じる」と言ってください。"
        promptUser(message: msg)
    }

    /// セッション終了時の定型案内
    public func promptSessionEnd(kind: String) {
        let msg = "\(kind)を終了しました。"
        promptUser(message: msg)
    }
}
