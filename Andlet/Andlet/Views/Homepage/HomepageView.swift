import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct HomepageView: View {
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @State private var showNoConnectionBanner = false
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var offerViewModel: OfferViewModel
    @State private var userRoommatePreference: Bool? = nil
    @StateObject private var filterViewModel: FilterViewModel
    @StateObject private var shakeDetector = ShakeDetector()
    @State private var selectedOffer: OfferWithProperty?  // Add a state to track selected offer
    
    init() {
        let filterVM = FilterViewModel()  // Inicia FilterViewModel con AppStorage
        _filterViewModel = StateObject(wrappedValue: filterVM)
        _offerViewModel = StateObject(wrappedValue: OfferViewModel(filterViewModel: filterVM))
    }
    
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
                            SearchAndFilterBar(filterViewModel: filterViewModel, offerViewModel: offerViewModel)
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        showFilterSearchView.toggle()
                                    }
                                }
                            if showNoConnectionBanner {
                                Text("⚠️ No Internet Connection, offers and availability will not be updated")
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
                            Color.clear.frame(height: 80)}
                        
                        .onAppear {
                            logPeakAction()
                            fetchUserViewPreferences()
                            let cache = URLCache.shared
                            print("Cache actual: \(cache.currentMemoryUsage) bytes en memoria y \(cache.currentDiskUsage) bytes en disco.")
                            
                            
                            if filterViewModel.filtersApplied {
                                offerViewModel.fetchOffersWithFilters()
                            } else {
                                offerViewModel.fetchOffers()
                            }
                        }
                        .background(
                            ShakeHandlingControllerRepresentable(shakeDetector: shakeDetector)
                                .frame(width: 0, height: 0)
                        )
                        .alert(isPresented: $showConfirmationAlert) {
                            Alert(
                                title: Text("Shake Detected"),
                                message: Text("Do you want to clear the filters?🧹"),
                                primaryButton: .destructive(Text("Yes")) {
                                    filterViewModel.clearFilters()
                                    offerViewModel.fetchOffers()
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
                            withAnimation {
                                showNoConnectionBanner = !isConnected
                            }
                            if isConnected {
                                offerViewModel.syncOfflineViews()
                            }
                        }
                        // Manage navigation based on selected offer
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
                
                // Guardamos en UserDefaults
                UserDefaults.standard.roommateViews = roommateViews
                UserDefaults.standard.noRoommateViews = noRoommateViews
                
                userRoommatePreference = roommateViews > noRoommateViews
            } else {
                print("No se encontró el documento de preferencias de usuario")
            }
        }
    }
    
    // Función para registrar la acción "peak" en Firestore
    private func logPeakAction() {
        guard let currentUser = Auth.auth().currentUser, let userEmail = currentUser.email else {
            print("Error: No se pudo obtener el email del usuario, el usuario no está autenticado.")
            return
        }
        
        // Crear un identificador único para el documento usando el formato solicitado
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        let documentID = "5_\(userEmail)_\(formattedDate)"  // Identificador que empieza con "5"
        
        // Crear la estructura del documento
        let actionData: [String: Any] = [
            "action": "peak",
            "app": "swift",
            "date": Date(),
            "user_id": userEmail
        ]
        
        // Registrar la acción en la colección "user_actions" en Firestore
        let db = Firestore.firestore()
        db.collection("user_actions").document(documentID).setData(actionData) { error in
            if let error = error {
                print("Error al registrar el evento 'peak' en Firestore: \(error.localizedDescription)")
            } else {
                print("Evento 'peak' registrado exitosamente en Firestore con ID: \(documentID)")
            }
        }
    }
    
    func sortedOffers() -> [OfferWithProperty] {
        // Comprobamos si hay conexión
        let isConnected = networkMonitor.isConnected
        
        // Usar la preferencia desde Firestore o UserDefaults
        let preference: Bool
        if isConnected, let userPreference = userRoommatePreference {
            preference = userPreference
        } else {
            preference = UserDefaults.standard.roommateViews > UserDefaults.standard.noRoommateViews
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
