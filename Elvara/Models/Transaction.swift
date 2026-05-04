//
//  Transaction.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation
import FirebaseFirestore

struct Transaction: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var userId: String?
    var title: String
    var amount: Double
    var type: TransactionType
    var walletId: String
    var toWalletId: String?
    var categoryId: String?
    var date: Date
    var status: TransactionStatus
    var note: String?
    var createdAt: Date?
    var updatedAt: Date?
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "title": title,
            "amount": amount,
            "type": type.rawValue,
            "walletId": walletId,
            "date": date,
            "status": status.rawValue
        ]
        if let userId = userId { dict["userId"] = userId }
        if let toWalletId = toWalletId { dict["toWalletId"] = toWalletId }
        if let categoryId = categoryId { dict["categoryId"] = categoryId }
        if let note = note, !note.isEmpty { dict["note"] = note }
        if let createdAt = createdAt { dict["createdAt"] = createdAt }
        dict["updatedAt"] = FieldValue.serverTimestamp()
        return dict
    }
}
enum TransactionType: String, Codable, CaseIterable {
    case income
    case expense
    case transfer
    var displayName: String {
        switch self {
        case .income: return "Income"
        case .expense: return "Expense"
        case .transfer: return "Transfer"
        }
    }
}
enum TransactionStatus: String, Codable, CaseIterable {
    case pending
    case completed
    case failed
}
