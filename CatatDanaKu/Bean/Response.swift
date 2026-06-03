import Foundation

//
//  Response.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//
struct Response <T: Codable>: Codable {
    var code : Int
    var data : T?
    var msg : String?
}
