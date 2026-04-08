//
//  AuthRepository.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

class AuthRepository {
    private let service = AuthService()
    
    func login(email: String, password: String) async throws -> User {
        try await service.login(email: email, password: password)
    }
    
    func logout() throws {
        try service.logout()
    }
    
    func currentUser() -> User? {
        service.getCurrentUser()
    }
}
