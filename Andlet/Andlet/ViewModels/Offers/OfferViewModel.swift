import FirebaseFirestore
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
        fetchOffers()
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

            // Iterar sobre los documentos en la colección "offers"
            for document in documents {
                let data = document.data()

                print("Documento de oferta completo: \(data)")

                // Iterar sobre las claves dentro del documento de ofertas
                for (key, value) in data {
                    print("Clave: \(key), Valor: \(value)")  // Imprimir cada clave y valor

                    if let offerData = value as? [String: Any] {
                        print("Datos de la oferta bajo la clave '\(key)': \(offerData)")

                        // Filtrar por is_active == true dentro de los campos anidados
                        if let isActive = offerData["is_active"] as? Bool, isActive == true {
                            // Extraer el id_property como Int y convertirlo a String si es necesario
                            if let idProperty = offerData["id_property"] as? Int {
                                let idPropertyString = "\(idProperty)"

                                // Mapeamos los datos de la oferta al modelo OfferModel
                                let offer = self.mapOfferDataToModel(data: offerData)
                                let offerId = "\(document.documentID)_\(key)"  // ID único para la oferta

                                // Buscar la propiedad asociada
                                self.fetchPropertyForOffer(idProperty: idPropertyString) { property in
                                    if let property = property {
                                        let offerWithProperty = OfferWithProperty(
                                            id: offerId,
                                            offer: offer,
                                            property: property
                                        )
                                        tempOffersWithProperties.append(offerWithProperty)

                                        // Actualizar las ofertas en el hilo principal
                                        DispatchQueue.main.async {
                                            self.offersWithProperties = tempOffersWithProperties
                                        }
                                    } else {
                                        print("Propiedad no encontrada para id_property \(idPropertyString).")
                                    }
                                }
                            } else {
                                print("id_property no encontrado o no es un número en la oferta bajo la clave '\(key)'")
                            }
                        } else {
                            print("La oferta bajo la clave '\(key)' no está activa y no se incluirá.")
                        }
                    } else {
                        print("Los datos de la oferta bajo la clave '\(key)' no están en el formato esperado.")
                    }
                }
            }
        }
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
                print("Datos del documento de propiedades: \(propertyData)")  // Verificar los datos de cada propiedad

                for (propertyKey, propertyValue) in propertyData {
                    if let propertyDetails = propertyValue as? [String: Any] {
                        let property = self.mapPropertyDataToModel(data: propertyDetails)
                        propertyMap[propertyKey] = property
                        print("Propiedad mapeada: \(propertyKey): \(property)")  // Verificar cada propiedad mapeada
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
                    print("Documento de oferta completo: \(offerData)")  // Imprimir todas las ofertas antes de mapear

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
                            let offer = self.mapOfferDataToModel(data: offerDetails)
                            let offerId = "\(document.documentID)_\(offerKey)"  // Generar ID único para la oferta

                            // Verificar condiciones de fechas y precios antes de agregar la oferta a la lista
                            guard let initialDate = offerDetails["initial_date"] as? Timestamp,
                                  let finalDate = offerDetails["final_date"] as? Timestamp,
                                  let pricePerMonth = offerDetails["price_per_month"] as? Double else {
                                print("Datos faltantes o en formato incorrecto para la oferta con clave \(offerKey).")
                                continue
                            }

                            // Filtrar por fechas y precio
                            if initialDate.dateValue() >= self.startDate &&
                                finalDate.dateValue() <= self.endDate &&
                                pricePerMonth >= self.minPrice &&
                                pricePerMonth <= self.maxPrice {

                                // Crear OfferWithProperty solo si cumple con las condiciones de filtro
                                let offerWithProperty = OfferWithProperty(
                                    id: offerId,
                                    offer: offer,
                                    property: property
                                )

                                print("OfferWithProperty creado: \(offerWithProperty)")  // Verificar cada OfferWithProperty creado
                                tempOffersWithProperties.append(offerWithProperty)
                            } else {
                                print("La oferta con clave \(offerKey) no cumple con los filtros de fechas o precio.")
                            }
                        } else {
                            print("Error al crear OfferWithProperty para la oferta con clave \(offerKey).")
                        }
                    }
                }

                // Imprimir todas las ofertas con propiedades antes de filtrar
                print("Todos los OfferWithProperty antes de filtrar por minutes_from_campus: \(tempOffersWithProperties)")

                // Filtrar por minutos desde el campus
                let filteredOffers = tempOffersWithProperties.filter { offerWithProperty in
                    let property = offerWithProperty.property
                    return property.minutes_from_campus <= Int(self.maxMinutesFromCampus)
                }

                // Imprimir ofertas filtradas por minutos desde el campus
                print("OfferWithProperty después de filtrar por minutes_from_campus (<= \(self.maxMinutesFromCampus)): \(filteredOffers)")

                // Actualizar las ofertas con los filtros aplicados
                DispatchQueue.main.async {
                    self.offersWithProperties = filteredOffers
                }
            }
        }
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
    private func mapOfferDataToModel(data: [String: Any]) -> OfferModel {
        let finalDate = (data["final_date"] as? Timestamp)?.dateValue() ?? Date()
        let initialDate = (data["initial_date"] as? Timestamp)?.dateValue() ?? Date()

        // Modificar la extracción de id_property para soportar tanto Int como String
        let idProperty: String
        if let idPropertyInt = data["id_property"] as? Int {
            idProperty = "\(idPropertyInt)"  // Convertir Int a String
        } else {
            idProperty = data["id_property"] as? String ?? ""  // Asignar el valor si es String o vacío si no se encuentra
        }

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
        let address = data["address"] as? String ?? "Dirección desconocida"
        let complexName = data["complex_name"] as? String ?? "Complejo desconocido"
        let description = data["description"] as? String ?? ""
        let location = data["location"] as? [Double] ?? [0.0, 0.0]
        let minutes_from_campus = data["minutes_from_campus"] as? Int ?? 0
        let photos = data["photos"] as? [String] ?? []
        let title = data["title"] as? String ?? "Sin título"

        return PropertyModel(
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
