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
    @ObservedObject var propertyOfferData: PropertyOfferData
    @State private var isPublishing = false // Cambiar a @State para hacerla mutable

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
                                    propertyOfferData.resetJSON() // Reiniciar JSON al crear una nueva propiedad
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
                            propertyOfferData.reset()
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

                            if isConnectedStatus && publishedOffline {
                                checkAndPublishPendingProperty()
                                refreshOffers()
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

            // Cargar los datos de la propiedad pendiente
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

            // Subir imágenes antes de publicar
            propertyViewModel.uploadImages(for: propertyOfferData) { success in
                if success {
                    // Una vez subidas las imágenes, publicar la propiedad
                    propertyViewModel.savePropertyAsync(propertyOfferData: propertyOfferData) {
                        propertyOfferData.resetJSON() // Reiniciar JSON tras publicar la propiedad
                        isPublishing = false // Resetear bandera de publicación
                        print("Pending property published successfully and JSON reset.")

                        // Refrescar ofertas en segundo plano después de publicar
                        DispatchQueue.main.async {
                            refreshOffers()
                        }
                    }
                } else {
                    print("Error uploading images")
                    isPublishing = false // Resetear bandera si falla la publicación
                }
            }
        } catch {
            print("No pending property to publish or error reading JSON: \(error)")
            isPublishing = false
        }
    }
}
