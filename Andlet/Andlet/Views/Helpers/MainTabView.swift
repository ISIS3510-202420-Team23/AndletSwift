//
//  MainTabView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 18/09/24.
//

import SwiftUI



struct MainTabView: View {
    @StateObject private var shakeDetector = ShakeDetector()  // Instancia de ShakeDetector
    @StateObject private var filterViewModel = FilterViewModel()
    @StateObject private var offerViewModel: OfferViewModel
    @StateObject private var offerSavedViewModel: SavedOffersViewModel
    @StateObject private var networkManager = NetworkMonitor()
    @State private var showShakeAlert = false
    @State public var selectedTab: Tab = .explore
    @State private var showNoConnectionBanner = false

    enum Tab {
        case explore
        case saved
    }

    init(initialTab: Tab = .explore) {
        // Inicializa los modelos de vista solo una vez
        let filterVM = FilterViewModel()
        _selectedTab = State(initialValue: initialTab)
        _filterViewModel = StateObject(wrappedValue: filterVM)
        _offerViewModel = StateObject(wrappedValue: OfferViewModel(filterViewModel: filterVM))
        _offerSavedViewModel = StateObject(wrappedValue: SavedOffersViewModel(filterViewModel: filterVM))
    }
  
    var body: some View {
        TabView {
            HomepageView(offerViewModel: offerViewModel, filterViewModel: filterViewModel, showNoConnectionBanner: $showNoConnectionBanner)
                .edgesIgnoringSafeArea(.all)
                .tabItem {
                    Label("Explore", systemImage: "location.fill"
                        )
                    .foregroundStyle(Color(hex: "0C356A"))
                }
                .tag(Tab.explore)
            SavedOffersView(offerViewModel: offerSavedViewModel, showNoConectionBanner: $showNoConnectionBanner)
                .tabItem {
                    Label("Saved", systemImage: "bookmark.fill"
                    )
                    .foregroundStyle(Color(hex: "0C356A"))
                }
                .tag(Tab.saved)
            
            
        }
        .navigationBarBackButtonHidden(true)
        .accentColor(Color(hex: "0C356A"))
        .onAppear {
            UITabBar.appearance().backgroundColor = UIColor.white
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
//            UIApplication.shared.windows.first?.rootViewController?.becomeFirstResponder()
        }
        .onReceive(networkManager.$isConnected) { isConnected in
                    withAnimation {
                        showNoConnectionBanner = !isConnected
                    }
                }
                .onReceive(shakeDetector.$didShake) { didShake in
                    if didShake {
                        showShakeAlert = true
                        shakeDetector.didShake = false  // Reinicia el valor
                    }
                }
                .alert(isPresented: $showShakeAlert) {
                    Alert(
                        title: Text("Shake Detected"),
                        message: Text("You have refreshed the offers!"),
                        dismissButton: .default(Text("OK"))
                    )
                }
    }
}
