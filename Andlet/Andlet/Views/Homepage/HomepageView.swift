import SwiftUI
import FirebaseAuth
import FirebaseFirestore
import UIKit

struct HomepageView: View {
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @Binding private var showNoConnectionBanner: Bool // Pasado desde MainTabView
    @ObservedObject private var offerViewModel: OfferViewModel
    @ObservedObject private var filterViewModel: FilterViewModel
    @ObservedObject private var networkMonitor = NetworkMonitor()
    @StateObject private var shakeDetector = ShakeDetector()
    @State private var selectedOffer: OfferWithProperty?  // Estado local para ofertas seleccionadas
    @State private var userRoommatePreference: Bool? = nil
    
    @State private var isInitialized: Bool = false
    
    public init(offerViewModel: OfferViewModel,
                filterViewModel: FilterViewModel, showNoConnectionBanner: Binding<Bool>) {
        self.offerViewModel = offerViewModel
        self.filterViewModel = filterViewModel
        self._showNoConnectionBanner = showNoConnectionBanner
    }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView {
                    FilterSearchView(show: $showFilterSearchView,
                                     filterViewModel: filterViewModel,
                                     offerViewModel: offerViewModel)
                } else {
                    ScrollView {
                        VStack {
                            Spacer()
                            Heading()
                            SearchAndFilterBar(filterViewModel: filterViewModel,
                                               offerViewModel: offerViewModel)
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
                                            selectedOffer = offerWithProperty  // Selección de oferta
                                        }) {
                                            OfferView(offer: offerWithProperty.offer,
                                                      property: offerWithProperty.property)
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
//                        .onReceive(networkMonitor.$isConnected) { isConnected in
//                            withAnimation {
//                                showNoConnectionBanner = !isConnected
//                            }
//                            if isConnected {
//                                offerViewModel.syncOfflineViews()
//                            }
//                        }
                        .task {
                            if !isInitialized {
                                isInitialized = true
                                await initializeData()
                                print("Apareci iniciado en homePage")
                            }
                            
                            print("Apareci en homepage")
                        }
                        .navigationDestination(isPresented: Binding(
                            get: { selectedOffer != nil },
                            set: { _ in selectedOffer = nil }
                        )) {
                            if let offerWithProperty = selectedOffer {
                                OfferDetailView(offer: offerWithProperty.offer,
                                                property: offerWithProperty.property,
                                                tabOrigin: .explore)
                                    .navigationBarBackButtonHidden()
                            }
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
        // Fetch user preferences
//        fetchUserViewPreferences()

        // Fetch offers with or without filters
        if filterViewModel.filtersApplied {
            await offerViewModel.fetchOffersWithFilters()
        } else {
            await offerViewModel.fetchOffers()
        }

        // Log cache stats
        let cache = URLCache.shared
        print("Cache usage: \(cache.currentMemoryUsage) bytes in memory, \(cache.currentDiskUsage) bytes on disk.")
    }
    
    // MARK: - Helpers
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

                // Save preferences in UserDefaults
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


        return offerViewModel.offersWithProperties.sorted { first, second in
            let firstHasRoommates = first.offer.roommates > 0
            let secondHasRoommates = second.offer.roommates > 0
            return preference ? (firstHasRoommates && !secondHasRoommates) : (!firstHasRoommates && secondHasRoommates)
        }
    }
}
