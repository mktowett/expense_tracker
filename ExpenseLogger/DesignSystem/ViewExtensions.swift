//
//  ViewExtensions.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

// MARK: - Safe Area and Layout Extensions
extension View {
    /// Applies consistent horizontal margins with safe area handling
    func ctHorizontalPadding() -> some View {
        self.padding(.horizontal, CTSpacing.horizontalMargin)
    }
    
    /// Applies consistent vertical spacing
    func ctVerticalSpacing(_ spacing: CGFloat = CTSpacing.md) -> some View {
        self.padding(.vertical, spacing)
    }
    
    /// Applies the standard card styling
    func ctCardStyle(backgroundColor: Color = .primaryBackground, hasShadow: Bool = true) -> some View {
        self
            .padding(CTSpacing.md)
            .background(backgroundColor)
            .cornerRadius(CTCornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CTCornerRadius.card)
                    .stroke(Color.borderColor, lineWidth: 1)
            )
            .conditionalShadow(hasShadow)
    }
    
    /// Applies subtle shadow if enabled
    func conditionalShadow(_ hasShadow: Bool) -> some View {
        Group {
            if hasShadow {
                self.shadow(
                    color: Color.black.opacity(CTShadow.subtle.opacity),
                    radius: CTShadow.subtle.radius,
                    x: CTShadow.subtle.offset.width,
                    y: CTShadow.subtle.offset.height
                )
            } else {
                self
            }
        }
    }
    
    /// Standard screen background with safe area handling
    func ctScreenBackground() -> some View {
        self
            .background(Color.secondaryBackground.ignoresSafeArea())
            .navigationBarHidden(true)
    }
}
