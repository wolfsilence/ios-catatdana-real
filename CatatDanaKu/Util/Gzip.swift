import Foundation
import Compression

//  Gzip.swift
//  CatatDanaKu

/// gzip 压缩 — 使用 Compression framework
enum Gzip {

    /// 将 Data 压缩为 gzip 格式
    static func compress(_ data: Data) -> Data? {
        guard !data.isEmpty else { return data }

        // 1. deflate（zlib 格式）
        let maxDst = data.count + 256
        let dst = UnsafeMutablePointer<UInt8>.allocate(capacity: maxDst)
        defer { dst.deallocate() }

        let zlibSize = data.withUnsafeBytes { (src: UnsafeRawBufferPointer) -> Int in
            compression_encode_buffer(
                dst, maxDst,
                src.bindMemory(to: UInt8.self).baseAddress!, data.count,
                nil,
                COMPRESSION_ZLIB
            )
        }
        guard zlibSize > 6 else { return data }

        // 2. 剥离 zlib 头尾，只留 deflate 数据
        let deflateData = Data(bytes: dst.advanced(by: 2), count: zlibSize - 6)

        // 3. 组装 gzip 格式
        var result = Data()
        // gzip 头: ID1 ID2 CM FLG MTIME XFL OS
        result.append(contentsOf: [0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03])
        result.append(deflateData)
        // CRC32
        let crc = data.crc32()
        var crcLE = crc.littleEndian
        result.append(Data(bytes: &crcLE, count: 4))
        // ISIZE
        var sizeLE = UInt32(data.count).littleEndian
        result.append(Data(bytes: &sizeLE, count: 4))

        return result
    }
}

private extension Data {
    func crc32() -> UInt32 {
        var crc: UInt32 = 0xffffffff
        for byte in self {
            crc ^= UInt32(byte)
            for _ in 0..<8 {
                if (crc & 1) != 0 {
                    crc = (crc >> 1) ^ 0xedb88320
                } else {
                    crc >>= 1
                }
            }
        }
        return crc ^ 0xffffffff
    }
}
