//
//  ContentView.swift
//  Andlet
//
//  Created by Daniel Arango Cruz on 20/09/24.
//

//import SwiftUI
//
//struct ContentView: View {
//    var body: some View {
//        VStack {
//            Image(systemName: "globe")
//                .imageScale(.large)
//                .foregroundStyle(.tint)
//            Text("Hello, world!")
//        }
//        .padding()
//    }
//}
//
//#Preview {
//    ContentView()
//}

import SwiftUI
import FirebaseAuth

struct ContentView: View {
    var body: some View {
        Text("Log out user")
            .onAppear {
                do {
                    try Auth.auth().signOut()
                    print("User logged out successfully")
                } catch let signOutError as NSError {
                    print("Error signing out: %@", signOutError)
                }
            }
    }
}
