//
//  UserFaceCredential.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Authentication/UserFaceCredential.swift
//
//  🎯 目的:
//      顔認証用のユーザー本人ベクトルを保持する構造体
//
//  🔗 関連/連動ファイル:
//      - FaceAuthService.swift（照合時の参照）
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月29日
//

import Foundation

public struct UserFaceCredential: Codable {
    public let userId: UUID
    public let faceprint: [Float]
    public let createdAt: Date

    public init(userId: UUID, faceprint: [Float], createdAt: Date = Date()) {
        self.userId = userId
        self.faceprint = faceprint
        self.createdAt = createdAt
    }
}
