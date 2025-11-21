// The Swift Programming Language
// https://docs.swift.org/swift-book
//
//  QuestMeSDK.swift
//  QuestMeSDK
//
//  👤 Author: 津村 淳一
//  📅 Created: 2025/10/29
//  🔗 Related Files:
//      - LocalizationManager.swift
//      - SpeechService.swift
//      - FaceAuthService.swift
//

import Foundation

public final class QuestMeSDK {
    public static let shared = QuestMeSDK()

    public let locale: LocalizationManager
    public let speech: SpeechService
    public let faceAuth: FaceAuthService

    private init() {
        self.locale = LocalizationManager()
        self.speech = SpeechService(languageCode: locale.currentLanguage)
        self.faceAuth = FaceAuthService()
    }

    // 言語を変更したら SpeechService を再初期化（将来のホットスワップ用）
    public func updateLanguage(_ code: String) {
        locale.setLanguage(code)
        speech.updateLanguage(code)
    }
}
