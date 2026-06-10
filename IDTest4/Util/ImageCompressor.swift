import UIKit

enum ImageCompressor {

    // MARK: - Public API

    /// UIImage → 压缩后 JPEG Data（先缩分辨率，再 JPEG 编码）
    static func compress(_ image: UIImage, maxKB: Int = 250) -> Data? {
        // 1. 缩分辨率：最长边 ≤ maxSide
        let resized = resize(image, maxSide: 800)
        // 2. 从合理 quality 出发二分，避免从 1.0 起产生巨量 data
        guard var jpeg = resized.jpegData(compressionQuality: 0.75) else { return nil }
        // 3. 二分微调 quality 到目标大小
        jpeg = compress(jpeg, maxKB: maxKB, sourceImage: resized)
        return jpeg
    }

    /// JPEG Data → 进一步压缩（二分 quality；须主线程调用，涉及 UIImage 重编码）
    static func compress(_ data: Data, maxKB: Int = 250, sourceImage: UIImage? = nil) -> Data {
        let maxBytes = maxKB * 1024
        guard data.count > maxBytes else { return data }

        guard let image = sourceImage ?? UIImage(data: data) else { return data }

        var bestData = data
        var low: CGFloat = 0.0
        var high: CGFloat = 1.0

        for _ in 0..<6 {
            let mid = (low + high) / 2.0
            guard mid > 0.01,
                  let compressed = image.jpegData(compressionQuality: mid) else { break }

            if compressed.count <= maxBytes {
                bestData = compressed
                low = mid
            } else {
                high = mid
            }

            if abs(compressed.count - maxBytes) < maxBytes / 20 { break }
        }

        return bestData
    }

    /// UIImage → Base64 字符串（主线程调用）
    static func toBase64(_ image: UIImage, maxKB: Int = 250) -> String? {
        guard let data = compress(image, maxKB: maxKB) else { return nil }
        return dataToBase64(data)
    }

    /// Data → Base64 Data URI（任意线程安全）
    static func dataToBase64(_ data: Data) -> String {
        let base64 = data.base64EncodedString()
        return "data:image/jpeg;base64,\(base64)"
    }

    // MARK: - Private

    /// 等比缩放，最长边 ≤ maxSide
    private static func resize(_ image: UIImage, maxSide: CGFloat) -> UIImage {
        let size = image.size
        let scale = min(maxSide / size.width, maxSide / size.height, 1)
        guard scale < 1 else { return image }

        let newSize = CGSize(width: size.width * scale, height: size.height * scale)
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            image.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
