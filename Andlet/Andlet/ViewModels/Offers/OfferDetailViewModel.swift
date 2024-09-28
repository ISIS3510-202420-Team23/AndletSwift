import SwiftUI
import FirebaseFirestore

class OfferDetailViewModel: ObservableObject {
    @Published var user: UserModel = UserModel(
        id: "loading@example.com",
        favoriteOffers: [],
        isAndes: false,
        name: "Loading...",
        phone: "0000000000",
        typeUser: .landlord
    )  // Usuario inicial por defecto para evitar opcionales
    
    @Published var isLoading: Bool = false  // Para mostrar un indicador de carga

    private var db = Firestore.firestore()

    // Función para buscar al usuario basado en el correo (userId)
    func fetchUser(userEmail: String) {
        isLoading = true

        // Acceder al documento único 'users'
        db.collection("users").document("eBbttobInFQe6i9wLHSF").getDocument { document, error in
            if let error = error {
                print("Error al obtener el usuario: \(error)")
                self.isLoading = false
                return
            }

            guard let document = document, document.exists, let data = document.data() else {
                print("El documento de usuario no existe o los datos están mal formados.")
                self.isLoading = false
                return
            }

            // Buscamos el usuario usando el email (userId) como clave en el documento
            if let userData = data[userEmail] as? [String: Any] {
                let user = self.mapUserDataToModel(data: userData, userEmail: userEmail)
                DispatchQueue.main.async {
                    self.user = user  // Actualizamos el usuario con los datos reales
                    self.isLoading = false
                }
            } else {
                print("Usuario con email \(userEmail) no encontrado.")
                self.isLoading = false
            }
        }
    }

    // Función para mapear los datos de Firestore al modelo UserModel
    private func mapUserDataToModel(data: [String: Any], userEmail: String) -> UserModel {
        let isAndes = data["is_andes"] as? Bool ?? false
        let name = data["name"] as? String ?? "Unknown"
        let phone = data["phone"] as? String ?? "0000000000"
        let typeUserString = data["type_user"] as? String ?? "landlord"
        let typeUser = UserType(rawValue: typeUserString) ?? .landlord
        let favoriteOffers = data["favorite_offers"] as? [Int] ?? []

        return UserModel(
            id: userEmail,
            favoriteOffers: favoriteOffers,
            isAndes: isAndes,
            name: name,
            phone: phone,
            typeUser: typeUser
        )
    }
}
