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
    private let offerCache = NSCache<NSString, NSArray>()  // Usamos NSCache para cachear ofertas
    private let offerCacheKey = "cachedOffers" as NSString  // Clave para el cache
    
    init() {
        offerCache.countLimit = 10  // Limitar a un máximo de 10 elementos en el cache
    }
    
    /// Función para guardar ofertas en caché (máximo 10)
    func saveOffersToCache(_ offers: [OfferWithProperty]) {
        let offersArray = Array(offers.prefix(10))  // Limitar a un máximo de 10 ofertas
        offerCache.setObject(offersArray as NSArray, forKey: offerCacheKey)
        print("🔴Ofertas guardadas en caché correctamente: \(offersArray.count) ofertas.")  // Debug
    }
    
    // Función para obtener las ofertas desde el caché
    func loadOffersFromCache() -> [OfferWithProperty] {
        if let cachedOffers = offerCache.object(forKey: offerCacheKey) as? [OfferWithProperty] {
            return cachedOffers
        } else {
            print("🔴No hay ofertas guardadas en caché.")
        }
        return []
    }
    
    // Función para limpiar el caché (opcional)
    func clearCache() {
        offerCache.removeObject(forKey: offerCacheKey)
        print("🔴Cache de ofertas limpiado.")
    }
}
