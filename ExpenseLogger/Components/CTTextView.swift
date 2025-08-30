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
                .font(.claudeBody)
                .foregroundColor(.textPrimary)
                .scrollContentBackground(.hidden)
                .background(Color.clear)
            
            if text.isEmpty {
                Text(placeholder)
                    .font(.claudeBody)
                    .foregroundColor(.textTertiary)
                    .padding(.horizontal, 4)
                    .padding(.vertical, 8)
                    .allowsHitTesting(false)
            }
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
        .frame(minHeight: minHeight)
        .background(Color.primaryBackground)
        .cornerRadius(8) // Claude uses consistent 8px radius
        .overlay(
            RoundedRectangle(cornerRadius: 8)
                .stroke(isFocused ? Color.accentColor : Color.borderLight, lineWidth: isFocused ? 2 : 1)
        )
        .animation(.easeInOut(duration: 0.15), value: isFocused)
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
