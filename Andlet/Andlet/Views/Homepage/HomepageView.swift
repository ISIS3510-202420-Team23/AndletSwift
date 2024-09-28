//
//  HomepageTestsView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 16/09/24.
//

import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct HomepageView: View {
    @State private var showFilterSearchView = false
    @StateObject private var offerViewModel = OfferViewModel()
    @State private var userRoommatePreference: Bool? = nil  // true = prefiere roommates, false = no roommates

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView {
                    FilterSearchView(show: $showFilterSearchView)
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
                                    ForEach(offerViewModel.offersWithProperties) { offerWithProperty in
                                        NavigationLink(value: offerWithProperty) {  // Aquí pasamos OfferWithProperty
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
                    // Prefiere roommates: primero las ofertas con roommates
                    return firstHasRoommates && !secondHasRoommates
                } else {
                    // Prefiere no roommates: primero las ofertas sin roommates
                    return !firstHasRoommates && secondHasRoommates
                }
            }
        }
    }
