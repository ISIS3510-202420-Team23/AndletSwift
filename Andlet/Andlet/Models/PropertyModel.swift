//
//  PropertyModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 23/09/24.
//

import Foundation
import FirebaseFirestore

// Hacer que PropertyModel conforme a Hashable y Equatable
struct PropertyModel: Identifiable, Codable, Hashable, Equatable {
    var id: String
    let address: String
    let complexName: String
    let description: String
    let location: [Double]
    let minutes_from_campus: Int
    let photos: [String]
    let title: String

    // Implementamos la conformidad a Equatable (se puede generar automáticamente)
    static func == (lhs: PropertyModel, rhs: PropertyModel) -> Bool {
        return lhs.id == rhs.id &&
               lhs.address == rhs.address &&
               lhs.complexName == rhs.complexName &&
               lhs.description == rhs.description &&
               lhs.location == rhs.location &&
               lhs.minutes_from_campus == rhs.minutes_from_campus &&
               lhs.photos == rhs.photos &&
               lhs.title == rhs.title
    }

    // Implementamos la conformidad a Hashable
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
        hasher.combine(address)
        hasher.combine(complexName)
        hasher.combine(description)
        hasher.combine(location)
        hasher.combine(minutes_from_campus)
        hasher.combine(photos)
        hasher.combine(title)
    }
}
