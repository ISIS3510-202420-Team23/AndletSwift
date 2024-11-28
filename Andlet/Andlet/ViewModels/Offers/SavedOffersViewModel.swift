//
//  SavedOffersViewModel.swift
//  Andlet
//
//  Created by Daniel Arango Cruz on 27/11/24.
//
import SwiftUI
import FirebaseFirestore
import FirebaseAuth

class SavedOffersViewModel: ObservableObject {
    @Published var savedOffers: [OfferWithProperty] = []
    @Published var isLoading = false
    
    // Instancia de FilterViewModel
   @ObservedObject var filterViewModel: FilterViewModel
    
    // Propiedades para almacenar los filtros seleccionados
   @Published var startDate: Date = Date()
   @Published var endDate: Date = Date().addingTimeInterval(24 * 60 * 60)
   @Published var minPrice: Double = 0
   @Published var maxPrice: Double = 10000000
   @Published var maxMinutesFromCampus: Double = 30

    private let db = Firestore.firestore()
    
    var filtersApplied = false
    
    init(filterViewModel: FilterViewModel) {
        self.filterViewModel = filterViewModel
        if filterViewModel.filtersApplied {
            fetchOffersWithFilters()
        }
        else {
            fetchSavedOffers()
        }
        
    }

    func fetchSavedOffers() {
        guard let userEmail = Auth.auth().currentUser?.email else { return }
        isLoading = true

        // Step 1: Fetch saved offer IDs from the user_saved collection
        db.collection("user_saved").document(userEmail).getDocument { document, error in
            if let error = error {
                print("Error fetching saved offers: \(error.localizedDescription)")
                self.isLoading = false
                return
            }

            guard let data = document?.data() as? [String: Any] else {
                print("No saved offers found for user \(userEmail).")
                self.isLoading = false
                return
            }

            let savedOfferIds = Array(data.keys)

            // Step 2: Fetch details for each saved offer in parallel
            self.fetchOffers(savedUserOffers: savedOfferIds)
        }
    }

    /// ---------------------------------------------------------
    func fetchOffers(savedUserOffers: [String]) {
        if NetworkMonitor.shared.isConnected {
            // Con conexión, cargamos desde la base de datos y actualizamos el caché
            db.collection("offers").getDocuments { snapshot, error in
                guard error == nil, let documents = snapshot?.documents else {
                    print("Error al obtener las ofertas: \(error?.localizedDescription ?? "desconocido")")
                    return
                }
                
                // Procesamos los documentos como en tu código original
                var tempOffersWithProperties: [OfferWithProperty] = []
                let group = DispatchGroup()
                
                for document in documents {
                    let data = document.data()
                    for (key, value) in data {
                        if let offerData = value as? [String: Any],
                           let isActive = offerData["is_active"] as? Bool, isActive{
                            if savedUserOffers.contains(key) {
                                let idPropertyString = "\(offerData["id_property"] as? Int ?? 0)"
                                let offerId = "\(document.documentID)_\(key)"
                                let offer = self.mapOfferDataToModel(data: offerData, documentId: document.documentID, key: key)
                                
                                group.enter()
                                
                                self.fetchPropertyForOffer(idProperty: idPropertyString) { property in
                                    if let property = property {
                                        let offerWithProperty = OfferWithProperty(id: offerId, offer: offer, property: property)
                                        tempOffersWithProperties.append(offerWithProperty)
                                    }
                                    group.leave()
                                }
                            }
                            
                        }
                    }
                }
                
                group.notify(queue: .main) {
                    self.savedOffers = tempOffersWithProperties
                    OfferCacheManager.shared.saveOffersToCache(tempOffersWithProperties)  // Cacheamos las ofertas principales
                }
            }
        } else {
            // Sin conexión, cargar siempre desde caché
            savedOffers = OfferCacheManager.shared.loadOffersFromCache()
        }
    }

    
    // Calcular el porcentaje de propiedades activas con descripción vacía
    func calculateEmptyDescriptionPercentage() {
        // Filtrar propiedades activas
        let activeProperties = savedOffers.map { $0.property }
        let totalActiveProperties = activeProperties.count

        // Contar propiedades activas con descripción vacía
        let emptyDescriptionCount = activeProperties.filter { $0.description == "" }.count

        // Calcular porcentaje
        let percentage = totalActiveProperties == 0 ? 0.0 : (Double(emptyDescriptionCount) / Double(totalActiveProperties)) * 100.0
        logPercentageToAnalytics(percentage: percentage, totalProperties: totalActiveProperties)
    }
    
    // Registrar el porcentaje en Firebase Analytics usando AnalyticsManager
    private func logPercentageToAnalytics(percentage: Double, totalProperties: Int) {
        guard let currentUser = Auth.auth().currentUser, let userEmail = currentUser.email else {
            print("Error: No se pudo obtener el email del usuario, el usuario no está autenticado.")
            return
        }

        AnalyticsManager.shared.setUserId(userId: userEmail)

        // Registrar el evento en Firebase Analytics usando AnalyticsManager
        AnalyticsManager.shared.logEvent(name: "empty_description_percentage", params: [
            "user_id": userEmail,
            "percentage_empty_descriptions": percentage,
            "total_active_properties": totalProperties
        ])

        print("Evento 'empty_description_percentage' registrado con éxito con el user_id: \(userEmail), el porcentaje: \(percentage) y total_properties: \(totalProperties)")
    }
    func fetchOffersWithFilters() {
        let startDate = filterViewModel.startDate
        let endDate = filterViewModel.endDate
        let minPrice = filterViewModel.minPrice
        let maxPrice = filterViewModel.maxPrice
        let maxMinutesFromCampus = filterViewModel.maxMinutes

        print("Fetching offers with filters:")
        print("Start Date:", startDate)
        print("End Date:", endDate)
        print("Min Price:", minPrice)
        print("Max Price:", maxPrice)
        print("Max Minutes from Campus:", maxMinutesFromCampus)

        guard let userEmail = Auth.auth().currentUser?.email else {
            print("User not logged in")
            return
        }

        var tempOffersWithProperties: [OfferWithProperty] = []

        if NetworkMonitor.shared.isConnected {
            // Step 1: Fetch saved offers for the user
            db.collection("user_saved").document(userEmail).getDocument { document, error in
                if let error = error {
                    print("Error fetching saved offers: \(error.localizedDescription)")
                    return
                }

                guard let savedData = document?.data() else {
                    print("No saved offers found for user \(userEmail).")
                    return
                }

                // Extract saved offer IDs
                let savedOfferIds = Array(savedData.keys)

                // Step 2: Fetch all properties
                self.db.collection("properties").getDocuments { snapshot, error in
                    if let error = error {
                        print("Error fetching properties: \(error.localizedDescription)")
                        return
                    }

                    guard let propertyDocs = snapshot?.documents else {
                        print("No properties found.")
                        return
                    }

                    // Map properties by ID for fast access
                    var propertyMap: [String: PropertyModel] = [:]
                    for propertyDoc in propertyDocs {
                        let propertyData = propertyDoc.data()
                        if let propertyDetails = propertyData as? [String: Any] {
                            let property = self.mapPropertyDataToModel(data: propertyDetails)
                            propertyMap[propertyDoc.documentID] = property
                        }
                    }

                    // Step 3: Fetch all offers
                    self.db.collection("offers").getDocuments { snapshot, error in
                        if let error = error {
                            print("Error fetching offers: \(error.localizedDescription)")
                            return
                        }

                        guard let offerDocs = snapshot?.documents else {
                            print("No offers found.")
                            return
                        }

                        for offerDoc in offerDocs {
                            let offerData = offerDoc.data()

                            // Iterate through offers inside the document
                            for (offerKey, offerValue) in offerData {
                                if let offerDetails = offerValue as? [String: Any],
                                   let isActive = offerDetails["is_active"] as? Bool, isActive {
                                    
                                    // Only process if the offer is saved by the user
                                    if savedOfferIds.contains(offerKey) {
                                        // Extract property ID
                                        let idPropertyString: String
                                        if let idPropertyInt = offerDetails["id_property"] as? Int {
                                            idPropertyString = "\(idPropertyInt)"
                                        } else if let idProperty = offerDetails["id_property"] as? String {
                                            idPropertyString = idProperty
                                        } else {
                                            print("Error: id_property could not be converted to String.")
                                            continue
                                        }

                                        // Check if the property exists in the property map
                                        guard let property = propertyMap[idPropertyString] else {
                                            print("No property found with id \(idPropertyString).")
                                            continue
                                        }

                                        // Map the offer data to an OfferModel
                                        let offer = self.mapOfferDataToModel(
                                            data: offerDetails,
                                            documentId: offerDoc.documentID,
                                            key: offerKey
                                        )
                                        let offerId = "\(offerDoc.documentID)_\(offerKey)"

                                        // Validate filters
                                        guard let initialDate = offerDetails["initial_date"] as? Timestamp,
                                              let finalDate = offerDetails["final_date"] as? Timestamp,
                                              let pricePerMonth = offerDetails["price_per_month"] as? Double else {
                                            print("Missing or invalid data for offer \(offerKey).")
                                            continue
                                        }

                                        let propertyStartDate = self.normalizeDate(initialDate.dateValue())
                                        let propertyEndDate = self.normalizeDate(finalDate.dateValue())
                                        let userStartDate = self.normalizeDate(startDate)
                                        let userEndDate = self.normalizeDate(endDate)

                                        // Apply date, price, and minutes-from-campus filters
                                        if userStartDate >= propertyStartDate &&
                                            userEndDate <= propertyEndDate &&
                                            pricePerMonth >= minPrice &&
                                            pricePerMonth <= maxPrice &&
                                            property.minutes_from_campus <= Int(maxMinutesFromCampus) {
                                            
                                            let offerWithProperty = OfferWithProperty(
                                                id: offerId,
                                                offer: offer,
                                                property: property
                                            )
                                            tempOffersWithProperties.append(offerWithProperty)
                                        }
                                    }
                                }
                            }
                        }

                        // Step 4: Update saved offers with filters applied
                        DispatchQueue.main.async {
                            self.savedOffers = tempOffersWithProperties
                        }
                    }
                }
            }
        } else {
            // Offline: Filter cached offers
            let cachedOffers = OfferCacheManager.shared.loadOffersFromCache()

            for offerWithProperty in cachedOffers {
                let offer = offerWithProperty.offer
                let property = offerWithProperty.property

                let propertyStartDate = normalizeDate(offer.initialDate)
                let propertyEndDate = normalizeDate(offer.finalDate)
                let userStartDate = normalizeDate(startDate)
                let userEndDate = normalizeDate(endDate)

                if userStartDate >= propertyStartDate &&
                    userEndDate <= propertyEndDate &&
                    offer.pricePerMonth >= minPrice &&
                    offer.pricePerMonth <= maxPrice &&
                    property.minutes_from_campus <= Int(maxMinutesFromCampus) {
                    
                    tempOffersWithProperties.append(offerWithProperty)
                }
            }

            DispatchQueue.main.async {
                self.savedOffers = tempOffersWithProperties
            }
        }
    }



    // Función para normalizar una fecha a año, mes y día
    private func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
    
    func updateFilters(startDate: Date, endDate: Date, minPrice: Double, maxPrice: Double, maxMinutes: Double) {
        self.filterViewModel.updateFilters(startDate: startDate, endDate: endDate, minPrice: minPrice, maxPrice: maxPrice, maxMinutes: maxMinutes)
        fetchOffersWithFilters()
    }


    // Obtener la propiedad asociada usando el id_property
    func fetchPropertyForOffer(idProperty: String, completion: @escaping (PropertyModel?) -> Void) {
        db.collection("properties").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener las propiedades: \(error)")
                completion(nil)
                return
            }

            guard let documents = snapshot?.documents else {
                print("No se encontraron documentos en la colección 'properties'")
                completion(nil)
                return
            }

            // Iteramos sobre el documento de propiedades
            for document in documents {
                let propertyData = document.data()

                // Buscamos la propiedad usando el id_property como clave
                if let propertyDetails = propertyData["\(idProperty)"] as? [String: Any] {
                    let property = self.mapPropertyDataToModel(data: propertyDetails)
                    completion(property)  // Llamamos al completion con la propiedad encontrada
                    return
                }
            }

            completion(nil)  // Si no se encuentra la propiedad, devolvemos nil
        }
    }
    
    func syncOfflineViews() {
            let offlineViews = UserDefaults.standard.offlineOfferViews
            for (offerId, viewCount) in offlineViews where viewCount > 0 {
                let documentId = "E2amoJzmIbhtLq65ScpY"
                if let offerKey = offerId.split(separator: "_").last.map(String.init) {
                    db.collection("offers").document(documentId).updateData([
                        "\(offerKey).views": FieldValue.increment(Int64(viewCount))
                    ]) { error in
                        if let error = error {
                            print("Error al sincronizar vistas para \(offerId): \(error.localizedDescription)")
                        } else {
                            print("Vistas sincronizadas para \(offerId): \(viewCount)")
                            // Reiniciar el contador local una vez sincronizado
                            UserDefaults.standard.resetOfflineViews(for: offerId)
                        }
                    }
                }
            }
        }

    // Función para mapear datos de la oferta al modelo OfferModel
    private func mapOfferDataToModel(data: [String: Any], documentId: String, key: String) -> OfferModel {
        let finalDate = (data["final_date"] as? Timestamp)?.dateValue() ?? Date()
        let initialDate = (data["initial_date"] as? Timestamp)?.dateValue() ?? Date()

        // Modificar la extracción de id_property para soportar tanto Int como String
        let idProperty: String
        if let idPropertyInt = data["id_property"] as? Int {
            idProperty = "\(idPropertyInt)"  // Convertir Int a String
        } else {
            idProperty = data["id_property"] as? String ?? ""  // Asignar el valor si es String o vacío si no se encuentra
        }
        let documentId = "E2amoJzmIbhtLq65ScpY"

        let id = "\(documentId)_\(key)"
        let isActive = data["is_active"] as? Bool ?? false
        let numBaths = data["num_baths"] as? Int ?? 0
        let numBeds = data["num_beds"] as? Int ?? 0
        let numRooms = data["num_rooms"] as? Int ?? 0
        let onlyAndes = data["only_andes"] as? Bool ?? false
        let pricePerMonth = data["price_per_month"] as? Double ?? 0.0
        let roommates = data["roommates"] as? Int ?? 0
        let typeString = data["type"] as? String ?? "a_room"
        let type = OfferType(rawValue: typeString) ?? .aRoom
        let userId = data["user_id"] as? String ?? ""
        let views = data["views"] as? Int ?? 0

        return OfferModel(
            id: id,
            finalDate: finalDate,
            idProperty: idProperty,  // Ahora este campo siempre tendrá un valor String válido
            initialDate: initialDate,
            isActive: isActive,
            numBaths: numBaths,
            numBeds: numBeds,
            numRooms: numRooms,
            onlyAndes: onlyAndes,
            pricePerMonth: pricePerMonth,
            roommates: roommates,
            type: type,
            userId: userId,
            views: views
        )
    }


    // Función para mapear datos de la propiedad al modelo PropertyModel
    private func mapPropertyDataToModel(data: [String: Any]) -> PropertyModel {
        let id = data["id"] as? String ?? ""
        let address = data["address"] as? String ?? "Dirección desconocida"
        let complexName = data["complex_name"] as? String ?? "Complejo desconocido"
        let description = data["description"] as? String ?? ""
        let location = data["location"] as? [Double] ?? [0.0, 0.0]
        let minutes_from_campus = data["minutes_from_campus"] as? Int ?? 0
        let photos = data["photos"] as? [String] ?? []
        let title = data["title"] as? String ?? "Sin título"

        return PropertyModel(
            id: id,
            address: address,
            complexName: complexName,
            description: description,
            location: location,
            minutes_from_campus: minutes_from_campus,
            photos: photos,
            title: title
        )
    }
}

