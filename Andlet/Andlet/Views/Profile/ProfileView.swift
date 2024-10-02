//
//  ProfileView.swift
//  Andlet
//
//  Created by Daniel Arango Cruz on 30/09/24.
//

import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    var userImageURL: String?  // URL for the user's image
    @State private var isUserSignedOut = false  // Trigger for navigation

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // Load the user's image (from URL or default image)
                if let userImageURL = userImageURL, userImageURL != "", let url = URL(string: userImageURL) {
                    AsyncImage(url: url) { phase in
                        switch phase {
                        case .success(let image):
                            image
                                .resizable()
                                .aspectRatio(contentMode: .fill)
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                        case .failure(_):
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        case .empty:
                            ProgressView()
                        @unknown default:
                            Image(systemName: "person.circle.fill")
                                .resizable()
                                .frame(width: 150, height: 150)
                                .clipShape(Circle())
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.bottom, 40)
                } else {
                    Image(systemName: "person.circle.fill")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }

                // Sign Out Button
                Button(action: {
                    signOutUser()  // Sign out the user
                }) {
                    Text("Sign Out")
                        .foregroundColor(.white)
                        .font(.headline)
                        .frame(width: 200, height: 50)
                        .background(Color.red)
                        .cornerRadius(10)
                }

                Spacer()

                // NavigationLink to trigger navigation after sign-out
                NavigationLink(
                    destination: WelcomePageView(),
                    isActive: $isUserSignedOut  // Binding to the state that triggers the navigation
                ) {
                    EmptyView()  // The NavigationLink doesn't display anything, navigation is triggered by state
                }
            }
            .navigationTitle("Profile")
            .navigationBarTitleDisplayMode(.inline)
            .padding()
        }
    }

    // Sign out logic
    private func signOutUser() {
        authViewModel.signOut()  // Sign out the user
        authViewModel.isAuthenticated = false
        isUserSignedOut = true  // Trigger navigation to WelcomePageView
    }
}
