import SwiftUI
import FirebaseAuth
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
    @State private var propertyOfferData = PropertyOfferData()
    @State private var isPublishing = false

    // Propiedad computada para obtener el usuario actual
    private var currentUser: User? {
        return Auth.auth().currentUser
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView {
                    // Aquí iría la vista del filtro de búsqueda si se habilita
                } else {
                    ScrollView {
                        VStack {
                            Heading()

                            // Botón para crear más ofertas
                            if !showNoConnectionBanner {
                                Button(action: {
                                    propertyOfferData.reset()
                                    propertyOfferData = PropertyOfferData() // Restablece los datos de la propiedad
                                    print("RESET PROPERTY DATA ON CREATE MORE CLICK")
                                }) {
                                    CreateMoreButton()
                                }
                            }

                            // Banner de conexión
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
                                    .transition(.opacity) // Transición simple para mejor rendimiento
                                    .padding(.horizontal, 40)
                            }

                            // Mensaje si no hay ofertas disponibles
                            if offerViewModel.offersWithProperties.isEmpty {
                                Text("No offers available")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                // Lista de ofertas
                                LazyVStack(spacing: 32) {
                                    ForEach(offerViewModel.offersWithProperties) { offerWithProperty in
                                        NavigationLink(value: offerWithProperty) {
                                            OfferRentView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                                .frame(height: 360)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        .onAppear {
                            initializeView()
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
                            handleNetworkStatusChange(isConnectedStatus: isConnectedStatus)
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

    // MARK: - Métodos

    private func refreshOffers() {
        guard let userEmail = currentUser?.email else { return }
        print("REFRESHING OFFERS FOR LANDLORD...")
        offerViewModel.fetchOffers(for: userEmail)
    }

    private func initializeView() {
        propertyOfferData = PropertyOfferData()
        guard let userEmail = currentUser?.email else { return }
        offerViewModel.fetchOffers(for: userEmail)
        checkAndPublishPendingProperty()
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

            // Asignar los datos de la propiedad pendiente
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

            // Publicar detalles de la propiedad
            propertyViewModel.savePropertyAsync(propertyOfferData: propertyOfferData) {
                propertyViewModel.uploadImages(for: propertyOfferData) { uploadSuccess in
                    if uploadSuccess {
                        propertyViewModel.updateFirestorePropertyPhotos(propertyOfferData: propertyOfferData, photoFileNames: propertyOfferData.photos)
                    }
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

    private func handleNetworkStatusChange(isConnectedStatus: Bool) {
        withAnimation {
            showNoConnectionBanner = !isConnectedStatus
            print("NETWORK CONNECTION STATUS CHANGED - CONNECTED: \(isConnectedStatus)")
        }
        isConnected = isConnectedStatus

        if isConnectedStatus && publishedOffline {
            checkAndPublishPendingProperty()
            refreshOffers()
        }
    }
}
