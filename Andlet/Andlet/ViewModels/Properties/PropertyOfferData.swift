import Foundation
import SwiftUI

class PropertyOfferData: ObservableObject, CustomStringConvertible {
    // Datos capturados en Step 1
    @Published var placeTitle: String = ""
    @Published var placeDescription: String = ""
    @Published var placeAddress: String = ""
    @Published var photos: [String] = [] // Almacena URLs o identificadores de imágenes para el backend
    @Published var selectedImagesData: [Data] = [] // Almacena las imágenes como Data para persistencia

    // Datos capturados en Step 2
    @Published var numBaths: Int = 0
    @Published var numBeds: Int = 0
    @Published var numRooms: Int = 0
    @Published var pricePerMonth: Double = 0.0
    @Published var type: OfferType = .aRoom

    // Datos capturados en Step 3
    @Published var onlyAndes: Bool = false
    @Published var initialDate: Date = Date()
    @Published var finalDate: Date = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
    @Published var minutesFromCampus: Int = 0

    // Datos adicionales
    @Published var userId: String = "" // ID del usuario autenticado
    @Published var userName: String = "" // Nombre del usuario autenticado
    @Published var userEmail: String = "" // Email del usuario autenticado
    @Published var propertyID: Int = 0 // ID de la propiedad como Int

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
        """
    }
}
