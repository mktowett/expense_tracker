//
//  Spacing.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

// MARK: - Spacing Constants (8px grid system)
struct CTSpacing {
    static let xs: CGFloat = 4
    static let sm: CGFloat = 8
    static let md: CGFloat = 16
    static let lg: CGFloat = 24
    static let xl: CGFloat = 32
    static let xxl: CGFloat = 48
    
    // MARK: - Default margins
    static let horizontalMargin: CGFloat = 16
}

// MARK: - Corner Radius Constants
struct CTCornerRadius {
    static let button: CGFloat = 8
    static let card: CGFloat = 12
}

// MARK: - Shadow Constants
struct CTShadow {
    static let subtle = (offset: CGSize(width: 0, height: 1), radius: CGFloat(3), opacity: 0.1)
}
