import SwiftUI
import FirebaseAuth
import UIKit

struct HomepageRentView: View {
    @AppStorage("publishedOffline") private var publishedOffline = false // Indica si se publicó sin conexión
    @AppStorage("initialOfferCount") private var initialOfferCount = 0 // Cantidad inicial de ofertas en la primera carga
    @State private var isConnected = false // Indica si la conexión a Internet está activa
    @State private var showSuccessNotification = false // Notificación de éxito
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @State private var showNoConnectionBanner = false
    @StateObject private var viewModel = OfferRentViewModel()
    @StateObject private var shakeDetector = ShakeDetector()
    @StateObject private var networkMonitor = NetworkMonitor()
    
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
                            
                            CreateMoreButton()
                            
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
                        
                            
                        
                            
                            if viewModel.offersWithProperties.isEmpty {
                                Text("No offers available")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                LazyVStack(spacing: 32) {
                                    ForEach(viewModel.offersWithProperties) { offerWithProperty in
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
                            print("ON APPEAR - EXISTING INITIAL OFFER COUNT: \(initialOfferCount)")
                            print("CURRENT OFFER COUNT ON APPEAR: \(viewModel.offersWithProperties.count)")
                            
                            let cache = URLCache.shared
                            print("CACHE USAGE - MEMORY: \(cache.currentMemoryUsage) BYTES, DISK: \(cache.currentDiskUsage) BYTES.")
                        }
                        
                        .background(
                            ShakeHandlingControllerRepresentable(shakeDetector: shakeDetector)
                                .frame(width: 0, height: 0)  // Oculto pero activo
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
                            // Actualizar el estado de conexión
                            isConnected = isConnectedStatus
                            
                            // Solo refrescar ofertas si se restauró la conexión y había publicaciones sin conexión
                            if isConnectedStatus && publishedOffline {
                                print("CONNECTION RESTORED - REFRESHING OFFERS AFTER OFFLINE PUBLISH")
                                refreshOffers() // Actualizar las ofertas al recuperar conexión
                            }
                        }
                        .onReceive(NotificationCenter.default.publisher(for: .offerSaveCompleted)) { _ in
                            print("OFFER SAVE COMPLETED NOTIFICATION RECEIVED - REFRESHING OFFERS")
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
                                    print("SUCCESS NOTIFICATION DISMISSED")
                                }
                            }
                    }
                }
                .animation(.easeInOut, value: showSuccessNotification)
            )
            .onAppear {
                print("HOMEPAGERENTVIEW APPEARED - FETCHING OFFERS FOR \(currentUser?.email ?? "UNKNOWN")")
                viewModel.fetchOffers(for: "\(currentUser?.email ?? "UNKNOWN")")
            }
            .onChange(of: viewModel.offersWithProperties) { newOffers in
                print("OFFER COUNT CHANGED - INITIAL: \(initialOfferCount), NEW COUNT: \(newOffers.count)")
                
                // Establecer el valor inicial después de la primera carga de `offersWithProperties`
                if initialOfferCount == 0 {
                    initialOfferCount = newOffers.count
                    print("SETTING INITIAL OFFER COUNT: \(initialOfferCount)")
                }
                
                // Mostrar la notificación si el conteo de ofertas ha aumentado y la conexión ha sido restaurada
                if publishedOffline && isConnected && newOffers.count > initialOfferCount {
                    print("NEW PROPERTY ADDED AFTER RECONNECTION - SHOWING SUCCESS NOTIFICATION")
                    showSuccessNotification = true
                    initialOfferCount = newOffers.count // Actualizar el contador inicial
                    publishedOffline = false // Resetear publishedOffline solo cuando se detecte un nuevo conteo
                } else {
                    print("NO NEW PROPERTY ADDED OR CONDITIONS NOT MET (PUBLISHEDOFFLINE: \(publishedOffline), ISCONNECTED: \(isConnected))")
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func refreshOffers() {
        print("REFRESHING OFFERS FOR LANDLORD...")
        viewModel.fetchOffers(for: "\(currentUser?.email ?? "UNKNOWN")")
    }
}
