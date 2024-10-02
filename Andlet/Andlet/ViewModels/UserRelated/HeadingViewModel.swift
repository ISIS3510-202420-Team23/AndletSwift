//
//  HeadingViewModel.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 1/10/24.
//

import FirebaseFirestore
import FirebaseAuth

class HeadingViewModel: ObservableObject {
    
    private let db = Firestore.firestore()

    // Función para obtener los datos del usuario desde Firestore
    func fetchUserData(completion: @escaping (String, URL?) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: No hay usuario logueado.")
            completion("Guest", nil)
            return
        }
        
        // Convertir el email para usarlo como clave (reemplazar puntos con guiones bajos)
        let userKey = userEmail.replacingOccurrences(of: ".", with: "_")
        
        // Acceder al documento de usuarios
        db.collection("users").document("eBbttobInFQe6i9wLHSF").getDocument { document, error in
            if let error = error {
                print("Error al obtener el usuario desde Firestore: \(error)")
                completion("Guest", nil)
                return
            }
            
            guard let document = document, document.exists, let data = document.data() else {
                print("Documento de usuario no encontrado.")
                completion("Guest", nil)
                return
            }
            
            // Extraemos los datos del usuario
            if let userData = data[userKey] as? [String: Any] {
                let name = userData["name"] as? String ?? "Guest"
                let photoString = userData["photo"] as? String
                let photoURL = URL(string: photoString ?? "")
                
                // Devolver el nombre y la URL de la foto
                completion(name, photoURL)
            } else {
                print("Usuario con key \(userKey) no encontrado.")
                completion("Guest", nil)
            }
        }
    }
}
