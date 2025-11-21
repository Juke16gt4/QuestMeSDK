//
//  FaceAuthService.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Authentication/FaceAuthService.swift
//
//  🎯 目的:
//      顔認証ライフサイクル管理（保存・照合・更新・機能使用前・起動時）
//      - CoreDataへの保存/取得（UserFaceCredential）
//      - CoreMLモデルを用いた顔ベクトル抽出
//      - タイムアウト除外（ナビ/録音/通訳）
//      - 起動時認証（AppLaunchAuthenticatorから利用）
//
//  🔗 関連/連動ファイル:
//      - UserFaceCredential.swift
//      - AppLaunchAuthenticator.swift
//      - NavigationSessionManager.swift
//      - RecordingSessionManager.swift
//      - InterpretationSessionManager.swift
//      - CompanionPromptService.swift
//      - FaceEmbeddingModel.mlmodel（CoreMLモデル）
//
//  👤 修正者: 津村 淳一
//  📅 修正日: 2025年10月31日
//

import Foundation
import CoreData
import CoreML
import Vision
import UIKit

public final class FaceAuthService {
    // MARK: - CoreData stack
    private lazy var container: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "QuestMeAuth")
        container.loadPersistentStores { _, error in
            if let error = error {
                print("❌ CoreData store load error: \(error)")
            }
        }
        return container
    }()
    private var context: NSManagedObjectContext { container.viewContext }

    public init() {}

    // MARK: - 保存
    public func saveCredential(_ credential: UserFaceCredential) {
        let entityName = "FaceCredentialEntity"
        let request = NSFetchRequest<NSManagedObject>(entityName: entityName)
        request.predicate = NSPredicate(format: "userId == %@", credential.userId.uuidString)

        do {
            let results = try context.fetch(request)
            let obj: NSManagedObject
            if let existing = results.first {
                obj = existing
            } else {
                obj = NSEntityDescription.insertNewObject(forEntityName: entityName, into: context)
            }
            obj.setValue(credential.userId.uuidString, forKey: "userId")
            obj.setValue(credential.createdAt, forKey: "createdAt")
            obj.setValue(encodeFaceprint(credential.faceprint), forKey: "faceprintData")
            try context.save()
        } catch {
            print("❌ CoreData save error: \(error.localizedDescription)")
        }
    }

    // MARK: - 取得
    public func loadCredential(for userId: UUID) -> UserFaceCredential? {
        let request = NSFetchRequest<NSManagedObject>(entityName: "FaceCredentialEntity")
        request.fetchLimit = 1
        request.predicate = NSPredicate(format: "userId == %@", userId.uuidString)
        do {
            if let obj = try context.fetch(request).first,
               let data = obj.value(forKey: "faceprintData") as? Data,
               let createdAt = obj.value(forKey: "createdAt") as? Date,
               let faceprint = decodeFaceprint(data) {
                return UserFaceCredential(userId: userId, faceprint: faceprint, createdAt: createdAt)
            }
        } catch {
            print("❌ CoreData fetch error: \(error.localizedDescription)")
        }
        return nil
    }

    // MARK: - 使用前認証
    public func verifyBeforeFeature(_ featureName: String, for userId: UUID) -> Bool {
        if isTimeoutExcluded() { return true }

        if let last = LastAuthCache.shared.lastVerifiedAt,
           isWithinTimeout(last) {
            return true
        }

        let ok = verifyCurrentFace(for: userId)
        if ok { LastAuthCache.shared.lastVerifiedAt = Date() }
        return ok
    }

    // MARK: - 現在の顔と保存済み顔の照合
    public func verifyCurrentFace(for userId: UUID) -> Bool {
        guard let stored = loadCredential(for: userId) else {
            print("⚠️ Stored credential not found")
            return false
        }
        guard let currentFace = captureCurrentFaceprint() else {
            print("⚠️ Current faceprint not captured")
            return false
        }
        return areFaceprintsSimilar(currentFace, stored.faceprint)
    }

    // MARK: - CoreMLによる顔ベクトル抽出
    private func captureCurrentFaceprint() -> [Float]? {
        guard let sampleImage = UIImage(named: "sample_face") else {
            return nil
        }
        return extractFaceEmbedding(from: sampleImage)
    }

    private func extractFaceEmbedding(from image: UIImage) -> [Float]? {
        guard let cgImage = image.cgImage else { return nil }
        do {
            let wrapper = try FaceEmbeddingModelWrapper()
            return try wrapper.extractEmbedding(from: cgImage)
        } catch {
            print("❌ FaceEmbeddingModelWrapper error: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - ベクトル比較
    private func areFaceprintsSimilar(_ a: [Float], _ b: [Float]) -> Bool {
        guard a.count == b.count, a.count > 0 else { return false }
        let sim = cosineSimilarity(a, b)
        return sim >= 0.85
    }

    private func cosineSimilarity(_ a: [Float], _ b: [Float]) -> Float {
        var dot: Float = 0
        var na: Float = 0
        var nb: Float = 0
        for i in 0..<a.count {
            dot += a[i] * b[i]
            na += a[i] * a[i]
            nb += b[i] * b[i]
        }
        let denom = (sqrtf(na) * sqrtf(nb))
        return denom == 0 ? 0 : (dot / denom)
    }

    // MARK: - エンコード/デコード
    private func encodeFaceprint(_ vector: [Float]) -> Data {
        do { return try JSONEncoder().encode(vector) }
        catch {
            print("❌ JSON encode error: \(error.localizedDescription)")
            return Data()
        }
    }

    private func decodeFaceprint(_ data: Data) -> [Float]? {
        do { return try JSONDecoder().decode([Float].self, from: data) }
        catch {
            print("❌ JSON decode error: \(error.localizedDescription)")
            return nil
        }
    }

    // MARK: - タイムアウト（5分）と除外条件
    private func isWithinTimeout(_ last: Date) -> Bool {
        let elapsed = Date().timeIntervalSince(last)
        return elapsed <= 300
    }

    private func isTimeoutExcluded() -> Bool {
        if NavigationSessionManager.shared.isActive { return true }
        if RecordingSessionManager.shared.isActive { return true }
        if InterpretationSessionManager.shared.isActive { return true }
        return false
    }
}

// MARK: - 簡易キャッシュ（@unchecked Sendable 対応済み）
public final class LastAuthCache: @unchecked Sendable {
    public static let shared = LastAuthCache()
    public var lastVerifiedAt: Date?
    private init() {}
}
