import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct SavedOffersView: View {
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @Binding private var showNoConnectionBanner: Bool // Cambiado a @Binding
    @ObservedObject private var networkMonitor = NetworkMonitor()
    @ObservedObject private var offerViewModel: SavedOffersViewModel
    @State private var userRoommatePreference: Bool? = nil
    @StateObject private var shakeDetector = ShakeDetector()
    @State private var selectedOffer: OfferWithProperty?
    @State private var isInitialized = false
    
    public init(
        offerViewModel: SavedOffersViewModel,
        showNoConectionBanner: Binding<Bool>
    ) {
        self.offerViewModel = offerViewModel
        self._showNoConnectionBanner = showNoConectionBanner
    }
  
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                    ScrollView {
                        VStack {
                            Spacer()
                            Heading()
//                            SearchAndFilterSavedBar(
//                                filterViewModel: filterViewModel,
//                                offerViewModel: offerViewModel
//                            )
//                            .onTapGesture {
//                                withAnimation(.snappy) {
//                                    showFilterSearchView.toggle()
//                                }
//                            }
                            
                            Text("Your saved places")
                                .font(.custom("LeagueSpartan-SemiBold", size: 22))
                                .foregroundColor(Color(hex: "0C356A"))
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .padding(.horizontal, 20)
                                .padding(.top, 10)
                            
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
                            
                            if offerViewModel.savedOffers.isEmpty {
                                Text("No offers available")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                LazyVStack(spacing: 32) {
                                    ForEach(sortedOffers()) { offerWithProperty in
                                        Button(action: {
                                            selectedOffer = offerWithProperty
                                        }) {
                                            OfferView(
                                                offer: offerWithProperty.offer,
                                                property: offerWithProperty.property
                                            )
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
                        .background(
                            ShakeHandlingControllerRepresentable(shakeDetector: shakeDetector)
                                .frame(width: 0, height: 0)
                        )
                        .alert(isPresented: $showConfirmationAlert) {
                            Alert(
                                title: Text("Shake Detected"),
                                message: Text("Do you want to clear the filters?🧹"),
                                primaryButton: .destructive(Text("Yes")) {
                                    offerViewModel.fetchSavedOffers()
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
//                        .onReceive(networkMonitor.$isConnected) { isConnected in
//                            withAnimation {
//                                showNoConnectionBanner = !isConnected
//                            }
//                            if isConnected {
//                                offerViewModel.syncOfflineViews()
//                            }
//                        }
                        // Task para inicializar datos
                        .task {
                            if !isInitialized {
                                isInitialized = true
                                await initializeData()
                                print("Apareci iniciado en saved")
                            }
                            print("Apareci en la vista saved")
                        }
                        .navigationDestination(isPresented: Binding(
                            get: { selectedOffer != nil },
                            set: { _ in selectedOffer = nil }
                        )) {
                            if let offerWithProperty = selectedOffer {
                                OfferDetailView(
                                    offer: offerWithProperty.offer,
                                    property: offerWithProperty.property,
                                    tabOrigin: .saved
                                )
                                .navigationBarBackButtonHidden()
                            }
                        }
                    }
                }
                .navigationBarBackButtonHidden(true)
        } else {
            Text("Version not supported")
        }
    }

    // MARK: - Initialization
    func initializeData() async {
//        fetchUserViewPreferences() // No asíncrono, corre inmediatamente.
        // Manejo de fetch de ofertas
        offerViewModel.fetchSavedOffers()
        
    }

    func fetchUserViewPreferences() {
        let db = Firestore.firestore()
        guard let userEmail = Auth.auth().currentUser?.email else {
            print("Error: No logged-in user")
            return
        }

        let userViewsRef = db.collection("user_views").document(userEmail)
        userViewsRef.getDocument { document, error in
            if let document = document, document.exists {
                let roommateViews = document.data()?["roommates_views"] as? Int ?? 0
                let noRoommateViews = document.data()?["no_roommates_views"] as? Int ?? 0

                UserDefaults.standard.roommateViews = roommateViews
                UserDefaults.standard.noRoommateViews = noRoommateViews

                userRoommatePreference = roommateViews > noRoommateViews
            } else {
                print("User preferences document not found")
            }
        }
    }

    func sortedOffers() -> [OfferWithProperty] {
        let preference = userRoommatePreference ?? (UserDefaults.standard.roommateViews > UserDefaults.standard.noRoommateViews)
        return offerViewModel.savedOffers.sorted { first, second in
            let firstHasRoommates = first.offer.roommates > 0
            let secondHasRoommates = second.offer.roommates > 0
            return preference ? (firstHasRoommates && !secondHasRoommates) : (!firstHasRoommates && secondHasRoommates)
        }
    }
}
