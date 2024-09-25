//
//  UserModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 24/09/24.
//

import Foundation
import FirebaseFirestore

// Enum to restrict the type_user field to "landlord" or "student"
enum UserType: String, Codable {
    case landlord = "landlord"
    case student = "student"
}

struct UserModel: Codable, Identifiable {
    @DocumentID var id: String?  // Firestore will auto-handle document ID
    let email: String
    let favoriteOffers: [Int]?  // Optional list of favorite offer IDs (nullable)
    let isAndes: Bool
    let name: String
    let phone: String
    let typeUser: UserType  // Restrict type_user using the enum

    // Convenience initializer to create a UserModel manually
    init(id: String? = nil, email: String, favoriteOffers: [Int]? = nil, isAndes: Bool, name: String, phone: String, typeUser: UserType) {
        self.id = id
        self.email = email
        self.favoriteOffers = favoriteOffers
        self.isAndes = isAndes
        self.name = name
        self.phone = phone
        self.typeUser = typeUser
    }
}

