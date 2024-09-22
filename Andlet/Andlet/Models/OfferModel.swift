//
//  OfferModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 21/09/24.
//

import Foundation
//import FirebaseFirestore

struct OfferModel: Hashable, Codable, Identifiable {
    let id: String
    var inital_date: Date
    let id_property: String
    var final_Date: Date
    var is_active: Bool
    var num_baths: Int
    var num_beds: Int
    var num_rooms: Int
    var only_andes: Bool
    var price_per_month: Int
    var roommates: Int
    var type: OfferTypes
    var user_id: String
}

enum OfferTypes: String, Codable, Identifiable, Hashable {
    case entire_place = "entire_place"
    case own_place = "own_place"
    
    var id: String { return self.rawValue }
}
