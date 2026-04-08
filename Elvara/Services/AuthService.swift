//
//  AuthService.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import FirebaseAuth

class AuthService {
    func login(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().signIn(withEmail: email, password: password)
        let firebaseUser = result.user
            
        return User(id: firebaseUser.uid, email: firebaseUser.email ?? "")
    }
    
    func register(email: String, password: String) async throws -> User {
        let result = try await Auth.auth().createUser(withEmail: email, password: password)
        let firebaseUser = result.user
            
        return User(id: firebaseUser.uid, email: firebaseUser.email ?? "")
    }
    
    func logout() throws {
        try Auth.auth().signOut()
    }
    
    func getCurrentUser() -> User? {
        guard let firebaseUser = Auth.auth().currentUser else {
            return nil
        }
        return User(id: firebaseUser.uid, email: firebaseUser.email ?? "")
    }
    
    // Check if Firebase session exists
    func hasActiveSession() -> Bool {
        return Auth.auth().currentUser != nil
    }
}
