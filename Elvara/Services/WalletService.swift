//
//  WalletService.swift
//  Elvara
//
//  Created by Quang Phat on 13/4/26.
//

import FirebaseFirestore

class WalletService {
    private let db = Firestore.firestore()
    
    func fetchWallets(userId: String) async throws -> [Wallet] {
        let snapshot = try await db.collection("wallets")
            .whereField("userId", isEqualTo: userId)
            .order(by: "createdAt", descending: true)
            .getDocuments()
        
        return snapshot.documents.compactMap { doc in
            try? doc.data(as: Wallet.self)
        }
    }
    
    func createWallet(_ wallet: Wallet) async throws -> String {
        let docRef = try await db.collection("wallets").addDocument(data: wallet.dictionary)
        return docRef.documentID
    }
    
    func updateWallet(_ wallet: Wallet) async throws {
        guard let id = wallet.id else { return }
        try await db.collection("wallets").document(id).updateData(wallet.dictionary)
    }
    
    func deleteWallet(id: String) async throws {
        try await db.collection("wallets").document(id).delete()
    }
}
