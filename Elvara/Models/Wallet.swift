//
//  Wallet.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Wallet: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var balance: Double
    var currency: String
    var userId: String?
    var type: WalletType
    var createdAt: Date?
    var updatedAt: Date?
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "balance": balance,
            "currency": currency,
            "type": type.rawValue
        ]
        
        if let userId = userId { dict["userId"] = userId }
        if let createdAt = createdAt { dict["createdAt"] = createdAt }
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        return dict
    }
}

enum WalletType: String, Codable {
    case cash
    case bank
    case eWallet
}
