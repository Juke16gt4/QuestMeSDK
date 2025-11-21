//
//  LocalizationManager.swift
//  QuestMeSDK
//
//  👤 Author: 津村 淳一
//  📅 Created: 2025/10/29
//  🔗 Related Files:
//      - QuestMeSDK.swift
//

import Foundation
import Combine

@MainActor
public final class LocalizationManager: ObservableObject {
    @Published public private(set) var currentLanguage: String
    private let key = "userPreferredLanguage"

    public init() {
        if let saved = UserDefaults.standard.string(forKey: key) {
            self.currentLanguage = saved
        } else {
            // 例: "ja-JP" / "en-US"
            self.currentLanguage = Locale.current.identifier
        }
    }

    public func setLanguage(_ code: String) {
        self.currentLanguage = code
        UserDefaults.standard.set(code, forKey: key)
    }
}
