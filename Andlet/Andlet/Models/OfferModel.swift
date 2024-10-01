//
//  OfferModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 23/09/24.
//

import Foundation
import FirebaseFirestore

// Enum to restrict the type to "entire_place" or "shared_place"
enum OfferType: String, Codable, Hashable, Equatable  {
    case entirePlace = "entire_place"
    case aRoom = "a_room"
}

struct OfferModel: Identifiable, Codable, Hashable, Equatable {
    var id: String
    let finalDate: Date
    let idProperty: String
    let initialDate: Date
    let isActive: Bool
    let numBaths: Int
    let numBeds: Int
    let numRooms: Int
    let onlyAndes: Bool
    let pricePerMonth: Double
    let roommates: Int
    let type: OfferType
    let userId: String
    let views: Int
    
    

    // A convenience initializer to manually create an OfferModel
    init(id: String, finalDate: Date, idProperty: String, initialDate: Date, isActive: Bool, numBaths: Int, numBeds: Int, numRooms: Int, onlyAndes: Bool, pricePerMonth: Double, roommates: Int, type: OfferType, userId: String, views: Int) {
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
        self.views = views
    }
    
    // Implementamos Equatable (opcional, pero se genera automáticamente si todos los campos son Hashable y Equatable)
        static func == (lhs: OfferModel, rhs: OfferModel) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.finalDate == rhs.finalDate &&
                   lhs.idProperty == rhs.idProperty &&
                   lhs.initialDate == rhs.initialDate &&
                   lhs.isActive == rhs.isActive &&
                   lhs.numBaths == rhs.numBaths &&
                   lhs.numBeds == rhs.numBeds &&
                   lhs.numRooms == rhs.numRooms &&
                   lhs.onlyAndes == rhs.onlyAndes &&
                   lhs.pricePerMonth == rhs.pricePerMonth &&
                   lhs.roommates == rhs.roommates &&
                   lhs.type == rhs.type &&
                   lhs.userId == rhs.userId &&
                   lhs.views == rhs.views
        }
}
