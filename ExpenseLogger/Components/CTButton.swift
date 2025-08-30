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
    var size: CTButtonSize = .medium
    var isDisabled: Bool = false
    @State private var isPressed = false
    
    enum CTButtonStyle {
        case primary
        case secondary
        case ghost
        case destructive
    }
    
    enum CTButtonSize {
        case small
        case medium
        case large
    }
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(buttonFont)
                .foregroundColor(textColor)
                .frame(maxWidth: style == .ghost ? nil : .infinity)
                .padding(.vertical, verticalPadding)
                .padding(.horizontal, horizontalPadding)
                .background(backgroundColor)
                .cornerRadius(8) // Claude uses consistent 8px radius
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(borderColor, lineWidth: borderWidth)
                )
                .scaleEffect(isPressed ? 0.98 : 1.0)
                .animation(.easeInOut(duration: 0.1), value: isPressed)
        }
        .disabled(isDisabled)
        .opacity(isDisabled ? 0.5 : 1.0)
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
    
    private var backgroundColor: Color {
        switch style {
        case .primary:
            return .accentColor
        case .secondary:
            return .secondaryBackground
        case .ghost:
            return .clear
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
        case .ghost:
            return .accentColor
        }
    }
    
    private var borderColor: Color {
        switch style {
        case .primary, .destructive:
            return .clear
        case .secondary:
            return .borderLight
        case .ghost:
            return .borderLight
        }
    }
    
    private var borderWidth: CGFloat {
        switch style {
        case .primary, .destructive:
            return 0
        case .secondary, .ghost:
            return 1
        }
    }
    
    private var buttonFont: Font {
        switch size {
        case .small:
            return .claudeCaption
        case .medium:
            return .claudeBodyMedium
        case .large:
            return .claudeHeadline
        }
    }
    
    private var verticalPadding: CGFloat {
        switch size {
        case .small:
            return 8
        case .medium:
            return 12
        case .large:
            return 16
        }
    }
    
    private var horizontalPadding: CGFloat {
        switch size {
        case .small:
            return 12
        case .medium:
            return 16
        case .large:
            return 20
        }
    }
}

#Preview {
    VStack(spacing: CTSpacing.md) {
        CTButton(title: "Primary Button", action: {})
        CTButton(title: "Secondary Button", action: {}, style: .secondary)
        CTButton(title: "Ghost Button", action: {}, style: .ghost)
        CTButton(title: "Destructive Button", action: {}, style: .destructive)
        CTButton(title: "Small Button", action: {}, size: .small)
        CTButton(title: "Disabled Button", action: {}, isDisabled: true)
    }
    .padding()
}
