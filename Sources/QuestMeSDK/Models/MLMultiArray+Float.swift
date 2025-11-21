//
//  MLMultiArray+Float.swift
//  QuestMeSDK
//
//  📂 格納場所:
//      Sources/QuestMeSDK/Models/MLMultiArray+Float.swift
//
//  🎯 目的:
//      - MLMultiArray を [Float] に変換するユーティリティ
//
//  🔗 関連/連動ファイル:
//      - FaceEmbeddingModelWrapper.swift
//      - FaceAuthService.swift
//
//  👤 作成者: 津村 淳一
//  📅 作成日: 2025年10月31日
//

import CoreML

extension MLMultiArray {
    public func toFloatArray() -> [Float] {
        let count = self.count
        var result = [Float](repeating: 0, count: count)
        for i in 0..<count {
            result[i] = self[i].floatValue
        }
        return result
    }
}
