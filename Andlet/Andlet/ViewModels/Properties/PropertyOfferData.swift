import Foundation
import SwiftUI

class PropertyOfferData: ObservableObject, CustomStringConvertible {
    // Datos capturados en Step 1
    @Published var placeTitle: String = ""
    @Published var placeDescription: String = ""
    @Published var placeAddress: String = ""
    @Published var photos: [String] = []
    @Published var selectedImagesData: [Data] = []

    // Datos capturados en Step 2
    @Published var numBaths: Int = 0
    @Published var numBeds: Int = 0 {
        didSet {
            updateRoommates()
        }
    }
    @Published var numRooms: Int = 0
    @Published var pricePerMonth: Double = 0.0
    @Published var type: OfferType = .aRoom

    // Datos capturados en Step 3
    @Published var onlyAndes: Bool = false
    @Published var initialDate: Date = Date()
    @Published var finalDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var minutesFromCampus: Int = 0

    // Datos adicionales
    @Published var userId: String = ""
    @Published var userName: String = ""
    @Published var userEmail: String = ""
    @Published var propertyID: Int = 0

    // Variable de roommates calculada con base en `numBeds`
    @Published var roommates: Int = 0

    // Implementación de CustomStringConvertible para detalles legibles
    var description: String {
        return """
        Property Details:
        - Title: \(placeTitle)
        - Description: \(placeDescription)
        - Address: \(placeAddress)
        - Photos: \(photos.joined(separator: ", "))
        - Baths: \(numBaths)
        - Beds: \(numBeds)
        - Rooms: \(numRooms)
        - Price: \(pricePerMonth)
        - Type: \(type.rawValue)
        - Only Andes: \(onlyAndes)
        - Initial Date: \(initialDate)
        - Final Date: \(finalDate)
        - Minutes from Campus: \(minutesFromCampus)
        - User ID: \(userId)
        - Property ID: \(propertyID)
        """
    }

    // Método para actualizar el valor de `roommates` según el valor de `numBeds`
    private func updateRoommates() {
        if numBeds == 1 {
            roommates = 0
        } else {
            roommates = numBeds
        }
    }

    func offerDetails() -> String {
        return """
        Offer Details:
        - Initial Date: \(initialDate)
        - Final Date: \(finalDate)
        - Active: true
        - User ID: \(userId)
        - Price Per Month: \(pricePerMonth)
        - Property ID: \(propertyID)
        - Only Andes: \(onlyAndes)
        - Roommates: \(roommates)
        """
    }
}
