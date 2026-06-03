import Foundation

/// 网络请求返回的通用结果包装
struct ServiceResponse<T: Codable> {
    /// 请求是否成功（状态码 2xx）
    let isSuccess: Bool
    /// 反序列化后的业务数据
    let payload: T?
    /// 服务端返回的状态码
    let statusCode: Int
    /// 服务端返回的提示信息
    let message: String?
}
