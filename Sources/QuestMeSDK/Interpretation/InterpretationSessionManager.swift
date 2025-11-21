//
//  InterpretationSessionManager.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Interpretation/InterpretationSessionManager.swift
//
//  🎯 目的:
//      通訳機能使用中は認証タイムアウト除外。
//      開始時に「終了」や「閉じる」で明示的に終わらせるよう促す案内を実施。
//      Swift Concurrency に対して @unchecked Sendable で安全性を明示。
//
//  🔗 関連/連動ファイル:
//      - FaceAuthService.swift（タイムアウト除外判定で参照）
//      - CompanionPromptService.swift（案内表示）
//
//  👤 修正者: 津村 淳一
//  📅 修正日: 2025年10月30日
//

import Foundation

public final class InterpretationSessionManager: @unchecked Sendable {
    public static let shared = InterpretationSessionManager()
    public private(set) var isActive: Bool = false

    private init() {}

    public func startSession() {
        isActive = true
        CompanionPromptService.shared.promptSessionStart(kind: "通訳")
    }

    public func endSession() {
        isActive = false
        CompanionPromptService.shared.promptSessionEnd(kind: "通訳")
    }
}
