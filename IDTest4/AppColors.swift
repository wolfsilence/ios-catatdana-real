import SwiftUI

//
//  Colors.swift
//  CatatDanaKu
//
//  Created by lishen on 2026/6/3.
//

class AppColors {
    static let whiteBg = Color.white
    static let primary = Color.accentColor
    static let launchBackground = Color(hex: "#F3F6F4")

    static let strPrimary   = Color(hex: "#222222")
    static let strSecondary = Color(hex: "#888888")
    static let strOnPrimary = Color.white
    static let strHint      = Color(hex: "#8F8FA1")
    
    static let loginWaBg = Color(hex: "#FA9D11")
}

// MARK: - Hex Support

extension Color {
    init(hex: String) {
        let raw = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        let r, g, b: Double
        
        guard let value = UInt(raw, radix: 16) else {
            self = .black
            return
        }
        
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
