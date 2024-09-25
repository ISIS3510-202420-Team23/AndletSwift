//
//  OfferModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 23/09/24.
//

import Foundation
import FirebaseFirestore

// Enum to restrict the type to "entire_place" or "shared_place"
enum OfferType: String, Codable {
    case entirePlace = "entire_place"
    case sharedPlace = "shared_place"
}

struct OfferModel: Identifiable, Codable {
    @DocumentID var id: String?  // Optional, document ID auto-handled by Firestore
    let finalDate: Date
    let idProperty: Int
    let initialDate: Date
    let isActive: Bool
    let numBaths: Int
    let numBeds: Int
    let numRooms: Int
    let onlyAndes: Bool
    let pricePerMonth: Double
    let roommates: Int
    let type: OfferType  // Enforce restriction using the OfferType enum
    let userId: String

    // A convenience initializer to manually create an OfferModel
    init(id: String? = nil, finalDate: Date, idProperty: Int, initialDate: Date, isActive: Bool, numBaths: Int, numBeds: Int, numRooms: Int, onlyAndes: Bool, pricePerMonth: Double, roommates: Int, type: OfferType, userId: String) {
        self.id = id
        self.finalDate = finalDate
        self.idProperty = idProperty
        self.initialDate = initialDate
        self.isActive = isActive
        self.numBaths = numBaths
        self.numBeds = numBeds
        self.numRooms = numRooms
        self.onlyAndes = onlyAndes
        self.pricePerMonth = pricePerMonth
        self.roommates = roommates
        self.type = type  // Restriction enforced here
        self.userId = userId
    }
}
