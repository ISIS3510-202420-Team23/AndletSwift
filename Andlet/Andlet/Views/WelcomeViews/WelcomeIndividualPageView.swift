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
    @State private var navigateToAuth = false // State to control navigation to AuthenticationView
    @State private var navigateToProfile = false // State to control navigation to ProfilePickerView
    var pages: [Page]

    var body: some View {
        ZStack {
            Color(hex: "#C5DDFF")
                .edgesIgnoringSafeArea(.all)

            VStack {
                Spacer()

                // Displaying the image from the current page
                Image(pages[0].imageUrl)
                    .resizable()
                    .scaledToFit()
                    .padding()
                    .cornerRadius(30)
                    .padding()

                Spacer()

                HStack {
                    // Custom page indicator
                    CustomIndicatorView(totalPages: pages.count, currentPage: pageIndex)

                    Spacer()


                    CircularArrowButton()
                        .onTapGesture {
                            // Trigger navigation based on authentication state
                            if authViewModel.isAuthenticated {
                                navigateToProfile = true // Navigate to ProfilePickerView
                            } else {
                                navigateToAuth = true // Navigate to AuthenticationView
                            }
                            
                            // Increment the pageIndex when clicked
                            if pageIndex < pages.count - 1 {
                                pageIndex += 1
                            }
                        }
                }
                .padding(.bottom, 40)
                .padding(.trailing, 20)
                .padding(.leading, 40)
            }
            // Navigation Links (hidden) that trigger when states change
            .background(
                NavigationLink(
                    destination: ProfilePickerView(),
                    isActive: $navigateToProfile // Tied to state to navigate to ProfilePickerView
                ) {
                    EmptyView() // No visible content
                }
            )
            .background(
                NavigationLink(
                    destination: AuthenticationView(
                        pages: pages,
                        onLogginSuccess: {
                            authViewModel.isAuthenticated = true // After login, mark as authenticated
                            navigateToProfile = true // Automatically navigate to ProfilePickerView
                        },
                        authViewModel: authViewModel
                    ),
                    isActive: $navigateToAuth // Tied to state to navigate to AuthenticationView
                ) {
                    EmptyView() // No visible content
                }
            )
        }
    }
}

#Preview {
    WelcomePageView()
}
