//
//  Spacing.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

// MARK: - Claude-inspired Spacing Constants
struct CTSpacing {
    // Base spacing units (4px grid system like Claude)
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 12
    static let lg: CGFloat = 16
    static let xl: CGFloat = 20
    static let xxl: CGFloat = 24
    static let xxxl: CGFloat = 32
    
    // Component-specific spacing
    static let cardPadding: CGFloat = 16
    static let sectionSpacing: CGFloat = 24
    static let screenPadding: CGFloat = 16
    
    // Layout spacing
    static let listItemSpacing: CGFloat = 12
    
    /// Button spacing for consistent button layouts
    static let buttonSpacing: CGFloat = 12
    
    /// Horizontal margin for screen edges (backward compatibility)
    static let horizontalMargin: CGFloat = screenPadding
}

// MARK: - Claude-inspired Corner Radius
struct CTCornerRadius {
    static let standard: CGFloat = 8  // Claude's consistent radius
    static let card: CGFloat = 8
    static let input: CGFloat = 8
}

// MARK: - Claude-inspired Visual Effects (minimal shadows)
struct CTShadow {
    // Claude uses very subtle shadows or none at all
    static let none = (offset: CGSize.zero, radius: CGFloat(0), opacity: 0.0)
    static let subtle = (offset: CGSize(width: 0, height: 1), radius: CGFloat(2), opacity: 0.05)
}
