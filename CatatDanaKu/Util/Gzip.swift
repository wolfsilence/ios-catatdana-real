import Foundation
import Compression

//  Gzip.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/6.

/// gzip 压缩工具 — 使用 Apple Compression framework 完成 deflate，再手工封装 gzip 格式
enum Gzip {

    /// 将 Data 压缩为 gzip 格式
    static func compress(_ data: Data) -> Data? {
        guard !data.isEmpty else { return nil }

        // 1. deflate 压缩（zlib 格式：2 字节头 + 压缩数据 + 4 字节 Adler32 尾）
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
        guard zlibSize > 6 else { return nil }

        // 2. 剥离 zlib 壳 — 跳过头 2 字节 + 尾 4 字节，只留 raw deflate
        let deflateData = Data(bytes: dst.advanced(by: 2), count: zlibSize - 6)

        // 3. 组装 gzip
        var result = Data()
        // Gzip 头: ID1 ID2 CM FLG MTIME(4) XFL OS
        result.append(contentsOf: [0x1f, 0x8b, 0x08, 0x00, 0x00, 0x00, 0x00, 0x00, 0x00, 0x03])
        result.append(deflateData)
        // CRC32
        let crc = crc32Sum(data)
        var crcLE = crc.littleEndian
        result.append(Data(bytes: &crcLE, count: 4))
        // ISIZE (原始大小 mod 2^32)
        var sizeLE = UInt32(data.count % (1 << 32)).littleEndian
        result.append(Data(bytes: &sizeLE, count: 4))

        return result
    }

    // MARK: - CRC32

    private static func crc32Sum(_ data: Data) -> UInt32 {
        var crc: UInt32 = 0xffffffff
        for byte in data {
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
