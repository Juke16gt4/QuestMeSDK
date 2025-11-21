//
//  AppLaunchAuthenticator.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Authentication/AppLaunchAuthenticator.swift
//
//  🎯 目的:
//      アプリ起動時に顔認証を実行し、ユーザー本人確認を行う
//
//  🔗 関連/連動ファイル:
//      - FaceAuthService.swift
//      - UserFaceCredential.swift
//      - LastAuthCache（最終認証時刻の保持）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月30日
//

import Foundation

public struct AppLaunchAuthenticator {
    public static func verifyOnLaunch(for userId: UUID) -> Bool {
        let faceAuth = FaceAuthService()
        let ok = faceAuth.verifyCurrentFace(for: userId)
        if ok { LastAuthCache.shared.lastVerifiedAt = Date() }
        return ok
    }
}
