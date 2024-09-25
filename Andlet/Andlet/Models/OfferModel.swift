//
//  OfferModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 23/09/24.
//

import FirebaseDatabase
import Foundation

// MARK: - OfferModel
struct OfferModel: Identifiable {
    let id: String
    let finalDate: String
    let idProperty: Int
    let initialDate: String
    let isActive: Bool
    let numBaths: Int
    let numBeds: Int
    let numRooms: Int
    let onlyAndes: Bool
    let pricePerMonth: Double
    let roommates: Int
    let type: String
    let userId: String

    // Initialize from a Firebase Data Snapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let finalDate = value["final_date"] as? String,
            let idProperty = value["id_property"] as? Int,
            let initialDate = value["initial_date"] as? String,
            let isActive = value["is_active"] as? Bool,
            let numBaths = value["num_baths"] as? Int,
            let numBeds = value["num_beds"] as? Int,
            let numRooms = value["num_rooms"] as? Int,
            let onlyAndes = value["only_andes"] as? Bool,
            let pricePerMonth = value["price_per_month"] as? Double,
            let roommates = value["roommates"] as? Int,
            let type = value["type"] as? String,
            let userId = value["user_id"] as? String
        else {
            return nil
        }

        self.id = snapshot.key // Firebase key
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
        self.type = type
        self.userId = userId
    }

    // Convert to dictionary to save in Firebase
    func toDictionary() -> [String: Any] {
        return [
            "final_date": finalDate,
            "id_property": idProperty,
            "initial_date": initialDate,
            "is_active": isActive,
            "num_baths": numBaths,
            "num_beds": numBeds,
            "num_rooms": numRooms,
            "only_andes": onlyAndes,
            "price_per_month": pricePerMonth,
            "roommates": roommates,
            "type": type,
            "user_id": userId
        ]
    }
}
