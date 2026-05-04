//
//  WalletViewModel.swift
//  Elvara
//
//  Created by Quang Phat on 13/4/26.
//

import Foundation
import Combine

@MainActor
class WalletViewModel: ObservableObject {
    @Published var wallets: [Wallet] = []
    @Published var isLoading = false
    @Published var errorMessage: String?

    private let manager = WalletManager.shared

    func loadWallets(for userId: String) async {
        isLoading = true
        errorMessage = nil

        wallets = await manager.getWallets(for: userId)

        isLoading = false
    }

    func createWallet(
        name: String,
        balance: Double,
        currency: String,
        type: WalletType,
        userId: String
    ) async {
        errorMessage = nil

        var wallet = Wallet(
            id: nil,
            name: name,
            balance: balance,
            currency: currency.uppercased(),
            userId: userId,
            type: type,
            createdAt: Date(),
            updatedAt: nil
        )

        do {
            let newId = try await manager.createWallet(wallet)
            wallet.id = newId
            wallets.insert(wallet, at: 0)
        } catch {
            errorMessage = "Failed to create wallet: \(error.localizedDescription)"
            print(errorMessage ?? "")
        }
    }

    func updateWallet(
        wallet: Wallet,
        name: String,
        balance: Double,
        currency: String,
        type: WalletType
    ) async {
        errorMessage = nil

        var updated = wallet
        updated.name = name
        updated.balance = balance
        updated.currency = currency.uppercased()
        updated.type = type

        do {
            try await manager.updateWallet(updated)
            if let idx = wallets.firstIndex(where: { $0.id == updated.id }) {
                wallets[idx] = updated
            }
        } catch {
            errorMessage = "Failed to update wallet: \(error.localizedDescription)"
            print(errorMessage ?? "")
        }
    }

    func deleteWallet(_ wallet: Wallet) async {
        guard let id = wallet.id else { return }
        errorMessage = nil

        do {
            try await manager.deleteWallet(id: id)
            wallets.removeAll { $0.id == id }
        } catch {
            errorMessage = "Failed to delete wallet: \(error.localizedDescription)"
            print(errorMessage ?? "")
        }
    }
}
