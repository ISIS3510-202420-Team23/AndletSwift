//
//  PropertyModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 23/09/24.
//

import Foundation
import FirebaseFirestore

struct PropertyModel: Identifiable, Codable {
    @DocumentID var id: String?  // Optional, document ID auto-handled by Firestore
    let address: String
    let complexName: String
    let description: String
    let location: [Double]  // Array to represent latitude and longitude coordinates
    let photos: [String]    // Array of image URLs as strings
    let title: String

    // A convenience initializer to manually create a PropertyModel
    init(id: String? = nil, address: String, complexName: String, description: String, location: [Double], photos: [String], title: String) {
        self.id = id
        self.address = address
        self.complexName = complexName
        self.description = description
        self.location = location
        self.photos = photos
        self.title = title
    }
}
