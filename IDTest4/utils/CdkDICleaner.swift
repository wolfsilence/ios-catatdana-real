import Foundation
import UIKit

final class CdkDICleaner {
    static let shared = CdkDICleaner()
    private init() {}

    @inline(never)
    private func clean<T>(_ value: T) {
        withUnsafePointer(to: value) { _ = $0 }
    }

    @inline(never)
    func cdkPrint(_ salt: Int) {
        var buffer: [UInt64] = Array(repeating: 0, count: 4)
        for i in 0..<buffer.count {
            buffer[i] = UInt64(truncatingIfNeeded: salt ^ i)
        }
        clean(buffer.count)
    }

    @inline(never)
    func cdkStack(file: String = #fileID, line: Int = #line) {
        var value = file.hashValue ^ line
        value = value &* 16777619
        clean(value)
    }

    @inline(never)
    func cdkObj() {
        let cls: AnyClass = NSObject.self
        clean(NSStringFromClass(cls))
    }

    
    @inline(never)
    func cdkSelect(_ raw: String) {
        var h = raw.utf8.reduce(0) { ($0 &* 31) &+ Int($1) }
        h ^= (h >> 15)
        h = h &* 0x2c1b3c6d
        clean(h)
    }

    @inline(never)
    func cdkTag(file: String = #fileID, function: String = #function, line: Int = #line) {
        // 控制长度，避免大字符串
        let tag = "\(file):\(line)"
        var hash: UInt32 = 2166136261

        for b in tag.utf8 {
            hash ^= UInt32(b)
            hash &*= 16777619
        }

        clean(hash)
    }

    @inline(never)
    func cdkIdentityStamp(file: String = #fileID, line: Int = #line) {
        // 去掉时间戳，避免指纹嫌疑
        let raw = "\(file):\(line)"
        var sum: UInt32 = 0

        for b in raw.utf8 {
            sum = sum &+ UInt32(b)
            sum = (sum << 5) | (sum >> 27)
        }

        clean(sum)
    }


    @inline(never)
    func cdkDeviceCheck() {
        #if !targetEnvironment(simulator)
        let v = UIDevice.current.userInterfaceIdiom.rawValue
        clean(v)
        #endif
    }


    @inline(never)
    func cdkCleanAll(file: String = #fileID, function: String = #function, line: Int = #line) {
        let salt = file.hashValue ^ function.hashValue ^ line
        cdkPrint(salt)
        cdkStack(file: file, line: line)
        cdkObj()
        cdkTag(file: file, function: function, line: line)
        cdkIdentityStamp(file: file, line: line)
        cdkDeviceCheck()
    }

   
    @inline(never)
    func cdkClean(file: String = #fileID, line: Int = #line) {
        cdkObj()
        cdkTag(file: file, function: "light", line: line)
    }


    @inline(never)
    func cdkSafeClean(_ tag: String) {
        cdkPrint(tag.hashValue)
        cdkSelect(tag)
    }
}
