//
//  CategoryService.swift
//  Elvara
//
//  Created by Quang Phat on 10/4/26.
//

import FirebaseFirestore

class CategoryService {
    private let db = Firestore.firestore()
    
    // Fetch user's custom categories
    func fetchUserCategories(userId: String) async throws -> [Category] {
        let snapshot = try await db.collection("categories")
            .whereField("userId", isEqualTo: userId)
            .order(by: "order")
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Category.self)
        }
    }
    
    // Create custom category
    func createCategory(_ category: Category) async throws -> String {
        let docRef = try await db.collection("categories").addDocument(data: category.dictionary)
        return docRef.documentID
    }
    
    // Update category
    func updateCategory(_ category: Category) async throws {
        guard let id = category.id else { return }
        try await db.collection("categories").document(id).updateData(category.dictionary)
    }
    
    // Delete category
    func deleteCategory(id: String) async throws {
        try await db.collection("categories").document(id).delete()
    }
}
