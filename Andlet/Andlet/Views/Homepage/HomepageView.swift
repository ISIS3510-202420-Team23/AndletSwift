import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct HomepageView: View {
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @State private var showNoConnectionAlert = false  // Estado para mostrar la alerta de no conexión
    @StateObject private var offerViewModel = OfferViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()  // Monitoreo de red
    @State private var userRoommatePreference: Bool? = nil
    @StateObject private var filterViewModel = FilterViewModel(
        startDate: Date(),
        endDate: Date().addingTimeInterval(24 * 60 * 60),
        minPrice: 0,
        maxPrice: 10000000,
        maxMinutes: 30
    )
    @StateObject private var shakeDetector = ShakeDetector()
    @State private var selectedOffer: OfferWithProperty?  // Add a state to track selected offer
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView {
                    FilterSearchView(show: $showFilterSearchView, filterViewModel: filterViewModel, offerViewModel: offerViewModel)
                } else {
                    ScrollView {
                        VStack {
                            Spacer()
                            Heading()
                            SearchAndFilterBar()
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        showFilterSearchView.toggle()
                                    }
                                }

                            if offerViewModel.offersWithProperties.isEmpty {
                                Text("No offers available")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                LazyVStack(spacing: 32) {
                                    ForEach(sortedOffers()) { offerWithProperty in
                                        Button(action: {
                                            selectedOffer = offerWithProperty  // Set selected offer
                                        }) {
                                            OfferView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                                .frame(height: 330)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        }
                                    }
                                }
                                .padding()
                            }
                                
                        }
                        .safeAreaInset(edge: .bottom) {
                            Color.clear.frame(height: 80)
                        }
                        .onAppear {
                            fetchUserViewPreferences()
                            let cache = URLCache.shared
                            print("Cache actual: \(cache.currentMemoryUsage) bytes en memoria y \(cache.currentDiskUsage) bytes en disco.")
                        }
                        .background(
                            ShakeHandlingControllerRepresentable(shakeDetector: shakeDetector)
                                .frame(width: 0, height: 0)
                        )
                        .alert(isPresented: $showConfirmationAlert) {
                            Alert(
                                title: Text("Shake Detected"),
                                message: Text("Do you want to clear the filters / refresh the offers?🧹"),
                                primaryButton: .destructive(Text("Yes")) {
                                    refreshOffers()
                                },
                                secondaryButton: .cancel(Text("No"))
                            )
                        }
                        .onReceive(shakeDetector.$didShake) { didShake in
                            if didShake {
                                showConfirmationAlert = true
                                shakeDetector.resetShake()
                            }
                        }
                        .onReceive(networkMonitor.$isConnected) { isConnected in
                            if !isConnected {
                                showNoConnectionAlert = true  // Mostrar alerta si no hay conexión
                            }
                        }
                        .alert(isPresented: $showNoConnectionAlert) {
                            Alert(
                                title: Text("No Internet Connection"),
                                message: Text("Please check your internet connection."),
                                dismissButton: .default(Text("OK"))
                            )
                        }
                        .navigationDestination(isPresented: Binding(
                            get: { selectedOffer != nil },
                            set: { _ in selectedOffer = nil }
                        )) {
                            if let offerWithProperty = selectedOffer {
                                OfferDetailView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                    .navigationBarBackButtonHidden()
                            }
                        }
                    }
                }
            }
            .navigationBarBackButtonHidden(true)
        } else {
            Text("Versión de iOS no soportada")
        }
    }

    // Función para obtener la preferencia del usuario desde Firestore
    func fetchUserViewPreferences() {
        let db = Firestore.firestore()
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: No hay usuario logueado")
            return
        }

        let userViewsRef = db.collection("user_views").document(userEmail)
        userViewsRef.getDocument { document, error in
            if let document = document, document.exists {
                let roommateViews = document.data()?["roommates_views"] as? Int ?? 0
                let noRoommateViews = document.data()?["no_roommates_views"] as? Int ?? 0
                userRoommatePreference = roommateViews > noRoommateViews
            } else {
                print("No se encontró el documento de preferencias de usuario")
            }
        }
    }

    func sortedOffers() -> [OfferWithProperty] {
        guard let preference = userRoommatePreference else {
            return offerViewModel.offersWithProperties
        }

        return offerViewModel.offersWithProperties.sorted { first, second in
            let firstHasRoommates = first.offer.roommates > 0
            let secondHasRoommates = second.offer.roommates > 0

            if preference {
                return firstHasRoommates && !secondHasRoommates
            } else {
                return !firstHasRoommates && secondHasRoommates
            }
        }
    }

    func refreshOffers() {
        offerViewModel.fetchOffers()
    }
}
