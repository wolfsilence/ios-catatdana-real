import AVFoundation
import UIKit

//
//  VideoCompressor.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/11.
//

/// 视频压缩 & 缩略图，纯系统 API
enum VideoCompressor {

    // MARK: - 压缩

    /// 输入视频 URL → 压缩后 mp4，失败返回 nil
    /// 使用 AVAssetExportSession + MediumQuality 预设
    static func compress(inputURL: URL) async -> URL? {
        let asset = AVAsset(url: inputURL)
        guard let export = AVAssetExportSession(
            asset: asset,
            presetName: AVAssetExportPresetMediumQuality
        ) else {
            return nil
        }

        let outputURL = URL(fileURLWithPath: NSTemporaryDirectory())
            .appendingPathComponent(UUID().uuidString + ".mp4")

        // 清理残留文件
        try? FileManager.default.removeItem(at: outputURL)

        export.outputURL = outputURL
        export.outputFileType = .mp4
        export.shouldOptimizeForNetworkUse = true

        await export.export()

        guard export.status == .completed else { return nil }
        return outputURL
    }

    // MARK: - 缩略图

    /// 取视频第 1 秒帧作为预览图，失败返回 nil
    static func generateThumbnail(url: URL) -> UIImage? {
        let asset = AVAsset(url: url)
        let generator = AVAssetImageGenerator(asset: asset)
        generator.appliesPreferredTrackTransform = true
        generator.maximumSize = CGSize(width: 480, height: 480)

        let time = CMTime(seconds: 1, preferredTimescale: 600)
        guard let cgImage = try? generator.copyCGImage(at: time, actualTime: nil) else {
            return nil
        }
        return UIImage(cgImage: cgImage)
    }
}
