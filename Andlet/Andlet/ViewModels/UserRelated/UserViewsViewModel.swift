//
//  UserViewsViewModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 28/09/24.
//


import FirebaseFirestore

class UserViewsViewModel: ObservableObject {
    private var db = Firestore.firestore()

    // Función para registrar vistas según el tipo de oferta (con roommates o sin roommates)
    func registerOfferView(userId: String, hasRoommates: Bool) {
        let userViewsRef = db.collection("user_views").document(userId)
        
        userViewsRef.getDocument { (document, error) in
            if let document = document, document.exists {
                // Si el documento ya existe, actualizamos los contadores
                if hasRoommates {
                    userViewsRef.updateData([
                        "roommates_views": FieldValue.increment(Int64(1))
                    ])
                } else {
                    userViewsRef.updateData([
                        "no_roommates_views": FieldValue.increment(Int64(1))
                    ])
                }
            } else {
                // Si el documento no existe, lo creamos con los contadores iniciales
                userViewsRef.setData([
                    "roommates_views": hasRoommates ? 1 : 0,
                    "no_roommates_views": hasRoommates ? 0 : 1
                ])
            }
        }
    }
}
