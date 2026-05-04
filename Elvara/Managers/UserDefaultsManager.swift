//
//  UserDefaultsManager.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation

class UserDefaultsManager {
    static let shared = UserDefaultsManager()
    
    private let defaults = UserDefaults.standard
    private let userKey = "cached_user_profile"
    
    private init() {}
    
    // Store user into cache
    func saveUser(_ user: User) {
        if let encoded = try? JSONEncoder().encode(user) {
            defaults.set(encoded, forKey: userKey)
            print("User cached to UserDefaults")
        }
    }
    
    // Get user from cache
    func getCachedUser() -> User? {
        guard let data = defaults.data(forKey: userKey),
              let user = try? JSONDecoder().decode(User.self, from: data) else {
            print("No cached user found")
            return nil
        }
        print("User loaded from cache")
        return user
    }
    
    // Delete cache
    func clearCache() {
        defaults.removeObject(forKey: userKey)
        print("User cache cleared")
    }
    
    // Check if cache exists
    func hasCachedUser() -> Bool {
        return defaults.data(forKey: userKey) != nil
    }
}

extension UserDefaultsManager {
    private func customCategoriesKey(userId: String) -> String {
        return "custom_categories_\(userId)"
    }
    
    func saveCustomCategories(_ categories: [Category], userId: String) {
        if let encoded = try? JSONEncoder().encode(categories) {
            defaults.set(encoded, forKey: customCategoriesKey(userId: userId))
        }
    }
    
    func getCachedCustomCategories(userId: String) -> [Category]? {
        guard let data = defaults.data(forKey: customCategoriesKey(userId: userId)),
              let categories = try? JSONDecoder().decode([Category].self, from: data) else {
            return nil
        }
        return categories
    }
    
    func clearCustomCategories(userId: String) {
        defaults.removeObject(forKey: customCategoriesKey(userId: userId))
    }
}
