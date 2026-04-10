//
//  Category.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation

struct Category: Identifiable, Codable {
    let id: UUID
    var name: String
    var icon: String
    var type: TransactionType
}
