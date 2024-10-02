//
//  AndletApp.swift
//  Andlet
//
//  Created by Daniel Arango Cruz on 20/09/24.
//
import SwiftUI
import FirebaseCore
import FirebaseDatabase // For Realtime Database
import FirebaseStorage // For Firebase Storage
import FirebaseFirestore


class AppDelegate: NSObject, UIApplicationDelegate {
  func application(_ application: UIApplication,
                   didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
    FirebaseApp.configure()

    return true
  }
}

@main
struct AndletApp: App {
    @UIApplicationDelegateAdaptor(AppDelegate.self) var delegate
    
    var body: some Scene {
        WindowGroup {
            WelcomePageView()
                .onAppear {
                    LocationManager.shared.registerUniversityGeofence()
                    checkDaysSinceLastContact()
                }
//            ContentView()
        }
    }
}
