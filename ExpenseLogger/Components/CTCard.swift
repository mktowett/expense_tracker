//
//  CTCard.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct CTCard<Content: View>: View {
    let content: Content
    var backgroundColor: Color = .primaryBackground
    var hasShadow: Bool = true
    
    init(backgroundColor: Color = .primaryBackground, hasShadow: Bool = true, @ViewBuilder content: () -> Content) {
        self.backgroundColor = backgroundColor
        self.hasShadow = hasShadow
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(CTSpacing.md)
            .background(backgroundColor)
            .cornerRadius(CTCornerRadius.card)
            .overlay(
                RoundedRectangle(cornerRadius: CTCornerRadius.card)
                    .stroke(Color.borderColor, lineWidth: 1)
            )
            .conditionalShadow(hasShadow)
    }
}


#Preview {
    VStack(spacing: CTSpacing.md) {
        CTCard {
            VStack(alignment: .leading, spacing: CTSpacing.sm) {
                CTTextStyle.headline("Card Title")
                CTTextStyle.body("This is a sample card with some content to demonstrate the styling.")
            }
        }
        
        CTCard(backgroundColor: .secondaryBackground, hasShadow: false) {
            CTTextStyle.caption("Card without shadow")
        }
    }
    .padding()
}
