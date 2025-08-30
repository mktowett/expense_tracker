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
    var borderColor: Color = .borderLight
    var hasBorder: Bool = true
    var padding: CGFloat = 16
    
    init(
        backgroundColor: Color = .primaryBackground,
        borderColor: Color = .borderLight,
        hasBorder: Bool = true,
        padding: CGFloat = 16,
        @ViewBuilder content: () -> Content
    ) {
        self.backgroundColor = backgroundColor
        self.borderColor = borderColor
        self.hasBorder = hasBorder
        self.padding = padding
        self.content = content()
    }
    
    var body: some View {
        content
            .padding(padding)
            .background(backgroundColor)
            .cornerRadius(8) // Claude uses consistent 8px radius
            .overlay(
                RoundedRectangle(cornerRadius: 8)
                    .stroke(hasBorder ? borderColor : .clear, lineWidth: 1)
            )
    }
}


#Preview {
    VStack(spacing: 16) {
        CTCard {
            VStack(alignment: .leading, spacing: 8) {
                CTTextStyle.headline("Card Title")
                CTTextStyle.body("This is a sample card with Claude-inspired styling.")
            }
        }
        
        CTCard(backgroundColor: .secondaryBackground, hasBorder: false) {
            CTTextStyle.caption("Card without border")
        }
        
        CTCard(backgroundColor: .tertiaryBackground, padding: 12) {
            CTTextStyle.small("Compact card with less padding")
        }
    }
    .padding()
}
