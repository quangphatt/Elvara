//
//  Category.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation
import SwiftUI
import FirebaseFirestore

struct Category: Identifiable, Codable, Hashable {
    @DocumentID var id: String?
    var name: String
    var icon: String
    var type: TransactionType
    var color: String
    var order: Int
    var isDefault: Bool = true  // Default categories vs user-created
    var userId: String?  // nil for default, userId for custom
    var createdAt: Date?
    var updatedAt: Date?
    
    var colorValue: Color {
        Color(hex: color)
    }
    
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "name": name,
            "icon": icon,
            "type": type.rawValue,
            "color": color,
            "order": order,
            "isDefault": isDefault
        ]
        
        if let userId = userId { dict["userId"] = userId }
        if let createdAt = createdAt { dict["createdAt"] = createdAt }
        dict["updatedAt"] = FieldValue.serverTimestamp()
        
        return dict
    }
    
    // For local initialization
    init(id: String? = nil, name: String, icon: String, type: TransactionType,
         color: String, order: Int, isDefault: Bool = true, userId: String? = nil) {
        self.id = id
        self.name = name
        self.icon = icon
        self.type = type
        self.color = color
        self.order = order
        self.isDefault = isDefault
        self.userId = userId
    }
}
