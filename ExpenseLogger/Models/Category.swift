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
        Color(hex: color) ?? .gray
    }
    
    // Static method to create default categories
    static func createDefaultCategories() -> [Category] {
        return [
            Category(name: "Groceries", color: "#8B949E", icon: "cart", isDefault: true),
            Category(name: "Uber", color: "#8B949E", icon: "car", isDefault: true),
            Category(name: "Credit", color: "#8B949E", icon: "creditcard", isDefault: true),
            Category(name: "Takeout", color: "#8B949E", icon: "takeoutbag.and.cup.and.straw", isDefault: true),
            Category(name: "Shopping", color: "#8B949E", icon: "bag", isDefault: true),
            Category(name: "Rent", color: "#8B949E", icon: "house", isDefault: true),
            Category(name: "Utilities", color: "#8B949E", icon: "bolt", isDefault: true),
            Category(name: "Subscriptions", color: "#8B949E", icon: "repeat.circle", isDefault: true)
        ]
    }
}
