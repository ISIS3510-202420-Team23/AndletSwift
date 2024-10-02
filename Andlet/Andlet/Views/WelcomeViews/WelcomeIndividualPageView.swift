import SwiftUI
struct WelcomeIndividualPageView: View {
    @Binding var pageIndex: Int
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var destination: NavigationDestination?  // Manage the navigation state
    var pages: [Page]

    enum NavigationDestination: Hashable {
        case studentHome
        case landlordHome
        case profilePicker
        case authView
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

                // Use NavigationLink to navigate to another view
                NavigationLink(
                    destination: getDestinationView(),  // Dynamically determine the view to navigate to
                    isActive: Binding(
                        get: { destination != nil },
                        set: { _ in destination = nil }  // Reset destination after navigation
                    )) {
                    EmptyView()  // Invisible NavigationLink
                }
            }
            .navigationBarBackButtonHidden(true)
        }
        .onAppear {
            authViewModel.checkIfUserIsLoggedIn()
            print("Entre al welcome individual")
        }
    }

    // Handle user navigation based on authentication status and role
    private func handleUserNavigation() {
        if authViewModel.isAuthenticated {
            if let user = authViewModel.currentUser {
                switch user.typeUser {
                case .student:
                    print("Navigating to student home")
                    destination = .studentHome  // Set the destination to student home
                case .landlord:
                    destination = .landlordHome  // Set the destination to landlord home
                case .notDefined:
                    destination = .profilePicker  // Set the destination to profile picker
                }
            }
        } else {
            destination = .authView  // Navigate to authentication view if not signed in
        }
    }

    // Dynamically return the view to navigate to
    private func getDestinationView() -> some View {
        switch destination {
        case .studentHome:
            return AnyView(MainTabView())  // Navigate to MainTabView (student home)
        case .landlordHome:
            return AnyView(MainTabLandlordView())  // Navigate to MainTabLandlordView (landlord home)
        case .profilePicker:
            return AnyView(ProfilePickerView(authViewModel: authViewModel))  // Navigate to ProfilePickerView
        case .authView:
            return AnyView(AuthenticationView(pages: pages, authViewModel: authViewModel))  // Navigate to AuthenticationView
        case .none:
            return AnyView(EmptyView())  // Default case when no navigation is set
        }
    }
}
