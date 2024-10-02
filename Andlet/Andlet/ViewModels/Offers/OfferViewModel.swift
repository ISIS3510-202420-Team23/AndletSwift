import FirebaseFirestore
import FirebaseAuth
import SwiftUI



class OfferViewModel: ObservableObject {
    @Published var offersWithProperties: [OfferWithProperty] = []
    
    // Propiedades para almacenar los filtros seleccionados
   @Published var startDate: Date = Date()
   @Published var endDate: Date = Date().addingTimeInterval(24 * 60 * 60)
   @Published var minPrice: Double = 0
   @Published var maxPrice: Double = 10000000
   @Published var maxMinutesFromCampus: Double = 30

    private var db = Firestore.firestore()
    
    // Variable para rastrear si se aplicaron filtros
    var filtersApplied = false

    init() {
        // Verifica si los filtros se han aplicado y llama a la función adecuada.
        if filtersApplied {
            fetchOffersWithFilters()
        } else {
            fetchOffers()
        }
    }

    // Obtener ofertas y asegurarse de que tienen una propiedad asociada
    func fetchOffers() {
        db.collection("offers").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener las ofertas: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No se encontraron documentos en la colección 'offers'")
                return
            }

            var tempOffersWithProperties: [OfferWithProperty] = []
            let group = DispatchGroup() // Crear un DispatchGroup para gestionar la concurrencia

            // Iterar sobre los documentos en la colección "offers"
            for document in documents {
                let data = document.data()

                // Iterar sobre las claves dentro del documento de ofertas
                for (key, value) in data {
                    /*print("Clave: \(key), Valor: \(value)") */ // Imprimir cada clave y valor

                    if let offerData = value as? [String: Any] {
                        // Filtrar por is_active == true dentro de los campos anidados
                        if let isActive = offerData["is_active"] as? Bool, isActive == true {
                            // Extraer el id_property como Int y convertirlo a String si es necesario
                            if let idProperty = offerData["id_property"] as? Int {
                                let idPropertyString = "\(idProperty)"

                                // Mapeamos los datos de la oferta al modelo OfferModel
                                let offerId = "\(document.documentID)_\(key)"
                                let offer = self.mapOfferDataToModel(data: offerData, documentId: "E2amoJzmIbhtLq65ScpY", key: key)

                                // Añadir tarea al DispatchGroup
                                group.enter()

                                // Buscar la propiedad asociada
                                self.fetchPropertyForOffer(idProperty: idPropertyString) { property in
                                    if let property = property {
                                        let offerWithProperty = OfferWithProperty(
                                            id: offerId,
                                            offer: offer,
                                            property: property
                                        )
                                        tempOffersWithProperties.append(offerWithProperty)
                                    } else {
                                        print("Propiedad no encontrada para id_property \(idPropertyString).")
                                    }

                                    // Salir del DispatchGroup al finalizar la tarea
                                    group.leave()
                                }
                            } else {
//                                print("id_property no encontrado o no es un número en la oferta bajo la clave '\(key)'")
                            }
                        } else {
//                            print("La oferta bajo la clave '\(key)' no está activa y no se incluirá.")
                        }
                    } else {
//                        print("Los datos de la oferta bajo la clave '\(key)' no están en el formato esperado.")
                    }
                }
            }

            // Ejecutar la siguiente lógica cuando todas las tareas hayan terminado
            group.notify(queue: .main) {
                // Actualizar las ofertas en el hilo principal
                self.offersWithProperties = tempOffersWithProperties
                self.calculateEmptyDescriptionPercentage() // Calcular porcentaje una vez que se hayan cargado todas las ofertas
            }
        }
    }
    
    // Calcular el porcentaje de propiedades activas con descripción vacía
    func calculateEmptyDescriptionPercentage() {
        // Filtrar propiedades activas
        let activeProperties = offersWithProperties.map { $0.property }
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
        var tempOffersWithProperties: [OfferWithProperty] = []

        // Obtener todas las propiedades primero
        db.collection("properties").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener propiedades: \(error)")
                return
            }

            guard let documents = snapshot?.documents else {
                print("No se encontraron documentos en la colección 'properties'")
                return
            }

            // Mapeo de propiedades: [String: PropertyModel]
            var propertyMap: [String: PropertyModel] = [:]

            for document in documents {
                let propertyData = document.data()

                for (propertyKey, propertyValue) in propertyData {
                    if let propertyDetails = propertyValue as? [String: Any] {
                        let property = self.mapPropertyDataToModel(data: propertyDetails)
                        propertyMap[propertyKey] = property
                    }
                }
            }

            print("Mapa de propiedades completo: \(propertyMap)")

            // Obtener todas las ofertas y asociarlas con sus propiedades
            self.db.collection("offers").getDocuments { snapshot, error in
                if let error = error {
                    print("Error al obtener las ofertas: \(error)")
                    return
                }

                guard let documents = snapshot?.documents else {
                    print("No se encontraron documentos en la colección 'offers'")
                    return
                }

                for document in documents {
                    let offerData = document.data()

                    // Iterar sobre las ofertas dentro del documento
                    for (offerKey, offerValue) in offerData {
                        if let offerDetails = offerValue as? [String: Any],
                           let isActive = offerDetails["is_active"] as? Bool, isActive {

                            // Convertir id_property a String para asegurar coincidencia con propertyMap
                            let idPropertyString: String
                            if let idPropertyInt = offerDetails["id_property"] as? Int {
                                idPropertyString = "\(idPropertyInt)"
                            } else if let idProperty = offerDetails["id_property"] as? String {
                                idPropertyString = idProperty
                            } else {
                                print("Error: id_property no se pudo convertir a String.")
                                continue
                            }

                            // Verificar si se encuentra la propiedad en propertyMap
                            guard let property = propertyMap[idPropertyString] else {
                                print("No se encontró la propiedad con id \(idPropertyString) en el mapa de propiedades.")
                                continue
                            }

                            // Crear objeto OfferModel
                            let offer = self.mapOfferDataToModel(
                                data: offerDetails,
                                documentId: document.documentID,  // ID del documento actual
                                key: offerKey  // La clave actual de la oferta
                            )

                            let offerId = "\(document.documentID)_\(offerKey)"  // Generar ID único para la oferta

                            // Verificar condiciones de fechas y precios antes de agregar la oferta a la lista
                            guard let initialDate = offerDetails["initial_date"] as? Timestamp,
                                  let finalDate = offerDetails["final_date"] as? Timestamp,
                                  let pricePerMonth = offerDetails["price_per_month"] as? Double else {
                                print("Datos faltantes o en formato incorrecto para la oferta con clave \(offerKey).")
                                continue
                            }

                            // Convertir las fechas de Timestamp a Date y luego normalizarlas a año, mes y día
                            let propertyStartDate = self.normalizeDate(initialDate.dateValue())
                            let propertyEndDate = self.normalizeDate(finalDate.dateValue())
                            let userStartDate = self.normalizeDate(self.startDate)
                            let userEndDate = self.normalizeDate(self.endDate)

                            // Condición para verificar que el rango de fechas del usuario esté dentro del rango de fechas de la propiedad
                            if userStartDate >= propertyStartDate && userEndDate <= propertyEndDate &&
                                pricePerMonth >= self.minPrice && pricePerMonth <= self.maxPrice {

                                // Crear OfferWithProperty solo si cumple con las condiciones de filtro
                                let offerWithProperty = OfferWithProperty(
                                    id: offerId,
                                    offer: offer,
                                    property: property
                                )

                                tempOffersWithProperties.append(offerWithProperty)
                            } else {
                                print("La oferta con clave \(offerKey) no cumple con los filtros de fechas o precio.")
                            }
                        } else {
                            print("Error al crear OfferWithProperty para la oferta con clave \(offerKey).")
                        }
                    }
                }

                // Filtrar por minutos desde el campus
                let filteredOffers = tempOffersWithProperties.filter { offerWithProperty in
                    let property = offerWithProperty.property
                    return property.minutes_from_campus <= Int(self.maxMinutesFromCampus)
                }

                // Actualizar las ofertas con los filtros aplicados
                DispatchQueue.main.async {
                    self.offersWithProperties = filteredOffers
                }
            }
        }
    }

    // Función para normalizar una fecha a año, mes y día
    private func normalizeDate(_ date: Date) -> Date {
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day], from: date)
        return calendar.date(from: components) ?? date
    }
    
    // Función para actualizar los filtros en OfferViewModel
        func updateFilters(startDate: Date, endDate: Date, minPrice: Double, maxPrice: Double, maxMinutes: Double) {
            self.startDate = startDate
            self.endDate = endDate
            self.minPrice = minPrice
            self.maxPrice = maxPrice
            self.maxMinutesFromCampus = maxMinutes
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
