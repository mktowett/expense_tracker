//
//  CTTextField.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import SwiftUI

struct CTTextField: View {
    let placeholder: String
    @Binding var text: String
    var keyboardType: UIKeyboardType = .default
    var isSecure: Bool = false
    @FocusState private var isFocused: Bool
    
    var body: some View {
        Group {
            if isSecure {
                SecureField(placeholder, text: $text)
                    .focused($isFocused)
            } else {
                TextField(placeholder, text: $text)
                    .keyboardType(keyboardType)
                    .focused($isFocused)
            }
        }
        .font(.claudeBody)
        .foregroundColor(.textPrimary)
        .padding(.horizontal, 12)
        .padding(.vertical, 10)
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
        CTTextField(placeholder: "Enter amount", text: .constant(""))
        CTTextField(placeholder: "Description", text: .constant("Sample text"))
        CTTextField(placeholder: "Email", text: .constant(""), keyboardType: .emailAddress)
        CTTextField(placeholder: "Password", text: .constant(""), isSecure: true)
    }
    .padding()
    .background(Color.secondaryBackground)
}
