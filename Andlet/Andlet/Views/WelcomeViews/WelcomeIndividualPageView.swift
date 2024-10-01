//
//  WelcomeIndividualPageView.swift
//  SwiftApp
//
//  Created by Daniel Arango Cruz on 16/09/24.
//

import SwiftUI

struct WelcomeIndividualPageView: View {
    @Binding var pageIndex: Int
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Binding var path: NavigationPath  // Manage the navigation stack dynamically
    var pages: [Page]
    enum NavigationDestination: Hashable {
        case studentHome
        case landlordHome
        case profilePicker
        case authView
        case welcomePage
    }

    var body: some View {
        ZStack {
            Color(hex: "#C5DDFF")
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                Image(pages[0].imageUrl)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .cornerRadius(30)
                    .padding()

                Spacer()

                HStack {
                    CustomIndicatorView(totalPages: pages.count, currentPage: pageIndex)

                    Spacer()

                    CircularArrowButton()
                        .onTapGesture {
                            handleUserNavigation()

                            // Increment the page index
                            if pageIndex < pages.count - 1 {
                                pageIndex += 1
                            }
                        }
                }
                .padding(.bottom, 40)
                .padding(.trailing, 20)
                .padding(.leading, 40)
            }
            .navigationDestination(for: NavigationDestination.self) { destination in
                switch destination {
                case .studentHome:
                    MainTabView(path: $path)
                case .landlordHome:
                    MainTabLandlordView(path: $path)
                case .profilePicker:
                    ProfilePickerView(authViewModel: authViewModel, path: $path)
                case .authView:
                    AuthenticationView(pages: pages, authViewModel: authViewModel, path: $path)
                case .welcomePage:
                    WelcomePageView()
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            authViewModel.checkIfUserIsLoggedIn()
        }
    }

    // Handle user navigation based on authentication status and role
    private func handleUserNavigation() {
        if authViewModel.isAuthenticated {
            if let user = authViewModel.currentUser {
                switch user.typeUser {
                case .student:
                    path.append(NavigationDestination.studentHome)  // Navigate to student home
                case .landlord:
                    path.append(NavigationDestination.landlordHome)  // Navigate to landlord home
                case .notDefined:
                    path.append(NavigationDestination.profilePicker)  // Navigate to profile picker
                }
            }
        } else {
            path.append(NavigationDestination.authView)  // Navigate to authentication view if not signed in
        }
    }
}
