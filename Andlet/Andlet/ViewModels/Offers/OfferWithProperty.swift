//
//  OfferWithProperty.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 26/09/24.
//

import FirebaseFirestore
import SwiftUI


// Definir una estructura para vincular oferta y propiedad
struct OfferWithProperty: Identifiable, Hashable, Equatable {
    let id: String  // ID compuesto de la oferta
    let offer: OfferModel
    let property: PropertyModel
    
    
    // Implementamos la conformidad a Equatable
        static func == (lhs: OfferWithProperty, rhs: OfferWithProperty) -> Bool {
            return lhs.id == rhs.id &&
                   lhs.offer == rhs.offer &&
                   lhs.property == rhs.property
        }

        // Implementamos la conformidad a Hashable
        func hash(into hasher: inout Hasher) {
            hasher.combine(id)
            hasher.combine(offer)
            hasher.combine(property)
        }
}
