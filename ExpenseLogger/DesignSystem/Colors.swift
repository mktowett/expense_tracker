//
//  Colors.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

extension Color {
    // MARK: - Claude-inspired Background Colors (Light/Dark Mode)
    static let primaryBackground = Color(light: "#FFFFFF", dark: "#1A1A1A")
    static let secondaryBackground = Color(light: "#F8F9FA", dark: "#2A2A2A")
    static let tertiaryBackground = Color(light: "#F1F1F3", dark: "#333333")
    
    // MARK: - Claude-inspired Text Colors (Light/Dark Mode)
    static let textPrimary = Color(light: "#1F2937", dark: "#F2F2F2")
    static let textSecondary = Color(light: "#6B7280", dark: "#B3B3B3")
    static let textTertiary = Color(light: "#9CA3AF", dark: "#999999")
    
    // MARK: - Claude-inspired Accent Colors
    static let accentColor = Color(hex: "#D97706")  // Claude's warm orange
    static let accentSecondary = Color(hex: "#F59E0B")
    static let borderColor = Color(light: "#E1E1E6", dark: "#666666")
    static let borderLight = Color(light: "#EEEEEF", dark: "#595959")
    
    // MARK: - Claude-inspired Status Colors
    static let successColor = Color(hex: "#10B981")  // Softer green
    static let errorColor = Color(hex: "#EF4444")    // Softer red
    static let warningColor = Color(hex: "#D97706")
    
    // MARK: - Card System Colors
    static let cardBackground = Color(light: "#F8F9FA", dark: "#2A2A2A")
    static let cardBorder = Color(light: "#E5E7EB", dark: "#404040")
    static let cardShadow = Color.black.opacity(0.1)
    
    // MARK: - Claude-inspired Interactive Colors (Light/Dark Mode)
    static let hoverBackground = Color(light: "#F3F4F6", dark: "#383838")
    static let activeBackground = Color(light: "#E5E7EB", dark: "#404040")
    static let focusRing = Color(hex: "#D97706").opacity(0.3)
    
    // MARK: - Monochromatic Icon System
    static let iconPrimary = Color(hex: "#8B949E")  // Neutral gray for all icons
    static let iconSecondary = Color(hex: "#8B949E").opacity(0.7)  // Subtle variation
    static let iconBackground = Color.clear  // Transparent backgrounds
    
    // MARK: - Light/Dark Mode Helper
    init(light: String, dark: String) {
        self.init(UIColor { traitCollection in
            switch traitCollection.userInterfaceStyle {
            case .dark:
                return UIColor(Color(hex: dark))
            default:
                return UIColor(Color(hex: light))
            }
        })
    }
    
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
