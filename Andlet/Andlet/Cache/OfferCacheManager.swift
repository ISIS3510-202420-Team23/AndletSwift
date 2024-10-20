//
//  OfferCacheManager.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 19/10/24.
//

import Foundation
import SwiftUI
import FirebaseStorage

class OfferCacheManager {
    static let shared = OfferCacheManager()
    
    // Cache para las ofertas
    private let offerCacheKey = "cachedOffers"
    
    // Función para guardar ofertas en caché (máximo 10)
    func saveOffersToCache(_ offers: [OfferWithProperty]) {
        let encoder = JSONEncoder()
        let offersArray = Array(offers.prefix(10))  // Convertir ArraySlice a Array
        if let encoded = try? encoder.encode(offersArray) {  // Guardar máximo 10 ofertas
            UserDefaults.standard.set(encoded, forKey: offerCacheKey)
            print("🔴Ofertas guardadas en caché correctamente: \(offersArray.count) ofertas.")  // Debug
        } else {
            print("🔴Error al guardar ofertas en caché.")
        }
    }
    
    // Función para obtener las ofertas desde el caché
    func loadOffersFromCache() -> [OfferWithProperty] {
        if let savedOffers = UserDefaults.standard.object(forKey: offerCacheKey) as? Data {
            let decoder = JSONDecoder()
            if let loadedOffers = try? decoder.decode([OfferWithProperty].self, from: savedOffers) {
                return loadedOffers
            } else {
                print("🔴Error al decodificar las ofertas del caché.")
            }
        } else {
            print("🔴No hay ofertas guardadas en caché.")
        }
        return []
    }
    
    // Función para limpiar el caché (opcional)
    func clearCache() {
        UserDefaults.standard.removeObject(forKey: offerCacheKey)
    }
}
