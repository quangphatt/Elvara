//
//  DefaultCategories.swift
//  Elvara
//
//  Created by Quang Phat on 10/4/26.
//

import Foundation

enum DefaultCategories {
    // Income Categories
    static let incomeCategories: [Category] = [
        Category(
            id: "income_salary",
            name: "Salary",
            icon: "banknote",
            type: .income,
            color: "#34C759",
            order: 1
        ),
        Category(
            id: "income_business",
            name: "Business",
            icon: "briefcase.fill",
            type: .income,
            color: "#30D158",
            order: 2
        ),
        Category(
            id: "income_investment",
            name: "Investment",
            icon: "chart.line.uptrend.xyaxis",
            type: .income,
            color: "#32D74B",
            order: 3
        ),
        Category(
            id: "income_gift",
            name: "Gift",
            icon: "gift.fill",
            type: .income,
            color: "#64D2FF",
            order: 4
        ),
        Category(
            id: "income_other",
            name: "Other Income",
            icon: "plus.circle.fill",
            type: .income,
            color: "#5AC8FA",
            order: 5
        )
    ]
    
    // Expense Categories
    static let expenseCategories: [Category] = [
        Category(
            id: "expense_food",
            name: "Food & Dining",
            icon: "fork.knife",
            type: .expense,
            color: "#FF9500",
            order: 1
        ),
        Category(
            id: "expense_transport",
            name: "Transportation",
            icon: "car.fill",
            type: .expense,
            color: "#007AFF",
            order: 2
        ),
        Category(
            id: "expense_shopping",
            name: "Shopping",
            icon: "cart.fill",
            type: .expense,
            color: "#FF2D55",
            order: 3
        ),
        Category(
            id: "expense_entertainment",
            name: "Entertainment",
            icon: "tv.fill",
            type: .expense,
            color: "#AF52DE",
            order: 4
        ),
        Category(
            id: "expense_bills",
            name: "Bills & Utilities",
            icon: "bolt.fill",
            type: .expense,
            color: "#FFCC00",
            order: 5
        ),
        Category(
            id: "expense_health",
            name: "Healthcare",
            icon: "heart.fill",
            type: .expense,
            color: "#FF3B30",
            order: 6
        ),
        Category(
            id: "expense_education",
            name: "Education",
            icon: "book.fill",
            type: .expense,
            color: "#5856D6",
            order: 7
        ),
        Category(
            id: "expense_home",
            name: "Home & Rent",
            icon: "house.fill",
            type: .expense,
            color: "#8E8E93",
            order: 8
        ),
        Category(
            id: "expense_insurance",
            name: "Insurance",
            icon: "shield.fill",
            type: .expense,
            color: "#00C7BE",
            order: 9
        ),
        Category(
            id: "expense_other",
            name: "Other Expense",
            icon: "ellipsis.circle.fill",
            type: .expense,
            color: "#636366",
            order: 10
        )
    ]
    
    static var all: [Category] {
        incomeCategories + expenseCategories
    }
    
    static func getCategory(by id: String) -> Category? {
        all.first { $0.id == id }
    }
    
    static func getCategories(by type: TransactionType) -> [Category] {
        switch type {
        case .income:
            return incomeCategories
        case .expense:
            return expenseCategories
        case .transfer:
            return []
        }
    }
}
