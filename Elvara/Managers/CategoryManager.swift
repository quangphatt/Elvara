//
//  CategoryManager.swift
//  Elvara
//
//  Created by Quang Phat on 10/4/26.
//

import Foundation

class CategoryManager {
    static let shared = CategoryManager()
    
    private let cache = UserDefaultsManager.shared
    private let service = CategoryService()
    
    private init() {}
    
    // Get all categories for user (default + custom)
    func getCategories(for userId: String) async -> [Category] {
        // 1. Get default categories
        var allCategories = DefaultCategories.all
        
        // 2. Try to get custom categories from cache
        if let cached = cache.getCachedCustomCategories(userId: userId) {
            allCategories.append(contentsOf: cached)
            
            // Background sync
            Task {
                await syncCustomCategories(userId: userId)
            }
            return allCategories
        }
        
        // 3. Fetch custom from Firebase
        do {
            let customCategories = try await service.fetchUserCategories(userId: userId)
            cache.saveCustomCategories(customCategories, userId: userId)
            allCategories.append(contentsOf: customCategories)
        } catch {
            print("Failed to fetch custom categories: \(error)")
        }
        
        return allCategories
    }
    
    // Get categories by type
    func getCategories(for userId: String, type: TransactionType) async -> [Category] {
        let all = await getCategories(for: userId)
        return all.filter { $0.type == type }
    }
    
    // Create custom category
    func createCategory(_ category: Category) async throws -> String {
        let categoryId = try await service.createCategory(category)
        
        // Update cache
        if let userId = category.userId {
            var cached = cache.getCachedCustomCategories(userId: userId) ?? []
            var newCategory = category
            newCategory.id = categoryId
            cached.append(newCategory)
            cache.saveCustomCategories(cached, userId: userId)
        }
        
        return categoryId
    }
    
    // Background sync
    private func syncCustomCategories(userId: String) async {
        do {
            let categories = try await service.fetchUserCategories(userId: userId)
            cache.saveCustomCategories(categories, userId: userId)
        } catch {
            print("Sync failed: \(error)")
        }
    }
}
