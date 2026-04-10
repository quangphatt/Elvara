//
//  AuthRepository.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation

class AuthRepository {
    private let authService = AuthService()
    private let userService = UserService()
    private let cache = UserDefaultsManager.shared
    
    func login(email: String, password: String) async throws -> User {
        let basicUser = try await authService.login(email: email, password: password)
                
        // Fetch full profile from Firestore
        do {
            let fullUser = try await userService.getUserProfile(userId: basicUser.id)
            
            // Cache into UserDefaults
            cache.saveUser(fullUser)
            
            return fullUser
        } catch {
            // Create new
            print("No profile found, creating new one")
            let newUser = User(
                id: basicUser.id,
                email: basicUser.email,
                createdAt: Date(),
                updatedAt: Date()
            )
            try await userService.createUserProfile(user: newUser)
            cache.saveUser(newUser)
            return newUser
        }
    }
    
    func register(email: String, password: String, name: String) async throws -> User {
        // Register with Firebase Auth
        let basicUser = try await authService.register(email: email, password: password)
        
        // Create profile in Firestore
        let newUser = User(
            id: basicUser.id,
            email: basicUser.email,
            name: name,
            createdAt: Date(),
            updatedAt: Date()
        )
        try await userService.createUserProfile(user: newUser)
        
        // Cache into UserDefaults
        cache.saveUser(newUser)
        
        return newUser
    }
    
    func logout() throws {
        cache.clearCache()
        try authService.logout()
    }
    
    func currentUser() async -> User? {
        guard authService.hasActiveSession() else {
            cache.clearCache()
            return nil
        }
        
        // Try cache first (fast)
        if let cachedUser = cache.getCachedUser() {
            // Background sync from Firestore
            Task {
                await syncUserFromFirestore()
            }
            return cachedUser
        }
        
        // Fetch from Firestore if no cache
        guard let basicUser = authService.getCurrentUser() else {
            return nil
        }
        
        do {
            let user = try await userService.getUserProfile(userId: basicUser.id)
            cache.saveUser(user)
            return user
        } catch {
            print("Failed to fetch user profile: \(error)")
            return basicUser
        }
    }
    
    // Sync cache with Firestore (background)
    private func syncUserFromFirestore() async {
        guard let basicUser = authService.getCurrentUser() else { return }
        
        do {
            let freshUser = try await userService.getUserProfile(userId: basicUser.id)
            cache.saveUser(freshUser)
            print("User profile synced from Firestore")
        } catch {
            print("Failed to sync user profile: \(error)")
        }
    }
    
    // Update user profile: Firestore → Cache
    func updateUserProfile(fields: [String: Any]) async throws {
        guard let currentUser = cache.getCachedUser() else {
            throw NSError(domain: "NoUser", code: 401)
        }
        
        // 1. Update Firestore
        try await userService.updateUserProfile(userId: currentUser.id, fields: fields)
        
        // 2. Fetch updated profile
        let updatedUser = try await userService.getUserProfile(userId: currentUser.id)
        
        // 3. Update cache
        cache.saveUser(updatedUser)
    }
}
