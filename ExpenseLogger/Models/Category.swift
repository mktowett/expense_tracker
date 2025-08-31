//
//  Category.swift
//  ExpenseLogger
//
//  Created by marvin towett on 30/08/2025.
//

import Foundation
import SwiftData
import SwiftUI

@Model
final class Category {
    var id: UUID
    var name: String
    var color: String
    var icon: String
    var isDefault: Bool
    var createdAt: Date
    
    // Relationship
    @Relationship(deleteRule: .nullify, inverse: \Transaction.category)
    var transactions: [Transaction] = []
    
    init(name: String, color: String, icon: String, isDefault: Bool = false) {
        self.id = UUID()
        self.name = name
        self.color = color
        self.icon = icon
        self.isDefault = isDefault
        self.createdAt = Date()
    }
    
    // Convenience computed property for SwiftUI Color
    var swiftUIColor: Color {
        .iconPrimary  // Use unified icon color for all categories
    }
    
    // Static method to create default categories
    static func createDefaultCategories() -> [Category] {
        return [
            Category(name: "Groceries", color: "#6B7280", icon: "cart", isDefault: true),
            Category(name: "Uber", color: "#6B7280", icon: "car", isDefault: true),
            Category(name: "Credit", color: "#6B7280", icon: "creditcard", isDefault: true),
            Category(name: "Takeout", color: "#6B7280", icon: "takeoutbag.and.cup.and.straw", isDefault: true),
            Category(name: "Shopping", color: "#6B7280", icon: "bag", isDefault: true),
            Category(name: "Rent", color: "#6B7280", icon: "house", isDefault: true),
            Category(name: "Utilities", color: "#6B7280", icon: "bolt", isDefault: true),
            Category(name: "Subscriptions", color: "#6B7280", icon: "repeat.circle", isDefault: true)
        ]
    }
}
