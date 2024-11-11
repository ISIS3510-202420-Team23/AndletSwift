import Foundation
import SwiftUI

class PropertyOfferData: ObservableObject, CustomStringConvertible, Codable {
    // Datos capturados en Step 1
    @Published var placeTitle: String = ""
    @Published var placeDescription: String = ""
    @Published var placeAddress: String = ""
    @Published var photos: [String] = []  // Nombres de archivos de fotos
    @Published var selectedImagesData: [Data] = []  // Datos de las imágenes para almacenamiento local

    // Datos capturados en Step 2
    @Published var numBaths: Int = 1
    @Published var numBeds: Int = 1 {
        didSet {
            updateRoommates()
        }
    }
    @Published var numRooms: Int = 1
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

    // MARK: - CustomStringConvertible
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
        roommates = numBeds - 1
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

    // Método para reiniciar todos los datos de la propiedad
    func reset() {
        placeTitle = ""
        placeDescription = ""
        placeAddress = ""
        photos = []
        selectedImagesData = []
        numBaths = 1
        numBeds = 1
        numRooms = 1
        pricePerMonth = 0.0
        type = .aRoom
        onlyAndes = false
        initialDate = Date()
        finalDate = Calendar.current.date(byAdding: .day, value: 7, to: Date()) ?? Date()
        minutesFromCampus = 0
        userId = ""
        userName = ""
        userEmail = ""
        propertyID = 0
        updateRoommates()
    }

    // MARK: - JSON Handling
    func saveToJSON() {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .prettyPrinted
        do {
            let data = try encoder.encode(self)
            let url = getJSONFileURL()
            try data.write(to: url)
            print("Propiedad guardada en JSON: \(url)")
        } catch {
            print("Error al guardar la propiedad en JSON: \(error)")
        }
    }

    func loadFromJSON() -> PropertyOfferData? {
        let decoder = JSONDecoder()
        let url = getJSONFileURL()
        do {
            let data = try Data(contentsOf: url)
            let propertyOfferData = try decoder.decode(PropertyOfferData.self, from: data)
            print("Propiedad cargada desde JSON: \(url)")
            return propertyOfferData
        } catch {
            print("Error al cargar la propiedad desde JSON: \(error)")
            return nil
        }
    }

    private func getJSONFileURL() -> URL {
        let fileManager = FileManager.default
        let directory = fileManager.urls(for: .documentDirectory, in: .userDomainMask).first!
        return directory.appendingPathComponent("pending_property.json")
    }
    
    func resetJSON() {
        let url = getJSONFileURL()
        do {
            try FileManager.default.removeItem(at: url)
            print("JSON reiniciado correctamente.")
        } catch {
            print("Error al reiniciar el JSON: \(error)")
        }
    }


    // MARK: - Codable Compliance
    private enum CodingKeys: String, CodingKey {
        case placeTitle, placeDescription, placeAddress, photos, selectedImagesData, numBaths, numBeds, numRooms, pricePerMonth, type, onlyAndes, initialDate, finalDate, minutesFromCampus, userId, userName, userEmail, propertyID, roommates
    }

    // Inicializador para Decodable
    required init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.placeTitle = try container.decode(String.self, forKey: .placeTitle)
        self.placeDescription = try container.decode(String.self, forKey: .placeDescription)
        self.placeAddress = try container.decode(String.self, forKey: .placeAddress)
        self.photos = try container.decode([String].self, forKey: .photos)
        self.selectedImagesData = try container.decode([Data].self, forKey: .selectedImagesData)
        self.numBaths = try container.decode(Int.self, forKey: .numBaths)
        self.numBeds = try container.decode(Int.self, forKey: .numBeds)
        self.numRooms = try container.decode(Int.self, forKey: .numRooms)
        self.pricePerMonth = try container.decode(Double.self, forKey: .pricePerMonth)
        self.type = OfferType(rawValue: try container.decode(String.self, forKey: .type)) ?? .aRoom
        self.onlyAndes = try container.decode(Bool.self, forKey: .onlyAndes)
        self.initialDate = try container.decode(Date.self, forKey: .initialDate)
        self.finalDate = try container.decode(Date.self, forKey: .finalDate)
        self.minutesFromCampus = try container.decode(Int.self, forKey: .minutesFromCampus)
        self.userId = try container.decode(String.self, forKey: .userId)
        self.userName = try container.decode(String.self, forKey: .userName)
        self.userEmail = try container.decode(String.self, forKey: .userEmail)
        self.propertyID = try container.decode(Int.self, forKey: .propertyID)
        self.roommates = try container.decode(Int.self, forKey: .roommates)
    }

    // Método de Codificación
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(placeTitle, forKey: .placeTitle)
        try container.encode(placeDescription, forKey: .placeDescription)
        try container.encode(placeAddress, forKey: .placeAddress)
        try container.encode(photos, forKey: .photos)
        try container.encode(selectedImagesData, forKey: .selectedImagesData)
        try container.encode(numBaths, forKey: .numBaths)
        try container.encode(numBeds, forKey: .numBeds)
        try container.encode(numRooms, forKey: .numRooms)
        try container.encode(pricePerMonth, forKey: .pricePerMonth)
        try container.encode(type.rawValue, forKey: .type)
        try container.encode(onlyAndes, forKey: .onlyAndes)
        try container.encode(initialDate, forKey: .initialDate)
        try container.encode(finalDate, forKey: .finalDate)
        try container.encode(minutesFromCampus, forKey: .minutesFromCampus)
        try container.encode(userId, forKey: .userId)
        try container.encode(userName, forKey: .userName)
        try container.encode(userEmail, forKey: .userEmail)
        try container.encode(propertyID, forKey: .propertyID)
        try container.encode(roommates, forKey: .roommates)
    }

    // Inicializador por defecto
    init() {}
}
