//
//  TransactionService.swift
//  Elvara
//
//  Created by Quang Phat on 16/4/26.
//

import Foundation
import FirebaseFirestore

class TransactionService {
    private let db = Firestore.firestore()

    /// Per-wallet balance delta when a transaction is counted as settled (`completed` only).
    static func balanceDeltas(for transaction: Transaction) -> [String: Double] {
        guard transaction.status == .completed else { return [:] }
        var deltas: [String: Double] = [:]
        switch transaction.type {
        case .income:
            deltas[transaction.walletId, default: 0] += transaction.amount
        case .expense:
            deltas[transaction.walletId, default: 0] -= transaction.amount
        case .transfer:
            guard let toId = transaction.toWalletId, !toId.isEmpty else { return [:] }
            deltas[transaction.walletId, default: 0] -= transaction.amount
            deltas[toId, default: 0] += transaction.amount
        }
        return deltas
    }

    private static func netWalletIncrements(old: Transaction, new: Transaction) -> [String: Double] {
        let oldD = balanceDeltas(for: old)
        let newD = balanceDeltas(for: new)
        var keys = Set(oldD.keys)
        keys.formUnion(newD.keys)
        var result: [String: Double] = [:]
        for key in keys {
            let delta = (newD[key] ?? 0) - (oldD[key] ?? 0)
            if delta != 0 {
                result[key] = delta
            }
        }
        return result
    }

    private func applyWalletIncrements(_ increments: [String: Double], to batch: WriteBatch) {
        for (walletId, delta) in increments {
            let ref = db.collection("wallets").document(walletId)
            batch.updateData([
                "balance": FieldValue.increment(delta),
                "updatedAt": FieldValue.serverTimestamp()
            ], forDocument: ref)
        }
    }

    func fetchTransactions(userId: String, month: Date) async throws -> [Transaction] {
        let calendar = Calendar.current
        let monthStart = calendar.date(from: calendar.dateComponents([.year, .month], from: month))!
        let nextMonthStart = calendar.date(byAdding: .month, value: 1, to: monthStart)!

        let snapshot = try await db.collection("transactions")
            .whereField("userId", isEqualTo: userId)
            .whereField("date", isGreaterThanOrEqualTo: monthStart)
            .whereField("date", isLessThan: nextMonthStart)
            .order(by: "date", descending: true)
            .getDocuments()

        return snapshot.documents.compactMap { try? $0.data(as: Transaction.self) }
    }

    func createTransaction(_ transaction: Transaction) async throws -> String {
        let txRef = db.collection("transactions").document()
        let batch = db.batch()
        batch.setData(transaction.dictionary, forDocument: txRef)
        applyWalletIncrements(Self.balanceDeltas(for: transaction), to: batch)
        try await batch.commit()
        return txRef.documentID
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        guard let id = transaction.id else { return }
        let txRef = db.collection("transactions").document(id)
        let snapshot = try await txRef.getDocument()
        guard snapshot.exists else { return }
        guard let previous = try? snapshot.data(as: Transaction.self) else {
            throw ServiceError.existingTransactionUnreadable
        }

        let increments = Self.netWalletIncrements(old: previous, new: transaction)
        let batch = db.batch()
        batch.updateData(transaction.dictionary, forDocument: txRef)
        applyWalletIncrements(increments, to: batch)
        try await batch.commit()
    }

    func deleteTransaction(id: String) async throws {
        let txRef = db.collection("transactions").document(id)
        let snapshot = try await txRef.getDocument()
        guard snapshot.exists else { return }
        guard let existing = try? snapshot.data(as: Transaction.self) else {
            try await txRef.delete()
            return
        }
        let reversed = Self.balanceDeltas(for: existing).mapValues { -$0 }

        let batch = db.batch()
        batch.deleteDocument(txRef)
        applyWalletIncrements(reversed, to: batch)
        try await batch.commit()
    }

    private enum ServiceError: LocalizedError {
        case existingTransactionUnreadable

        var errorDescription: String? {
            switch self {
            case .existingTransactionUnreadable:
                return "Could not read the existing transaction to update wallet balances."
            }
        }
    }
}
