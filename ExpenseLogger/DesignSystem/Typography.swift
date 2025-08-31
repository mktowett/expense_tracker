//
//  Typography.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

extension Font {
    // MARK: - Claude-inspired Typography System
    static let claudeTitleLarge = Font.system(size: 28, weight: .semibold, design: .default)
    static let claudeTitleMedium = Font.system(size: 20, weight: .medium, design: .default)
    static let claudeHeadline = Font.system(size: 16, weight: .medium, design: .default)
    static let claudeBody = Font.system(size: 14, weight: .regular, design: .default)
    static let claudeBodyMedium = Font.system(size: 14, weight: .medium, design: .default)
    static let claudeCaption = Font.system(size: 12, weight: .regular, design: .default)
    static let claudeSmall = Font.system(size: 11, weight: .regular, design: .default)
    
    // MARK: - Dashboard-specific Typography (Premium Hierarchy)
    static let balanceAmount = Font.system(size: 24, weight: .semibold, design: .default)
    static let balanceLabel = Font.system(size: 14, weight: .medium, design: .default)
    static let statsAmount = Font.system(size: 16, weight: .semibold, design: .default)
    static let statsLabel = Font.system(size: 12, weight: .medium, design: .default)
    static let merchantName = Font.system(size: 16, weight: .medium, design: .default)
    static let transactionAmount = Font.system(size: 16, weight: .semibold, design: .default)
    static let transactionDate = Font.system(size: 12, weight: .regular, design: .default)
    static let transactionType = Font.system(size: 12, weight: .regular, design: .default)
}

// MARK: - Claude-inspired Text Styles
struct CTTextStyle {
    static func titleLarge(_ text: String) -> some View {
        Text(text)
            .font(.claudeTitleLarge)
            .foregroundColor(.textPrimary)
            .lineSpacing(2)
    }
    
    static func titleMedium(_ text: String) -> some View {
        Text(text)
            .font(.claudeTitleMedium)
            .foregroundColor(.textPrimary)
            .lineSpacing(1)
    }
    
    static func headline(_ text: String) -> some View {
        Text(text)
            .font(.claudeHeadline)
            .foregroundColor(.textPrimary)
    }
    
    static func body(_ text: String) -> some View {
        Text(text)
            .font(.claudeBody)
            .foregroundColor(.textPrimary)
            .lineSpacing(1)
    }
    
    static func bodyMedium(_ text: String) -> some View {
        Text(text)
            .font(.claudeBodyMedium)
            .foregroundColor(.textPrimary)
    }
    
    static func caption(_ text: String) -> some View {
        Text(text)
            .font(.claudeCaption)
            .foregroundColor(.textSecondary)
    }
    
    static func small(_ text: String) -> some View {
        Text(text)
            .font(.claudeSmall)
            .foregroundColor(.textTertiary)
    }
}
