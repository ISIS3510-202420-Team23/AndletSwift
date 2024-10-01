import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
struct AuthenticationView: View {
    var pages: [Page]
    @ObservedObject var authViewModel: AuthenticationViewModel
    @Binding var path: NavigationPath  // Shared navigation path from the parent view

    // Enum to manage different navigation destinations
    enum NavigationDestination: Hashable, Codable {
        case profilePicker
        case studentHome
        case landlordHome
    }

    var body: some View {
        VStack(spacing: 20) {
            Spacer(minLength: 50)
            // Title
            Text(pages[1].title)
                .font(.custom("LeagueSpartan-ExtraBold", size: 48).bold())
                .foregroundColor(Color(hex: "#1B3A68"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 27)

            Text(pages[1].subTitle)
                .font(.custom("Montserrat-Light", size: 18))
                .foregroundColor(Color(hex: "#1B3A68"))
                .multilineTextAlignment(.leading)
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.leading, 27)

            Spacer(minLength: 50)

            VStack(spacing: 16) {
                // Register prompt
                HStack {
                    Text("New Member?")
                        .foregroundColor(Color(hex: "#0C356A"))
                        .font(.custom("Montserrat-Medium", size: 15))

                    Text("Register now")
                        .foregroundColor(Color(hex: "#0C356A"))
                        .font(.custom("Montserrat-Bold", size: 15))
                        .underline()
                }

                // Sign in button
                Button(action: signInWithGoogle) {
                    HStack {
                        Image("GoogleIcon")
                            .resizable()
                            .frame(width: 25, height: 24)
                            .padding(.leading, 10)

                        Text("Sign in with Google")
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.white)
                    .cornerRadius(50)
                    .shadow(radius: 5)
                }

                HStack {
                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(Color.black)

                    Text("Or log in with Email")
                        .font(.custom("Montserrat-Regular", size: 15))
                        .foregroundColor(.black)

                    Rectangle()
                        .frame(height: 1)
                        .foregroundColor(.black)
                }

                Button(action: signInWithGoogle) {
                    HStack {
                        Image("GoogleIcon")
                            .resizable()
                            .frame(width: 24, height: 24)
                            .padding(.leading, 10)

                        Text("Log in with Google")
                            .foregroundColor(.black)
                            .padding(.vertical, 10)
                            .frame(maxWidth: .infinity)
                    }
                    .background(Color.white)
                    .cornerRadius(50)
                    .shadow(radius: 5)
                }

                Spacer()

                HStack {
                    CustomIndicatorView(totalPages: pages.count, currentPage: pages[1].tag)
                    Spacer()
                }
                .padding(.bottom, 70)
                .padding(.trailing, 20)
                .padding(.leading, 20)
            }
            .padding(.horizontal)

            // Navigation happens programmatically via path.append()
            .navigationDestination(for: NavigationDestination.self) { destination in
                getDestinationView(for: destination)
            }
        }
        .padding()
        .background(Color(hex: "#C5DDFF"))
        .edgesIgnoringSafeArea(.all)
        .navigationBarHidden(true)
    }

    // Function to handle Google Sign-In and programmatically navigate based on role
    private func signInWithGoogle() {
        Task {
            let isSuccess = await authViewModel.signInWithGoogle()
            print("This is the path in auth \(String(describing: path.codable))")
            if isSuccess {
                // Navigate based on user role
                if let user = authViewModel.currentUser {
                    switch user.typeUser {
                    case .notDefined:
                        path.append(NavigationDestination.profilePicker)
                    case .student:
                        path.append(NavigationDestination.studentHome)
                    case .landlord:
                        path.append(NavigationDestination.landlordHome)
                    }
                }
            }
        }
    }

    // Helper function to return the destination view based on the user's role
    @ViewBuilder
    func getDestinationView(for destination: NavigationDestination) -> some View {
        switch destination {
        case .profilePicker:
            ProfilePickerView(authViewModel: authViewModel, path: $path)
        case .studentHome:
            MainTabView(path: $path)
        case .landlordHome:
            MainTabLandlordView(path: $path)
        }
    }
}
