//
//  Transfer.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation

struct Transfer: Identifiable, Codable {
    let id: UUID
    var fromWalletId: UUID
    var toWalletId: UUID
    var amount: Double
    var date: Date
    var status: TransactionStatus
}
