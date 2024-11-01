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
                            
                            if showNoConnectionBanner {
                                Text("⚠️ No Internet Connection, you cannot change an offer status if you are offline")
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
                            } else {
                                CreateMoreButton()
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
                            }
                            // Actualizar el estado de conexión
                            isConnected = isConnectedStatus
                            
                            // Solo refrescar ofertas si se restauró la conexión y había publicaciones sin conexión
                            if isConnectedStatus && publishedOffline {
                                refreshOffers() // Actualizar las ofertas al recuperar conexión
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
                        Text("Your property has been published successfully!")
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
            .onAppear {
                viewModel.fetchOffers(for: "\(currentUser?.email ?? "UNKNOWN")")
            }
            .onChange(of: viewModel.offersWithProperties) { newOffers in
                
                // Establecer el valor inicial después de la primera carga de `offersWithProperties`
                if initialOfferCount == 0 {
                    initialOfferCount = newOffers.count
                }
                
                // Mostrar la notificación si el conteo de ofertas ha aumentado y la conexión ha sido restaurada
                if publishedOffline && isConnected && newOffers.count > initialOfferCount {
                    showSuccessNotification = true
                    initialOfferCount = newOffers.count // Actualizar el contador inicial
                    publishedOffline = false // Resetear publishedOffline solo cuando se detecte un nuevo conteo
                } else {

                }
            }
            .navigationBarHidden(true)
        }
    }
    
    func refreshOffers() {
        viewModel.fetchOffers(for: "\(currentUser?.email ?? "UNKNOWN")")
    }
}
