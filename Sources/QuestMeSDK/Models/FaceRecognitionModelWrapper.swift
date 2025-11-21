//
//  FaceRecognitionModelWrapper.swift
//  QuestMeSDK
//
//  Created by Junichi Tsumura on 2025/11/01
//  Related files:
//    - FaceEmbeddingModel.mlmodel (Xcode に追加済みの Core ML モデル)
//    - UIImage+PixelBuffer.swift (UIImage → CVPixelBuffer 変換ヘルパー, 下記に実装例あり)
//

import CoreML
import UIKit

/// FaceEmbeddingModel をラップし、画像から特徴ベクトルを抽出するクラス
final class FaceRecognitionModelWrapper {

    private let model: FaceEmbeddingModel

    init?() {
        do {
            self.model = try FaceEmbeddingModel(configuration: MLModelConfiguration())
        } catch {
            print("モデル初期化に失敗しました: \(error)")
            return nil
        }
    }

    /// UIImage から特徴ベクトルを生成
    func embed(from image: UIImage) throws -> String {
        guard let pixelBuffer = image.pixelBuffer(width: 224, height: 224) else {
            throw NSError(domain: "FaceRecognition", code: -1,
                          userInfo: [NSLocalizedDescriptionKey: "画像をPixelBufferに変換できませんでした"])
        }

        let input = FaceEmbeddingModelInput(image: pixelBuffer)
        let output = try model.prediction(input: input)

        // ⚠️ 出力名は .mlmodel に依存します。ここでは例として classLabel を使用。
        return output.classLabel
    }
}

// MARK: - UIImage → CVPixelBuffer 変換ヘルパー
extension UIImage {
    func pixelBuffer(width: Int, height: Int) -> CVPixelBuffer? {
        let attrs = [
            kCVPixelBufferCGImageCompatibilityKey: kCFBooleanTrue,
            kCVPixelBufferCGBitmapContextCompatibilityKey: kCFBooleanTrue
        ] as CFDictionary
        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(kCFAllocatorDefault,
                                         width,
                                         height,
                                         kCVPixelFormatType_32ARGB,
                                         attrs,
                                         &pixelBuffer)
        guard status == kCVReturnSuccess, let buffer = pixelBuffer else {
            return nil
        }

        CVPixelBufferLockBaseAddress(buffer, [])
        let context = CGContext(data: CVPixelBufferGetBaseAddress(buffer),
                                width: width,
                                height: height,
                                bitsPerComponent: 8,
                                bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
                                space: CGColorSpaceCreateDeviceRGB(),
                                bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue)
        guard let cgImage = self.cgImage else { return nil }
        context?.draw(cgImage, in: CGRect(x: 0, y: 0, width: width, height: height))
        CVPixelBufferUnlockBaseAddress(buffer, [])
        return buffer
    }
}
