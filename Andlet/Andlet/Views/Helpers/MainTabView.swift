//
//  MainTabView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 18/09/24.
//

import SwiftUI


struct MainTabView: View {
    @StateObject private var shakeDetector = ShakeDetector()  // Instancia de ShakeDetector
    @State private var showShakeAlert = false
    init() {
          
        UITabBar.appearance().backgroundColor = UIColor.white
        UITabBar.appearance().shadowImage = UIImage()
        UITabBar.appearance().backgroundImage = UIImage()
       }
    
    var body: some View {
        TabView {
            HomepageView()
                .edgesIgnoringSafeArea(.all)
                .tabItem {
                    Label("Explore", systemImage: "location.fill"
                        )
                    .foregroundStyle(Color(hex: "0C356A"))
                }
            
        }
        .accentColor(Color(hex: "0C356A"))
        .onAppear {
                    UIApplication.shared.windows.first?.rootViewController?.becomeFirstResponder()
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

#Preview {
    MainTabView()
    
}
