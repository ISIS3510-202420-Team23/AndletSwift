//
//  NotificationsRentView.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 18/11/24.
//

import SwiftUI
import FirebaseAuth
import UIKit

struct NotificationsRentView: View {
    @AppStorage("publishedOffline") private var publishedOffline = false
    @AppStorage("initialOfferCount") private var initialOfferCount = 0
    @State private var showNoConnectionBanner = false // Manejo del banner de conexión
    @StateObject private var notificationViewModel = NotificationViewModel() // ViewModel de notificaciones
    @StateObject private var networkMonitor = NetworkMonitor()
    @StateObject private var offerViewModel = OfferRentViewModel()

    let currentUser = Auth.auth().currentUser

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading) {
                    HeaderNotificationsView()

                    HStack {
                        Text("Bookmarks")
                            .font(.custom("LeagueSpartan-SemiBold", size: 25))
                            .foregroundColor(Color(hex: "0C356A"))
                            .fontWeight(.bold)
                        Spacer()
                    }
                    .padding(.horizontal)
                    .padding(.top, 10)

                    // Mostrar alerta si no hay conexión
                    if showNoConnectionBanner {
                        Text("⚠️ No Internet Connection, your bookmarks will not be updated")
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

                    // Lista de notificaciones dinámicas
                    VStack(spacing: 16) {
                        if notificationViewModel.notifications.isEmpty {
                            VStack {
                                Spacer()
                            Text("No notifications available")
                                .font(.headline)
                                .foregroundColor(.gray)
                                .padding()
                            Spacer() // Empuja desde la parte inferior
                                    }
                                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                        } else {
                            
                            ForEach(notificationViewModel.notifications) { notification in
                                
                                NotificationView(
                                    imageKey: notification.imageKey, // Placeholder, puedes ajustar si quieres imágenes dinámicas
                                    title: notification.propertyTitle,
                                    message: "\(notification.savesCount) people have saved your property in the last week.",
                                    date: DateFormatter.localizedString(
                                        from: Date(),
                                        dateStyle: .medium,
                                        timeStyle: .short
                                    )
                                )
                            }
                        }
                    }
                    .padding(.horizontal)
                    .padding(.top, 8)
                }
            }
            .navigationTitle("Notifications")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                // Detectar cambios en la conexión
                networkMonitor.$isConnected
                    .receive(on: DispatchQueue.main)
                    .sink { isConnected in
                        self.showNoConnectionBanner = !isConnected
                        if !isConnected {
                                        
                                        notificationViewModel.loadNotificationsFromLocal()
                                    }
                    }
                    .store(in: &notificationViewModel.cancellables)
                
                if let userId = currentUser?.email {
                                    offerViewModel.fetchOffers(for: userId)                                }

                            
                                offerViewModel.$offersWithProperties
                                    .receive(on: DispatchQueue.main)
                                    .sink { offersWithProperties in
                                        let userOffers = offersWithProperties.map { $0.offer } // Extraer las ofertas
                                        print("Ofertas del usuario: \(userOffers)") 
                                        notificationViewModel.fetchSaves(for: userOffers, timeInterval: 604800) // Últimos 7 días
                                    }
                                    .store(in: &notificationViewModel.cancellables)
                            }
                        }
                    }
                }
