@preconcurrency import UIKit

//
//  ImageCompressor.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/4.
//

/// 图片压缩工具（Data 版本可在任意线程调用）
enum ImageCompressor {

    /// UIImage → 主线程取原始 JPEG Data（调用方必须在主线程）
    static func extractJPEG(_ image: UIImage, quality: CGFloat = 1.0) -> Data? {
        image.jpegData(compressionQuality: quality)
    }

    /// 对 JPEG Data 做二分压缩到 maxKB 以下，任意线程安全
    static func compress(_ data: Data, maxKB: Int = 250) -> Data {
        let maxBytes = maxKB * 1024
        if data.count <= maxBytes { return data }
        // 二分降低质量重编码
        var result = data
        var low: CGFloat = 0, high: CGFloat = 1.0
        let image = UIImage(data: data)
        for _ in 0..<8 {
            let mid = (low + high) / 2
            guard let compressed = image?.jpegData(compressionQuality: mid) else { break }
            if compressed.count <= maxBytes {
                low = mid
                result = compressed
            } else {
                high = mid
            }
        }
        return result
    }

    /// UIImage → 主线程取 JPEG + 压缩（便捷方法，需在主线程调用）
    static func compress(_ image: UIImage, maxKB: Int = 250) -> Data? {
        guard let data = extractJPEG(image) else { return nil }
        return compress(data, maxKB: maxKB)
    }

    /// UIImage → Base64 字符串（调用方必须在主线程）
    static func toBase64(_ image: UIImage, maxKB: Int = 250) -> String? {
        guard let data = compress(image, maxKB: maxKB) else { return nil }
        return dataToBase64(data)
    }

    /// JPEG Data → Base64 字符串，任意线程安全
    static func dataToBase64(_ data: Data) -> String {
        "data:image/jpeg;base64,\(data.base64EncodedString())"
    }
}
