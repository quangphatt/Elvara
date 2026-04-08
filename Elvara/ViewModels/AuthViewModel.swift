//
//  AuthViewModel.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation
import Combine

@MainActor
class AuthViewModel: ObservableObject {
    static let shared = AuthViewModel()
    
    @Published var isLoggedIn = false
    @Published var user: User?
    @Published var isLoading = false
    
    private let repo = AuthRepository()
    
    public init() { }
    
    func checkSession() {
        isLoading = true
        Task {
            self.user = await repo.currentUser()
            self.isLoggedIn = (user != nil)
            self.isLoading = false
        }
    }
    
    func login(email: String, password: String) async {
        isLoading = true
        do {
            let user = try await repo.login(email: email, password: password)
            self.user = user
            self.isLoggedIn = true
            print("Login successful: \(user.name ?? user.email)")
        } catch {
            print("Login failed: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func register(email: String, password: String, name: String) async {
        isLoading = true
        do {
            let user = try await repo.register(email: email, password: password, name: name)
            self.user = user
            self.isLoggedIn = true
            print("Registration successful: \(user.name ?? user.email)")
        } catch {
            print("Registration failed: \(error.localizedDescription)")
        }
        isLoading = false
    }
    
    func logout() {
        do {
            try repo.logout()
            self.user = nil
            self.isLoggedIn = false
            print("Logout successful")
        } catch {
            print("Logout failed: \(error.localizedDescription)")
        }
    }
    
    func updateProfile(name: String? = nil,  phoneNumber: String? = nil) async {
        isLoading = true
        var fields: [String: Any] = [:]
        
        if let name = name { fields["name"] = name }
        if let phoneNumber = phoneNumber { fields["phoneNumber"] = phoneNumber }
        
        do {
            try await repo.updateUserProfile(fields: fields)
            self.user = await repo.currentUser()
            print("Profile updated")
        } catch {
            print("Profile update failed: \(error.localizedDescription)")
        }
        isLoading = false
    }
}
