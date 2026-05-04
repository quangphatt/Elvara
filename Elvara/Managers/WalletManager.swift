//
//  WalletManager.swift
//  Elvara
//
//  Created by Quang Phat on 13/4/26.
//

import Foundation

class WalletManager {
    static let shared = WalletManager()
    
    private let service = WalletService()
    
    private init() {}
    
    func getWallets(for userId: String) async -> [Wallet] {
        do {
            return try await service.fetchWallets(userId: userId)
        } catch {
            print("Failed to fetch wallets: \(error)")
            return []
        }
    }
    
    func getWallets(for userId: String, type: WalletType) async -> [Wallet] {
        let all = await getWallets(for: userId)
        return all.filter { $0.type == type }
    }
    
    func createWallet(_ wallet: Wallet) async throws -> String {
        try await service.createWallet(wallet)
    }
    
    func updateWallet(_ wallet: Wallet) async throws {
        try await service.updateWallet(wallet)
    }
    
    func deleteWallet(id: String) async throws {
        try await service.deleteWallet(id: id)
    }
}
