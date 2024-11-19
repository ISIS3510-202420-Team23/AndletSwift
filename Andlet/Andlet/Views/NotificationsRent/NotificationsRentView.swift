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
    @State private var isConnected = false
    @State private var showSuccessNotification = false
    @State private var showFilterSearchView = false
    @State private var showShakeAlert = false
    @State private var showConfirmationAlert = false
    @State private var showNoConnectionBanner = false
    @StateObject private var offerViewModel = OfferRentViewModel()
    @StateObject private var propertyViewModel = PropertyViewModel()
    @StateObject private var shakeDetector = ShakeDetector()
    @StateObject private var networkMonitor = NetworkMonitor()
    @State private var propertyOfferData = PropertyOfferData()  // Instancia inicial
    @State private var isPublishing = false
    
    struct NotificationData: Hashable {
        let image: String
        let title: String
        let message: String
        let date: String
    }
    
    @State private var notifications = [
        // Datos falsos para notificaciones
        NotificationData(image: "exampleImage1", title: "Apartment - T2 - 1102", message: "2 people have saved your property in the last day.", date: "01/08/2024 16:45:14"),
        NotificationData(image: "exampleImage2", title: "Beautiful house", message: "4 people have saved your property in the last day.", date: "02/08/2024 10:30:00"),
        NotificationData(image: "exampleImage3", title: "Cozy Studio", message: "1 person saved your property recently.", date: "03/08/2024 08:15:22")
    ]
    
    let currentUser = Auth.auth().currentUser
    
    var body: some View {
        NavigationStack {
                    ScrollView {
                        VStack (alignment: .leading){
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
                            
                            // Lista de notificaciones
                            VStack(spacing: 16) {
                                ForEach(notifications, id: \.self) { notification in
                                    NotificationView(
                                        image: notification.image,
                                        title: notification.title,
                                        message: notification.message,
                                        date: notification.date
                                    )
                                }
                            }
                            .padding(.horizontal)
                            .padding(.top, 8)
                        }
                    }
                    .navigationTitle("Notifications")
                    .navigationBarTitleDisplayMode(.inline)
                }
            }
        }
    
        
        // Modelo para datos de notificaciones
        struct NotificationData: Hashable {
            let image: String
            let title: String
            let message: String
            let date: String
        }
