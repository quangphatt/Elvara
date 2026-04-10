//
//  Transaction.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation

struct Transaction: Identifiable, Codable {
    let id: UUID
    var title: String
    var amount: Double
    var type: TransactionType
    var categoryId: UUID
    var walletId: UUID
    var date: Date
    var status: TransactionStatus
    var note: String?
}

enum TransactionType: String, Codable {
    case income
    case expense
    case transfer
}

enum TransactionStatus: String, Codable {
    case pending
    case completed
    case failed
}
