//
//  HomepageTestsView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 17/09/24.
//



import SwiftUI
import FirebaseAuth
import UIKit

struct HomepageRentView: View {
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @StateObject private var viewModel = OfferRentViewModel()
    @StateObject private var shakeDetector = ShakeDetector()  // Detector de shake

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
                                            print("Oferta: \(offerWithProperty.offer)")
                                            print("Propiedad: \(offerWithProperty.property)")
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        // Detección de shake
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
                            if didShake {
                                showConfirmationAlert = true
                                shakeDetector.resetShake()
                            }
                        }
                    }
                }
            }
            .onAppear {
                print("HomepageRentView appeared - Fetching offers for \(currentUser?.email ?? "Unknown") ...")
                viewModel.fetchOffers(for: "\(currentUser?.email ?? "Unknown")")
            }
            .navigationBarHidden(true)
        } else {
            // Fallback en versiones anteriores
        }
    }

    // Función para refrescar las ofertas
    func refreshOffers() {
        print("Dispositivo agitado. Refrescando ofertas para el landlord...")
        viewModel.fetchOffers(for: "\(currentUser?.email ?? "Unknown")")  // Llamamos a la función para recargar las ofertas
    }
}
