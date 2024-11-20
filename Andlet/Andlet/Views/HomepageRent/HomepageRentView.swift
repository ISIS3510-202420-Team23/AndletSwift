import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct HomepageRentView: View {
    @AppStorage("publishedOffline") private var publishedOffline = false
    @AppStorage("initialOfferCount") private var initialOfferCount = 0
    @State private var isConnected = false
    @State private var showSuccessNotification = false
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @State private var showNoConnectionBanner = false
    @StateObject private var offerViewModel = OfferRentViewModel()
    @StateObject private var propertyViewModel = PropertyViewModel()
    @StateObject private var shakeDetector = ShakeDetector()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var propertyOfferData = PropertyOfferData()  // Instancia inicial
    @State private var isPublishing = false

    let currentUser = Auth.auth().currentUser

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView {
                    // FilterSearchView(show: $showFilterSearchView)
                } else {
                    ScrollView {
                        VStack {
                            Heading()

                            if !showNoConnectionBanner {
                                Button(action: {
                                    propertyOfferData.reset()
                                    propertyOfferData = PropertyOfferData() // Nueva instancia para limpiar todos los campos
                                    propertyOfferData.reset()
                                    print("RESET PROPERTY DATA ON CREATE MORE CLICK")
                                }) {
                                    CreateMoreButton()
                                }
                            }

                            if showNoConnectionBanner {
                                Text("⚠️ No Internet Connection, you cannot create an offer or change an offer status if you are offline")
                                    .font(.system(size: 14, weight: .medium))
                                    .padding(.vertical, 10)
                                    .padding(.horizontal, 16)
                                    .background(Color.red.opacity(0.8))
                                    .foregroundColor(.white)
                                    .cornerRadius(8)
                                    .frame(maxWidth: .infinity)
                                    .multilineTextAlignment(.center)
                                    .transition(.move(edge: .top))
                                    .padding(.horizontal, 40)
                            }

                            if offerViewModel.offersWithProperties.isEmpty {
                                Text("No offers available")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                LazyVStack(spacing: 32) {
                                    ForEach(offerViewModel.offersWithProperties) { offerWithProperty in
                                        NavigationLink(value: offerWithProperty) {
                                            OfferRentView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                                .frame(height: 360)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        }
                                        .onAppear {
                                            print("OFERTA: \(offerWithProperty.offer)")
                                            print("PROPIEDAD: \(offerWithProperty.property)")
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        .onAppear {
                            propertyOfferData = PropertyOfferData() // Asegura que los datos estén frescos al cargar la vista
                            offerViewModel.fetchOffers(for: "\(currentUser?.email ?? "UNKNOWN")")
                            checkAndPublishPendingProperty()
                        }
                        .background(
                            ShakeHandlingControllerRepresentable(shakeDetector: shakeDetector)
                                .frame(width: 0, height: 0)
                        )
                        .alert(isPresented: $showConfirmationAlert) {
                            Alert(
                                title: Text("Shake Detected"),
                                message: Text("Do you want to refresh the offers?"),
                                primaryButton: .destructive(Text("Yes")) {
                                    refreshOffers()
                                },
                                secondaryButton: .cancel(Text("No"))
                            )
                        }
                        .onReceive(shakeDetector.$didShake) { didShake in
                            if didShake && networkMonitor.isConnected {
                                showConfirmationAlert = true
                                shakeDetector.resetShake()
                            }
                        }
                        .onReceive(networkMonitor.$isConnected) { isConnectedStatus in
                            withAnimation {
                                showNoConnectionBanner = !isConnectedStatus
                                print("NETWORK CONNECTION STATUS CHANGED - CONNECTED: \(isConnectedStatus)")
                            }
                            isConnected = isConnectedStatus

                            if isConnectedStatus {
                                logConnectionAction() // Registrar acción de conexión
                                if publishedOffline {
                                    checkAndPublishPendingProperty()
                                    refreshOffers()
                                }
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .offerSaveCompleted)) { _ in
                            refreshOffers()
                        }
                    }
                }
            }
            .overlay(
                VStack {
                    if showSuccessNotification {
                        Text("Your property has been published successfully")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(8)
                            .padding()
                            .onAppear {
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showSuccessNotification = false
                                    propertyOfferData.deleteLocalImages()
                                    propertyOfferData.clearDocumentsDirectory()
                                }
                            }
                    }
                }
                .animation(.easeInOut, value: showSuccessNotification)
            )
            .onChange(of: offerViewModel.offersWithProperties) { newOffers in
                if publishedOffline && isConnected && newOffers.count > initialOfferCount {
                    showSuccessNotification = true
                    initialOfferCount = newOffers.count
                    publishedOffline = false
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func refreshOffers() {
        print("REFRESHING OFFERS FOR LANDLORD...")
        offerViewModel.fetchOffers(for: "\(currentUser?.email ?? "UNKNOWN")")
    }
    
    private func logConnectionAction() {
        guard let currentUser = Auth.auth().currentUser, let userEmail = currentUser.email else {
            print("Error: No se pudo obtener el email del usuario, el usuario no está autenticado.")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        let documentID = "6_\(userEmail)_\(formattedDate)"

        let actionData: [String: Any] = [
            "action": "connected",
            "app": "swift",
            "date": Date(),
            "user_id": userEmail
        ]

        let db = Firestore.firestore()
        db.collection("user_actions").document(documentID).setData(actionData) { error in
            if let error = error {
                print("Error al registrar el evento 'connected' en Firestore: \(error.localizedDescription)")
            } else {
                print("Evento 'connected' registrado exitosamente en Firestore con ID: \(documentID)")
            }
        }
    }
    
    private func logLostConnectionAction() {
        guard let currentUser = Auth.auth().currentUser, let userEmail = currentUser.email else {
            print("Error: No se pudo obtener el email del usuario, el usuario no está autenticado.")
            return
        }

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        let documentID = "7_\(userEmail)_\(formattedDate)"

        let actionData: [String: Any] = [
            "action": "not_connected",
            "app": "swift",
            "date": Date(),
            "user_id": userEmail
        ]

        let db = Firestore.firestore()
        db.collection("user_actions").document(documentID).setData(actionData) { error in
            if let error = error {
                print("Error al registrar el evento 'connected' en Firestore: \(error.localizedDescription)")
            } else {
                print("Evento 'connected' registrado exitosamente en Firestore con ID: \(documentID)")
            }
        }
    }

    private func checkAndPublishPendingProperty() {
        guard !isPublishing else {
            print("Publicación ya en proceso. Evitando duplicación.")
            return
        }
        isPublishing = true

        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("pending_property.json")

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let pendingProperty = try decoder.decode(PropertyOfferData.self, from: data)
            print("Pending property found, attempting to publish...")

            // Load pending property data into PropertyOfferData
            propertyOfferData.placeTitle = pendingProperty.placeTitle
            propertyOfferData.placeDescription = pendingProperty.placeDescription
            propertyOfferData.placeAddress = pendingProperty.placeAddress
            propertyOfferData.photos = pendingProperty.photos
            propertyOfferData.numBaths = pendingProperty.numBaths
            propertyOfferData.numBeds = pendingProperty.numBeds
            propertyOfferData.numRooms = pendingProperty.numRooms
            propertyOfferData.pricePerMonth = pendingProperty.pricePerMonth
            propertyOfferData.type = pendingProperty.type
            propertyOfferData.onlyAndes = pendingProperty.onlyAndes
            propertyOfferData.initialDate = pendingProperty.initialDate
            propertyOfferData.finalDate = pendingProperty.finalDate
            propertyOfferData.minutesFromCampus = pendingProperty.minutesFromCampus
            propertyOfferData.userId = pendingProperty.userId
            propertyOfferData.userName = pendingProperty.userName
            propertyOfferData.userEmail = pendingProperty.userEmail
            propertyOfferData.propertyID = pendingProperty.propertyID
            propertyOfferData.roommates = pendingProperty.roommates

            print("Loaded pending property data into propertyOfferData.")
            
            // Step 1: Publish property details without images
            propertyViewModel.savePropertyAsync(propertyOfferData: propertyOfferData) {
                print("Property details published without images. Now uploading images in background.")
                
                // Step 2: Upload images in the background
                propertyViewModel.uploadImages(for: propertyOfferData) { uploadSuccess in
                    if uploadSuccess {
                        print("Images uploaded successfully. Updating Firestore photos field.")
                        propertyViewModel.updateFirestorePropertyPhotos(propertyOfferData: propertyOfferData, photoFileNames: propertyOfferData.photos)
                    } else {
                        print("Error uploading images.")
                    }
                    // Reset JSON and mark publishing as finished
                    propertyOfferData.resetJSON()
                    isPublishing = false
                    DispatchQueue.main.async {
                        refreshOffers()
                    }
                }
            }
        } catch {
            print("No pending property to publish or error reading JSON: \(error)")
            isPublishing = false
        }
    }
}
