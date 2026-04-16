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
        let docRef = try await db.collection("transactions").addDocument(data: transaction.dictionary)
        return docRef.documentID
    }

    func updateTransaction(_ transaction: Transaction) async throws {
        guard let id = transaction.id else { return }
        try await db.collection("transactions").document(id).updateData(transaction.dictionary)
    }

    func deleteTransaction(id: String) async throws {
        try await db.collection("transactions").document(id).delete()
    }
}
