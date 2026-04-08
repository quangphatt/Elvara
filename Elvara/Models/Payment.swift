//
//  Payment.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation

struct Payment: Identifiable, Codable {
    let id: UUID
    var amount: Double
    var fromWalletId: UUID
    var to: String // merchant / receiver
    var method: PaymentMethod
    var status: TransactionStatus
    var createdAt: Date
}

enum PaymentMethod: String, Codable {
    case qr
    case bankTransfer
    case wallet
}
