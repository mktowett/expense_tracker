//
//  Typography.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

extension Font {
    // MARK: - Typography System
    static let titleLarge = Font.custom("SF Pro Display", size: 28).weight(.bold)
    static let titleMedium = Font.custom("SF Pro Display", size: 22).weight(.semibold)
    static let headline = Font.custom("SF Pro Text", size: 17).weight(.semibold)
    static let body = Font.custom("SF Pro Text", size: 17).weight(.regular)
    static let caption = Font.custom("SF Pro Text", size: 12).weight(.regular)
}

// MARK: - Text Styles for consistent usage
struct CTTextStyle {
    static func titleLarge(_ text: String) -> some View {
        Text(text)
            .font(.titleLarge)
            .foregroundColor(.textPrimary)
    }
    
    static func titleMedium(_ text: String) -> some View {
        Text(text)
            .font(.titleMedium)
            .foregroundColor(.textPrimary)
    }
    
    static func headline(_ text: String) -> some View {
        Text(text)
            .font(.headline)
            .foregroundColor(.textPrimary)
    }
    
    static func body(_ text: String) -> some View {
        Text(text)
            .font(.body)
            .foregroundColor(.textPrimary)
    }
    
    static func caption(_ text: String) -> some View {
        Text(text)
            .font(.caption)
            .foregroundColor(.textSecondary)
    }
}
