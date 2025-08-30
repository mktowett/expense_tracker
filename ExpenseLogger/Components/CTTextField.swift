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
        .font(.body)
        .foregroundColor(.textPrimary)
        .padding(CTSpacing.md)
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
        CTTextField(placeholder: "Enter amount", text: .constant(""))
        CTTextField(placeholder: "Description", text: .constant("Sample text"))
        CTTextField(placeholder: "Email", text: .constant(""), keyboardType: .emailAddress)
        CTTextField(placeholder: "Password", text: .constant(""), isSecure: true)
    }
    .padding()
    .background(Color.secondaryBackground)
}
