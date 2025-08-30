//
//  CTTextView.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct CTTextView: View {
    let placeholder: String
    @Binding var text: String
    var minHeight: CGFloat = 100
    @FocusState private var isFocused: Bool
    
    var body: some View {
        ZStack(alignment: .topLeading) {
            TextEditor(text: $text)
                .focused($isFocused)
                .font(.body)
                .foregroundColor(.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(.body)
                    .foregroundColor(.textSecondary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
        }
        .padding(CTSpacing.md)
        .frame(minHeight: minHeight)
        .background(Color.primaryBackground)
        .cornerRadius(CTCornerRadius.button)
        .overlay(
            RoundedRectangle(cornerRadius: CTCornerRadius.button)
                .stroke(isFocused ? Color.accentColor : Color.borderColor, lineWidth: 1)
        )
        .animation(.easeInOut(duration: 0.2), value: isFocused)
    }
}

#Preview {
    VStack(spacing: CTSpacing.md) {
        CTTextView(placeholder: "Enter description...", text: .constant(""))
        CTTextView(placeholder: "Notes", text: .constant("Sample longer text content"), minHeight: 120)
    }
    .padding()
    .background(Color.secondaryBackground)
}
