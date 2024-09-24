//
//  PropertyModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 23/09/24.
//

import FirebaseDatabase
import Foundation

// MARK: - PropertyModel
struct PropertyModel: Identifiable {
    let id: String
    let address: String
    let complexName: String
    let description: String
    let location: String
    let title: String
    var photos: [String] // Array of photo URLs (from Firebase Storage)

    // Initialize from a Firebase Data Snapshot
    init?(snapshot: DataSnapshot) {
        guard
            let value = snapshot.value as? [String: Any],
            let address = value["address"] as? String,
            let complexName = value["complex_name"] as? String,
            let description = value["description"] as? String,
            let location = value["location"] as? String,
            let title = value["title"] as? String,
            let photos = value["photos"] as? [String] // Expecting photo URLs to be stored here
        else {
            return nil
        }

        self.id = snapshot.key // Firebase key
        self.address = address
        self.complexName = complexName
        self.description = description
        self.location = location
        self.title = title
        self.photos = photos
    }

    // Convert to dictionary to save in Firebase
    func toDictionary() -> [String: Any] {
        return [
            "address": address,
            "complex_name": complexName,
            "description": description,
            "location": location,
            "title": title,
            "photos": photos // URLs of the uploaded photos
        ]
    }
}

