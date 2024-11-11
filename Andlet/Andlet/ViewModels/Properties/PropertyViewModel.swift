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
                
                // Verificar si hay una o dos imágenes y asignar los nombres correspondientes
                var photoNames: [String] = []
                if propertyOfferData.loadImage(for: "imagen1") != nil {
                    photoNames.append("\(propertyOfferData.userId)_\(propertyID)_1.jpg")
                }
                if propertyOfferData.loadImage(for: "imagen2") != nil {
                    photoNames.append("\(propertyOfferData.userId)_\(propertyID)_2.jpg")
                }
                propertyOfferData.photos = photoNames
                
                // Paso 1: Crear la propiedad en Firestore sin fotos
                self.postProperty(propertyOfferData: propertyOfferData) { postPropertySuccess in
                    if postPropertySuccess {
                        // Paso 2: Crear la oferta vinculada a esta propiedad
                        self.postOffer(propertyOfferData: propertyOfferData) { postOfferSuccess in
                            if postOfferSuccess {
                                DispatchQueue.main.async {
                                    completion() // Actualizar vista para mostrar detalles de propiedad y oferta
                                }
                                
                                // Paso 3: Subir las imágenes en segundo plano
                                self.uploadImages(for: propertyOfferData) { uploadSuccess in
                                    if uploadSuccess {
                                        print("Images uploaded successfully. Updating Firestore photos field.")
                                        self.updateFirestorePropertyPhotos(propertyOfferData: propertyOfferData, photoFileNames: propertyOfferData.photos)
                                    } else {
                                        print("Error uploading images.")
                                    }
                                }
                            } else {
                                print("Error creating offer in Firestore.")
                                DispatchQueue.main.async { completion() }
                            }
                        }
                    } else {
                        print("Error posting property to Firestore.")
                        DispatchQueue.main.async { completion() }
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
                print("Error fetching documents from 'properties': \(error)")
                completion(nil)
                return
            }

            guard let documents = snapshot?.documents, let document = documents.first else {
                print("No documents found in 'properties'.")
                completion(nil)
                return
            }

            let documentID = document.documentID

            self.db.collection("properties").document(documentID).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error fetching document with ID '\(documentID)': \(error)")
                    completion(nil)
                    return
                }

                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists, let propertiesData = documentSnapshot.data() else {
                    print("No data found in document with ID '\(documentID)'.")
                    completion(nil)
                    return
                }

                var maxID = 0
                for key in propertiesData.keys {
                    if let id = Int(key) {
                        maxID = max(maxID, id)
                    }
                }

                completion(maxID + 1)
            }
        }
    }

    func getNextOfferID(completion: @escaping (Int?) -> Void) {
        db.collection("offers").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching documents from 'offers': \(error)")
                completion(nil)
                return
            }

            guard let documents = snapshot?.documents, let document = documents.first else {
                print("No documents found in 'offers'.")
                completion(nil)
                return
            }

            let documentID = document.documentID

            self.db.collection("offers").document(documentID).getDocument { documentSnapshot, error in
                if let error = error {
                    print("Error fetching document with ID '\(documentID)': \(error)")
                    completion(nil)
                    return
                }

                guard let documentSnapshot = documentSnapshot, documentSnapshot.exists, let offersData = documentSnapshot.data() else {
                    print("No data found in document with ID '\(documentID)'.")
                    completion(nil)
                    return
                }

                var maxID = 0
                for key in offersData.keys {
                    if let id = Int(key) {
                        maxID = max(maxID, id)
                    }
                }

                completion(maxID + 1)
            }
        }
    }

    func postProperty(propertyOfferData: PropertyOfferData, completion: @escaping (Bool) -> Void) {
        guard propertyOfferData.propertyID >= 0 else {
            print("Error: Invalid property ID.")
            completion(false)
            return
        }

        db.collection("properties").getDocuments { snapshot, error in
            if let error = error {
                print("Error fetching properties for POST: \(error)")
                completion(false)
                return
            }

            guard let documents = snapshot?.documents, let document = documents.first else {
                print("No documents found in 'properties'.")
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
                "photos": propertyOfferData.photos, // Inicializar con los nombres
                "title": propertyOfferData.placeTitle
            ]

            self.db.collection("properties").document(documentID).updateData([
                "\(propertyOfferData.propertyID)": propertyData
            ]) { error in
                if let error = error {
                    print("Error posting new property: \(error)")
                    completion(false)
                } else {
                    print("Property posted successfully in 'properties' with ID \(propertyOfferData.propertyID).")
                    completion(true)
                }
            }
        }
    }

    func postOffer(propertyOfferData: PropertyOfferData, completion: @escaping (Bool) -> Void) {
        guard propertyOfferData.propertyID >= 0 else {
            print("Error: Invalid property ID.")
            completion(false)
            return
        }

        getNextOfferID { nextOfferID in
            guard let offerID = nextOfferID, offerID >= 0 else {
                print("Error fetching next offer ID.")
                completion(false)
                return
            }

            self.db.collection("offers").getDocuments { snapshot, error in
                if let error = error {
                    print("Error fetching offers for POST: \(error)")
                    completion(false)
                    return
                }

                guard let documents = snapshot?.documents, let document = documents.first else {
                    print("No documents found in 'offers'.")
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
                        print("Error posting offer: \(error)")
                        completion(false)
                    } else {
                        print("Offer posted successfully in 'offers' with ID \(offerID).")
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
            print("No authenticated user found.")
        }
    }

    func updateFirestorePropertyPhotos(propertyOfferData: PropertyOfferData, photoFileNames: [String]) {
        let documentID = "\(propertyOfferData.propertyID)"
        let propertyRef = db.collection("properties").document(documentID)

        propertyRef.updateData(["photos": photoFileNames]) { error in
            if let error = error {
                print("Error updating photos in Firestore: \(error)")
            } else {
                print("Photos updated successfully in Firestore for property ID \(documentID)")
            }
        }
    }

    func uploadImages(for propertyOfferData: PropertyOfferData, completion: @escaping (Bool) -> Void) {
        guard !propertyOfferData.userId.isEmpty, propertyOfferData.propertyID >= 0 else {
            print("Error: User ID or Property ID not defined.")
            completion(false)
            return
        }

        let storageRef = storage.reference().child("properties")
        let group = DispatchGroup()
        var uploadedFileNames: [String] = []

        let localImages = ["imagen1", "imagen2"].compactMap { imageName -> Data? in
            propertyOfferData.loadImage(for: imageName)?.jpegData(compressionQuality: 0.8)
        }

        for (index, imageData) in localImages.enumerated() {
            let fileName = "\(propertyOfferData.userId)_\(propertyOfferData.propertyID)_\(index + 1).jpg"
            let imageRef = storageRef.child(fileName)

            group.enter()

            imageRef.putData(imageData, metadata: nil) { metadata, error in
                if let error = error {
                    print("Error uploading image \(fileName): \(error)")
                    group.leave()
                    return
                }

                uploadedFileNames.append(fileName)
                print("Image uploaded successfully: \(fileName)")
                group.leave()
            }
        }

        group.notify(queue: .main) {
            if uploadedFileNames.count == localImages.count {
                propertyOfferData.photos = uploadedFileNames
                self.updateFirestorePropertyPhotos(propertyOfferData: propertyOfferData, photoFileNames: uploadedFileNames)
                completion(true)
            } else {
                print("Error uploading some images.")
                completion(false)
            }
        }
    }
}

extension Notification.Name {
    static let offerSaveCompleted = Notification.Name("offerSaveCompleted")
}
