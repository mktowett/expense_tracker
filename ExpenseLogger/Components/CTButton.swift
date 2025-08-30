//
//  CTButton.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct CTButton: View {
    let title: String
    let action: () -> Void
    var style: CTButtonStyle = .primary
    var isDisabled: Bool = false
    
    enum CTButtonStyle {
        case primary
        case secondary
        case destructive
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.headline)
                .foregroundColor(textColor)
                .frame(maxWidth: .infinity)
                .padding(.vertical, CTSpacing.md)
                .padding(.horizontal, CTSpacing.lg)
                .background(backgroundColor)
                .cornerRadius(CTCornerRadius.button)
                .overlay(
                    RoundedRectangle(cornerRadius: CTCornerRadius.button)
                        .stroke(borderColor, lineWidth: 1)
                )
                .shadow(
                    color: Color.black.opacity(CTShadow.subtle.opacity),
                    radius: CTShadow.subtle.radius,
                    x: CTShadow.subtle.offset.width,
                    y: CTShadow.subtle.offset.height
                )
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.6 : 1.0)
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .accentColor
        case .secondary:
            return .secondaryBackground
        case .destructive:
            return .errorColor
        }
    }
    
    private var textColor: Color {
        switch style {
        case .primary, .destructive:
            return .white
        case .secondary:
            return .textPrimary
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .destructive:
            return .clear
        case .secondary:
            return .borderColor
        }
    }
}

#Preview {
    VStack(spacing: CTSpacing.md) {
        CTButton(title: "Primary Button", action: {})
        CTButton(title: "Secondary Button", action: {}, style: .secondary)
        CTButton(title: "Destructive Button", action: {}, style: .destructive)
        CTButton(title: "Disabled Button", action: {}, isDisabled: true)
    }
    .padding()
}
