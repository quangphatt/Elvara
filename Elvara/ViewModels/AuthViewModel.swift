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
    
    private let repo = AuthRepository()
    
    public init() {
        
    }
    
    func checkSession() {
        if let user = repo.currentUser() {
            self.user = user
            self.isLoggedIn = true
        }
    }
    
    func login(email: String, password: String) async {
        do {
            let user = try await repo.login(email: email, password: password)
            self.user = user
            self.isLoggedIn = true
        } catch {
            print(error)
        }
    }
    
    func logout() {
        try? repo.logout()
        self.user = nil
        self.isLoggedIn = false
    }
}
