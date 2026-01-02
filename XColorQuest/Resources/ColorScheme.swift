//
//  ColorScheme.swift
//  ColorQuest
//
//  Color scheme definitions for the app
//

import SwiftUI

struct ColorScheme {
    // Primary color scheme from requirements
    static let background = Color(hex: "#213d62")
    static let buttonPrimary = Color(hex: "#4a8fdc")
    static let buttonSecondary = Color(hex: "#86b028")
    static let accentPrimary = Color(hex: "#82AF31")
    static let accentSecondary = Color(hex: "#FFFFFF")
    
    // Additional colors for enhanced UI
    static let textPrimary = Color.white
    static let textSecondary = Color.white.opacity(0.7)
    static let success = Color(hex: "#86b028")
    static let error = Color(hex: "#FF6B6B")
    static let warning = Color(hex: "#FFD93D")
}

// Color extension for hex support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

