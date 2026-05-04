//
//  TransactionManager.swift
//  Elvara
//
//  Created by Quang Phat on 16/4/26.
//

import Foundation

class TransactionManager {
    static let shared = TransactionManager()

    private let service = TransactionService()

    private init() {}

    func getTransactions(for userId: String, month: Date) async -> [Transaction] {
        do {
            return try await service.fetchTransactions(userId: userId, month: month)
        } catch {
            print("Failed to fetch transactions: \(error)")
            return []
        }
    }

    func createTransaction(_ transaction: Transaction) async throws -> String {
        try await service.createTransaction(transaction)
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        try await service.updateTransaction(transaction)
    }

    func deleteTransaction(id: String) async throws {
        try await service.deleteTransaction(id: id)
    }
}
