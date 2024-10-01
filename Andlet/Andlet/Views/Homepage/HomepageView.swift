import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct HomepageView: View {
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @StateObject private var offerViewModel = OfferViewModel()
    @State private var userRoommatePreference: Bool? = nil  // true = prefiere roommates, false = no roommates
    @StateObject private var filterViewModel = FilterViewModel(
        startDate: Date(),
        endDate: Date().addingTimeInterval(24 * 60 * 60),
        minPrice: 0,
        maxPrice: 10000000,
        maxMinutes: 30
    )
    
    @StateObject private var shakeDetector = ShakeDetector()
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView {
                    FilterSearchView(show: $showFilterSearchView, filterViewModel: filterViewModel, offerViewModel: offerViewModel)
                } else {
                    ScrollView {
                        VStack {
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
                                        NavigationLink(value: offerWithProperty) {
                                            OfferView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                                .frame(height: 330)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        .onAppear {
                            fetchUserViewPreferences()
                        }
                        // Agregamos el controlador de detección de shake
                        .background(
                            ShakeHandlingControllerRepresentable(shakeDetector: shakeDetector)
                                .frame(width: 0, height: 0)  // Oculto, pero activo
                        )
                        .alert(isPresented: $showShakeAlert) {
                            Alert(title: Text("Shake Detected"), message: Text("Filters have been cleared🧹!"), dismissButton: .default(Text("OK")))
                        }
                        .onReceive(shakeDetector.$didShake) { didShake in
                            if didShake {
                                showShakeAlert = true
                                refreshOffers()  // Llama a la función para refrescar las ofertas
                                shakeDetector.resetShake()  // Reinicia el valor para que pueda detectar nuevos shakes
                            }
                        }
                        .navigationDestination(for: OfferWithProperty.self) { offerWithProperty in
                            OfferDetailView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                .navigationBarBackButtonHidden()
                        }
                    }
                }
            }
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
                // Determinamos la preferencia
                userRoommatePreference = roommateViews > noRoommateViews
            } else {
                print("No se encontró el documento de preferencias de usuario")
            }
        }
    }

    // Función para ordenar las ofertas basadas en la preferencia del usuario
    func sortedOffers() -> [OfferWithProperty] {
        guard let preference = userRoommatePreference else {
            return offerViewModel.offersWithProperties  // Si no hay preferencia, devolvemos las ofertas tal cual
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
