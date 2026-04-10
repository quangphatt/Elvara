//
//  Wallet.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation

struct Wallet: Identifiable, Codable {
    let id: UUID
    var name: String
    var balance: Double
    var currency: String
    var type: WalletType
    var createdAt: Date
}

enum WalletType: String, Codable {
    case cash
    case bank
    case eWallet
}
