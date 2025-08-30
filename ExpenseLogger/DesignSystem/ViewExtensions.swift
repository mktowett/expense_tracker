//
//  ViewExtensions.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

// MARK: - Claude-inspired Layout Extensions
extension View {
    /// Applies Claude-style screen padding
    func claudeScreenPadding() -> some View {
        self.padding(.horizontal, CTSpacing.screenPadding)
    }
    
    /// Applies Claude-style section spacing
    func claudeSectionSpacing() -> some View {
        self.padding(.vertical, CTSpacing.sectionSpacing)
    }
    
    /// Claude-style card with minimal styling
    func claudeCard(
        backgroundColor: Color = .primaryBackground,
        borderColor: Color = .borderLight,
        hasBorder: Bool = true
    ) -> some View {
        self
            .padding(CTSpacing.cardPadding)
            .background(backgroundColor)
            .cornerRadius(CTCornerRadius.standard)
            .overlay(
                RoundedRectangle(cornerRadius: CTCornerRadius.standard)
                    .stroke(hasBorder ? borderColor : .clear, lineWidth: 1)
            )
    }
    
    /// Claude-style list item with consistent spacing
    func claudeListItem() -> some View {
        self
            .padding(.vertical, CTSpacing.listItemSpacing)
            .padding(.horizontal, CTSpacing.screenPadding)
    }
    
    /// Claude-style screen background (clean and minimal)
    func claudeScreenBackground() -> some View {
        self
            .background(Color.secondaryBackground.ignoresSafeArea())
    }
    
    /// Claude-style button row spacing
    func claudeButtonSpacing() -> some View {
        self.padding(.vertical, CTSpacing.buttonSpacing)
    }
    
    // MARK: - Backward Compatibility (Temporary)
    /// Legacy horizontal padding - maps to Claude style
    func ctHorizontalPadding() -> some View {
        self.claudeScreenPadding()
    }
    
    /// Legacy vertical spacing - maps to Claude style
    func ctVerticalSpacing(_ spacing: CGFloat = CTSpacing.sectionSpacing) -> some View {
        self.padding(.vertical, spacing)
    }
    
    /// Legacy screen background - maps to Claude style
    func ctScreenBackground() -> some View {
        self.claudeScreenBackground()
    }
    
    /// Legacy card style - maps to Claude style
    func ctCardStyle(backgroundColor: Color = .primaryBackground, hasShadow: Bool = true) -> some View {
        self.claudeCard(backgroundColor: backgroundColor, hasBorder: !hasShadow)
    }
    
    /// Legacy shadow helper - maps to Claude style (minimal)
    func conditionalShadow(_ hasShadow: Bool) -> some View {
        self // Claude design uses minimal shadows
    }
}
