//
//  UserService.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import FirebaseFirestore

class UserService {
    private let db = Firestore.firestore()
    private let usersCollection = "users"
    
    // Store user profile into Firestore
    func saveUserProfile(_ user: User) async throws {
        var userData = user.dictionary
        userData["updatedAt"] = FieldValue.serverTimestamp()
        
        try await db.collection(usersCollection)
            .document(user.id)
            .setData(userData, merge: true)
        
        print("User profile saved to Firestore")
    }
    
    // Get user profile from Firestore
    func getUserProfile(userId: String) async throws -> User {
        let document = try await db.collection(usersCollection)
            .document(userId)
            .getDocument()
        
        guard let data = document.data() else {
            throw NSError(domain: "UserNotFound", code: 404, 
                         userInfo: [NSLocalizedDescriptionKey: "User profile not found"])
        }
        
        guard let user = User(dictionary: data) else {
            throw NSError(domain: "InvalidData", code: 400,
                         userInfo: [NSLocalizedDescriptionKey: "Invalid user data"])
        }
        
        print("User profile fetched from Firestore")
        return user
    }
    
    // Update specific fields
    func updateUserProfile(userId: String, fields: [String: Any]) async throws {
        var updateData = fields
        updateData["updatedAt"] = FieldValue.serverTimestamp()
        
        try await db.collection(usersCollection)
            .document(userId)
            .updateData(updateData)
        
        print("User profile updated in Firestore")
    }
    
    // Tạo profile mới cho user vừa register
    func createUserProfile(user: User) async throws {
        var userData = user.dictionary
        userData["createdAt"] = FieldValue.serverTimestamp()
        userData["updatedAt"] = FieldValue.serverTimestamp()
        
        try await db.collection(usersCollection)
            .document(user.id)
            .setData(userData)
        
        print("New user profile created in Firestore")
    }
}
