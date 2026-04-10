//
//  CategoryViewModel.swift
//  Elvara
//
//  Created by Quang Phat on 10/4/26.
//

import Foundation
import Combine

@MainActor
class CategoryViewModel: ObservableObject {
    @Published var categories: [Category] = []
    @Published var incomeCategories: [Category] = []
    @Published var expenseCategories: [Category] = []
    @Published var isLoading = false
    
    private let manager = CategoryManager.shared
    
    func loadCategories(for userId: String) async {
        isLoading = true
        categories = await manager.getCategories(for: userId)
        
        // Separate by type
        incomeCategories = categories.filter { $0.type == .income }
        expenseCategories = categories.filter { $0.type == .expense }
        
        isLoading = false
    }
    
    func loadCategories(for userId: String, type: TransactionType) async {
        isLoading = true
        categories = await manager.getCategories(for: userId, type: type)
        isLoading = false
    }
    
    func createCategory(name: String, icon: String, type: TransactionType, 
                       color: String, userId: String) async {
        do {
            let category = Category(
                name: name,
                icon: icon,
                type: type,
                color: color,
                order: categories.count + 1,
                isDefault: false,
                userId: userId
            )
            
            let id = try await manager.createCategory(category)
            var newCategory = category
            newCategory.id = id
            categories.append(newCategory)
            
            // Update type-specific arrays
            if type == .income {
                incomeCategories.append(newCategory)
            } else {
                expenseCategories.append(newCategory)
            }
        } catch {
            print("Failed to create category: \(error)")
        }
    }
}
