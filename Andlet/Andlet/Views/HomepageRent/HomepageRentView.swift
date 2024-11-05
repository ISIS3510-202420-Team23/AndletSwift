import SwiftUI
import FirebaseAuth
import UIKit

struct HomepageRentView: View {
    @AppStorage("publishedOffline") private var publishedOffline = false // Estado de publicación offline
    @AppStorage("initialOfferCount") private var initialOfferCount = 0 // Cantidad inicial de ofertas
    @State private var isConnected = false // Indica si la conexión a Internet está activa
    @State private var showSuccessNotification = false // Notificación de éxito
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @State private var showNoConnectionBanner = false
    @StateObject private var viewModel = OfferRentViewModel()
    @StateObject private var shakeDetector = ShakeDetector()
    @StateObject private var networkMonitor = NetworkMonitor()
    @ObservedObject var propertyOfferData = PropertyOfferData() // Agrega la instancia de PropertyOfferData

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
                            
                            CreateMoreButton(isConnected: isConnected)
                                .disabled(publishedOffline && !isConnected) // Desactiva el botón si se publicó offline y no hay conexión

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
                            if initialOfferCount == 0 {
                                initialOfferCount = viewModel.offersWithProperties.count
                            }
                            print("HomepageRentView loaded for user: \(currentUser?.email ?? "UNKNOWN")")
                            viewModel.fetchOffers(for: "\(currentUser?.email ?? "UNKNOWN")")
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
                            isConnected = isConnectedStatus
                            
                            // Refrescar las ofertas y publicar pendientes si se restauró la conexión y había publicaciones offline
                            if isConnectedStatus && publishedOffline {
                                refreshOffers()
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
                                // Resetear los datos de la propiedad cuando aparece la notificación de éxito
                                propertyOfferData.reset()
                                
                                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                    showSuccessNotification = false
                                }
                            }
                    }
                }
                .animation(.easeInOut, value: showSuccessNotification)
            )
            .onChange(of: viewModel.offersWithProperties) { newOffers in
                print("OFFER COUNT CHANGED - INITIAL: \(initialOfferCount), NEW COUNT: \(newOffers.count)")
                
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
