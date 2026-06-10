import Foundation

//
//  NetPath.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//
class NetPath {
    static let loginOneClick = "/leopard/v1/login/oneClick" // OneClickReq, OneClickResp
    static let loginVCode = "/leopard/v1/login/vcode" // VCodeReq, VCodeResp
    static let login = "/leopard/v1/login" // LoginReq, LoginResp
    static let userRuntime = "/leopard/v1/user/runtime" // RuntimeReq, EmptyResp
    static let survey = "/leopard/v1/survey" // SurveyReq, EmptyResp
    static let accRecgFace = "/leopard/v1/user/acc/recgFace" // RecgFaceReq, RecgFaceResp
    static let ossUpload = "/leopard/v1/oss/upload" // 图片数据流, OssUploadResp
    static let configKyc = "/leopard/v1/config/kyc" // get请求，ConfigKycResp
    static let anyBiz = "/leopard/v1/user/filterProduct" // AReq, EmptyResp
}
