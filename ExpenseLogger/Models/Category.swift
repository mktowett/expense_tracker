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
            Category(name: "Food & Dining", color: "#F59E0B", icon: "fork.knife", isDefault: true),
            Category(name: "Transportation", color: "#3B82F6", icon: "car.fill", isDefault: true),
            Category(name: "Shopping", color: "#EC4899", icon: "bag.fill", isDefault: true),
            Category(name: "Entertainment", color: "#8B5CF6", icon: "tv.fill", isDefault: true),
            Category(name: "Bills & Utilities", color: "#EF4444", icon: "bolt.fill", isDefault: true),
            Category(name: "Healthcare", color: "#10B981", icon: "heart.fill", isDefault: true),
            Category(name: "Education", color: "#6366F1", icon: "book.fill", isDefault: true),
            Category(name: "Other", color: "#6B7280", icon: "questionmark.circle.fill", isDefault: true)
        ]
    }
}
