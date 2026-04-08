//
//  User.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import Foundation

struct User: Identifiable, Codable {
    var id: String
    var email: String
    var name: String?
    var avatar: String?
    var phoneNumber: String?
    var createdAt: Date?
    var updatedAt: Date?
    
    // Convert to Firestore dictionary
    var dictionary: [String: Any] {
        var dict: [String: Any] = [
            "id": id,
            "email": email
        ]
        
        if let name = name { dict["name"] = name }
        if let avatar = avatar { dict["avatar"] = avatar }
        if let phoneNumber = phoneNumber { dict["phoneNumber"] = phoneNumber }
        if let createdAt = createdAt { dict["createdAt"] = createdAt }
        if let updatedAt = updatedAt { dict["updatedAt"] = updatedAt }
        
        return dict
    }
    
    // Init from Firestore data
    init(id: String, email: String, name: String? = nil, avatar: String? = nil, phoneNumber: String? = nil, createdAt: Date? = nil, updatedAt: Date? = nil) {
        self.id = id
        self.email = email
        self.name = name
        self.avatar = avatar
        self.phoneNumber = phoneNumber
        self.createdAt = createdAt
        self.updatedAt = updatedAt
    }
    
    init?(dictionary: [String: Any]) {
        guard let id = dictionary["id"] as? String,
              let email = dictionary["email"] as? String else {
            return nil
        }
        
        self.id = id
        self.email = email
        self.name = dictionary["name"] as? String
        self.avatar = dictionary["avatar"] as? String
        self.phoneNumber = dictionary["phoneNumber"] as? String
        self.createdAt = dictionary["createdAt"] as? Date
        self.updatedAt = dictionary["updatedAt"] as? Date
    }
}
