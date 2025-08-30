//
//  Colors.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

extension Color {
    // MARK: - Claude-inspired Background Colors
    static let primaryBackground = Color(hex: "#FFFFFF")
    static let secondaryBackground = Color(hex: "#F7F7F8")
    static let tertiaryBackground = Color(hex: "#F1F1F3")
    
    // MARK: - Claude-inspired Text Colors
    static let textPrimary = Color(hex: "#2D2D2D")
    static let textSecondary = Color(hex: "#656565")
    static let textTertiary = Color(hex: "#8E8EA0")
    
    // MARK: - Claude-inspired Accent Colors
    static let accentColor = Color(hex: "#D97706")  // Claude's warm orange
    static let accentSecondary = Color(hex: "#F59E0B")
    static let borderColor = Color(hex: "#E1E1E6")
    static let borderLight = Color(hex: "#EEEEEF")
    
    // MARK: - Claude-inspired Status Colors
    static let successColor = Color(hex: "#059669")
    static let errorColor = Color(hex: "#DC2626")
    static let warningColor = Color(hex: "#D97706")
    
    // MARK: - Claude-inspired Interactive Colors
    static let hoverBackground = Color(hex: "#F3F4F6")
    static let activeBackground = Color(hex: "#E5E7EB")
    static let focusRing = Color(hex: "#D97706").opacity(0.3)
    
    // MARK: - Helper initializer for hex colors
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
