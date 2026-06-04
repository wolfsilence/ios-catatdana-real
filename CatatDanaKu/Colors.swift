import SwiftUI

//
//  Colors.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

class Colors {
    static let primary          = Color.accentColor
    static let launchBackground = Color(hex: "#F3F6F3")
    static let background       = Color.white
    static let surface       = Color.gray.opacity(0.15)
    static let textPrimary   = Color(hex: "#222222")
    static let textSecondary = Color(hex: "#888888")
    static let textOnPrimary = Color.white
    static let textHint      = Color(hex: "#8F8FA1")

    // MARK: 协议页渐变
    static let protocolGradientTop    = Color(hex: "#06CA5E")
    static let protocolGradientMid    = Color(hex: "#06CF61")
    static let protocolGradientBottom = Color(hex: "#00873D")
}

// MARK: - Login Colors

extension Color {
    static let waOrange = Color(hex: "#FA9D11")
}

// MARK: - Hex Support

extension Color {
    init(hex: String) {
        let raw = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        guard let value = UInt(raw, radix: 16) else {
            self = .black
            return
        }
        let r, g, b: Double
        if raw.count == 6 {
            r = Double((value >> 16) & 0xFF) / 255.0
            g = Double((value >>  8) & 0xFF) / 255.0
            b = Double((value >>  0) & 0xFF) / 255.0
        } else {
            self = .black
            return
        }
        self.init(red: r, green: g, blue: b)
    }
}
