import Foundation

//
//  NetError.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//
enum InternalErrors: Error {
    case invalidURL
    case tokenValid
    case overdue
    case emptyBody
    case jsonError
    case cryptError
}
