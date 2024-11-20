//
//  NotificationsViewModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 19/11/24.
//

import Foundation
import FirebaseFirestore
import Combine

class NotificationViewModel: ObservableObject {
    @Published var notifications: [NotificationModel] = []
    private var db = Firestore.firestore()
    private var timer: Timer?
    var cancellables = Set<AnyCancellable>()
    private let notificationsKey = "savedNotifications"

    
    /// Iniciar temporizador para evaluar y generar notificaciones automáticamente
    func startEvaluatingNotifications(for userId: String, interval: TimeInterval = 3600) {
        // Detener cualquier temporizador existente
        stopTimer()
        
        // Configurar un nuevo temporizador
        timer = Timer.scheduledTimer(withTimeInterval: interval, repeats: true) { [weak self] _ in
            self?.fetchNotifications(for: userId)
        }
    }
    
    /// Detener el temporizador cuando ya no sea necesario
    func stopTimer() {
        timer?.invalidate()
        timer = nil
    }
    
    /// Generar notificaciones de saves basadas en el rango de tiempo
    func fetchNotifications(for userId: String, timeInterval: TimeInterval = 604800) {
        db.collection("offers").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener las ofertas: \(error)")
                self.loadNotificationsFromLocal()
                return
            }
            
            guard let documents = snapshot?.documents else {
                print("No se encontraron documentos en 'offers'")
                self.loadNotificationsFromLocal()
                return
            }
            
            var userOffers: [OfferModel] = []
            
            for document in documents {
                let data = document.data()
                
            
                for (key, value) in data {
                    if let offerData = value as? [String: Any],
                       let offerUserId = offerData["user_id"] as? String, offerUserId == userId {
                        let offer = self.mapOfferDataToModel(key: key, data: offerData) // Usa el mismo mapeo que en OfferRentViewModel
                        userOffers.append(offer)
                    }
                }
            }
            
            self.fetchSaves(for: userOffers, timeInterval: timeInterval)
        }
    }
    
    
    /// Consultar los saves por cada publicación
    func fetchSaves(for offers: [OfferModel], timeInterval: TimeInterval) {
        let now = Date()
        var tempNotifications: [NotificationModel] = []

        for offer in offers {
            db.collection("property_saved_by").document(offer.id).getDocument { document, error in
                if let error = error {
                    print("Error al obtener los saves para la oferta \(offer.id): \(error)")
                    return
                }

                guard let document = document, document.exists, let data = document.data() else {
                    print("No se encontraron saves para la oferta \(offer.id)")
                    return
                }

                print("Saves para la oferta \(offer.id): \(data)")

                var savesCount = 0

                for (_, value) in data {
                    if let timestamp = value as? Timestamp {
                        let saveDate = timestamp.dateValue()
                        let timeDifference = now.timeIntervalSince(saveDate)
                        print("Save en \(saveDate) con diferencia de tiempo: \(timeDifference) segundos")

                        if timeDifference <= timeInterval {
                            savesCount += 1
                        }
                    }
                }

                if savesCount > 0 {
                    // Buscar la propiedad asociada
                    OfferRentViewModel().fetchPropertyForOffer(idProperty: offer.idProperty) { property in
                        if let property = property {
                            let imageKey = property.photos.first ?? "icon"
                            let notification = NotificationModel(
                                id: offer.id,
                                propertyTitle: property.title, // Usamos el título de la propiedad
                                savesCount: savesCount,
                                imageKey: imageKey
                            )
                            tempNotifications.append(notification)
                            print("Notificación generada: \(notification)")

                            // Actualizar las notificaciones en el hilo principal
                            DispatchQueue.main.async {
                                self.notifications = tempNotifications
                                self.saveNotificationsToLocal() 
                                print("Notificaciones actualizadas: \(self.notifications)")
                            }
                        } else {
                            print("Propiedad no encontrada para la oferta \(offer.id)")
                        }
                    }
                }
            }
        }
    }

    /// Mapeo de datos de Firestore al modelo `OfferModel`
    private func mapOfferDataToModel(key: String, data: [String: Any]) -> OfferModel {
        let finalDate = (data["final_date"] as? Timestamp)?.dateValue() ?? Date()
        let initialDate = (data["initial_date"] as? Timestamp)?.dateValue() ?? Date()
        let id = key // Usar el `key` proporcionado como ID de la oferta
        let idProperty = data["id_property"] as? String ?? ""
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
            idProperty: idProperty,
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
}


extension NotificationViewModel {
    
    /// Guardar notificaciones en UserDefaults
    func saveNotificationsToLocal() {
        do {
            let encoder = JSONEncoder()
            let data = try encoder.encode(notifications)
            UserDefaults.standard.set(data, forKey: notificationsKey)
            print("Notificaciones guardadas localmente.")
        } catch {
            print("Error al guardar notificaciones localmente: \(error)")
        }
    }
    
    /// Cargar notificaciones desde UserDefaults
    func loadNotificationsFromLocal() {
        guard let data = UserDefaults.standard.data(forKey: notificationsKey) else {
            print("No hay notificaciones guardadas localmente.")
            return
        }
        
        do {
            let decoder = JSONDecoder()
            notifications = try decoder.decode([NotificationModel].self, from: data)
            print("Notificaciones cargadas desde almacenamiento local: \(notifications)")
        } catch {
            print("Error al cargar notificaciones localmente: \(error)")
        }
    }
}
