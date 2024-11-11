import Foundation
import FirebaseAuth
import FirebaseFirestore
import FirebaseStorage
import NotificationCenter

class PropertyViewModel: ObservableObject {
    @Published var properties: [PropertyModel] = []
    private var db = Firestore.firestore()
    private var storage = Storage.storage()
    
    func savePropertyAsync(propertyOfferData: PropertyOfferData, completion: @escaping () -> Void) {
        DispatchQueue.global(qos: .background).async {
            self.getNextPropertyID { propertyID in
                guard let propertyID = propertyID else {
                    completion()
                    return
                }

                propertyOfferData.propertyID = propertyID
                self.uploadImages(for: propertyOfferData) { success in
                    if success {
                        self.postProperty(propertyOfferData: propertyOfferData) { postSuccess in
                            if postSuccess {
                                self.postOffer(propertyOfferData: propertyOfferData) { offerSuccess in
                                    DispatchQueue.main.async {
                                        completion()
                                    }
                                }
                            } else {
                                DispatchQueue.main.async {
                                    completion()
                                }
                            }
                        }
                    } else {
                        DispatchQueue.main.async {
                            completion()
                        }
                    }
                }
            }
        }
    }

    func notifySaveCompletion() {
        NotificationCenter.default.post(name: .offerSaveCompleted, object: nil)
    }

    func getNextPropertyID(completion: @escaping (Int?) -> Void) {
        db.collection("properties").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener los documentos de la colección 'properties': \(error)")
                completion(nil)
                return
            }

            guard let documents = snapshot?.documents, let document = documents.first else {
                print("No se encontraron documentos en la colección 'properties'.")
                completion(nil)
                return
            }

            let documentID = document.documentID

            self.db.collection("properties").document(documentID).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error al obtener el documento con ID '\(documentID)': \(error)")
                    completion(nil)
                    return
                }

                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists, let propertiesData = documentSnapshot.data() else {
                    print("No se encontraron datos en el documento con ID '\(documentID)'.")
                    completion(nil)
                    return
                }

                var maxID = 0
                for key in propertiesData.keys {
                    if let id = Int(key) {
                        maxID = max(maxID, id)
                    }
                }

                let nextID = maxID + 1
                completion(nextID)
            }
        }
    }

    func getNextOfferID(completion: @escaping (Int?) -> Void) {
        db.collection("offers").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener los documentos de la colección 'offers': \(error)")
                completion(nil)
                return
            }

            guard let documents = snapshot?.documents, let document = documents.first else {
                print("No se encontraron documentos en la colección 'offers'.")
                completion(nil)
                return
            }

            let documentID = document.documentID

            self.db.collection("offers").document(documentID).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error al obtener el documento con ID '\(documentID)': \(error)")
                    completion(nil)
                    return
                }

                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists, let offersData = documentSnapshot.data() else {
                    print("No se encontraron datos en el documento con ID '\(documentID)'.")
                    completion(nil)
                    return
                }

                var maxID = 0
                for key in offersData.keys {
                    if let id = Int(key) {
                        maxID = max(maxID, id)
                    }
                }

                let nextID = maxID + 1
                completion(nextID)
            }
        }
    }

    func postProperty(propertyOfferData: PropertyOfferData, completion: @escaping (Bool) -> Void) {
        guard propertyOfferData.propertyID >= 0 else {
            print("Error: El ID de la propiedad no es válido.")
            completion(false)
            return
        }

        db.collection("properties").getDocuments { snapshot, error in
            if let error = error {
                print("Error al obtener las propiedades para hacer POST: \(error)")
                completion(false)
                return
            }

            guard let documents = snapshot?.documents, let document = documents.first else {
                print("No se encontró ningún documento en la colección 'properties'.")
                completion(false)
                return
            }

            let documentID = document.documentID

            let propertyData: [String: Any] = [
                "address": propertyOfferData.placeAddress,
                "complex_name": propertyOfferData.placeTitle,
                "description": propertyOfferData.placeDescription,
                "location": [],
                "minutes_from_campus": propertyOfferData.minutesFromCampus,
                "photos": propertyOfferData.photos,
                "title": propertyOfferData.placeTitle
            ]

            self.db.collection("properties").document(documentID).updateData([
                "\(propertyOfferData.propertyID)": propertyData
            ]) { error in
                if let error = error {
                    print("Error al hacer POST de la nueva propiedad: \(error)")
                    completion(false)
                } else {
                    print("Propiedad posteada con éxito en 'properties' con ID \(propertyOfferData.propertyID).")
                    completion(true)
                }
            }
        }
    }

    func postOffer(propertyOfferData: PropertyOfferData, completion: @escaping (Bool) -> Void) {
        guard propertyOfferData.propertyID >= 0 else {
            print("Error: El ID de la propiedad no es válido.")
            completion(false)
            return
        }

        getNextOfferID { nextOfferID in
            guard let offerID = nextOfferID, offerID >= 0 else {
                print("Error al obtener el siguiente ID de oferta.")
                completion(false)
                return
            }

            self.db.collection("offers").getDocuments { snapshot, error in
                if let error = error {
                    print("Error al obtener las ofertas para hacer POST: \(error)")
                    completion(false)
                    return
                }

                guard let documents = snapshot?.documents, let document = documents.first else {
                    print("No se encontró ningún documento en la colección 'offers'.")
                    completion(false)
                    return
                }

                let documentID = document.documentID

                let offerData: [String: Any] = [
                    "final_date": propertyOfferData.finalDate,
                    "id_property": propertyOfferData.propertyID,
                    "initial_date": propertyOfferData.initialDate,
                    "is_active": true,
                    "num_baths": propertyOfferData.numBaths,
                    "num_beds": propertyOfferData.numBeds,
                    "num_rooms": propertyOfferData.numRooms,
                    "only_andes": propertyOfferData.onlyAndes,
                    "price_per_month": propertyOfferData.pricePerMonth,
                    "roommates": propertyOfferData.roommates,
                    "type": propertyOfferData.type.rawValue,
                    "user_id": propertyOfferData.userId,
                    "views": 0
                ]

                self.db.collection("offers").document(documentID).updateData([
                    "\(offerID)": offerData
                ]) { error in
                    if let error = error {
                        print("Error al hacer POST de la oferta: \(error)")
                        completion(false)
                    } else {
                        print("Oferta posteada con éxito en 'offers' con ID \(offerID).")
                        completion(true)
                    }
                }
            }
        }
    }

    func assignAuthenticatedUser(to propertyOfferData: PropertyOfferData) {
        if let currentUser = Auth.auth().currentUser {
            propertyOfferData.userId = currentUser.email ?? ""
        } else {
            print("No se encontró un usuario autenticado.")
        }
    }
    
    private func updateFirestorePropertyPhotos(propertyOfferData: PropertyOfferData, photoFileNames: [String]) {
        let documentID = "\(propertyOfferData.propertyID)"
        let propertyRef = db.collection("properties").document(documentID)

        propertyRef.updateData(["photos": photoFileNames]) { error in
            if let error = error {
                print("Error al actualizar las fotos en Firestore: \(error)")
            } else {
                print("Fotos actualizadas con éxito en Firestore para la propiedad con ID \(documentID)")
            }
        }
    }

    func uploadImages(for propertyOfferData: PropertyOfferData, completion: @escaping (Bool) -> Void) {
        guard !propertyOfferData.userId.isEmpty, propertyOfferData.propertyID >= 0 else {
            print("Error: ID de usuario o ID de propiedad no están definidos.")
            completion(false)
            return
        }

        let storageRef = storage.reference().child("properties")
        let group = DispatchGroup()
        var uploadedFileNames: [String] = []

        // Obtener imágenes desde almacenamiento local para subirlas a Firebase Storage
        let localImages = ["imagen1", "imagen2"].compactMap { imageName -> Data? in
            propertyOfferData.loadImage(for: imageName)?.jpegData(compressionQuality: 0.8)
        }

        for (index, imageData) in localImages.enumerated() {
            let fileName = "\(propertyOfferData.userId)_\(propertyOfferData.propertyID)_\(index + 1).jpg"
            let imageRef = storageRef.child(fileName)

            group.enter()

            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error al subir la imagen \(fileName): \(error)")
                    group.leave()
                    return
                }

                // Guardar solo el nombre del archivo, no la URL
                uploadedFileNames.append(fileName)
                print("Imagen subida con éxito: \(fileName)")
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if uploadedFileNames.count == localImages.count {
                propertyOfferData.photos = uploadedFileNames
                self.updateFirestorePropertyPhotos(propertyOfferData: propertyOfferData, photoFileNames: uploadedFileNames)
                completion(true)
            } else {
                print("Error al subir algunas fotos.")
                completion(false)
            }
        }
    }
}

extension Notification.Name {
    static let offerSaveCompleted = Notification.Name("offerSaveCompleted")
}
