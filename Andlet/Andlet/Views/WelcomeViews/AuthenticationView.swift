import SwiftUI
import GoogleSignIn
import GoogleSignInSwift

@MainActor
struct AuthenticationView: View {
    var pages: [Page]
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var isLoading: Bool = false
    @State private var destination: NavigationDestination?  // Manage navigation state

    // Enum to manage different navigation destinations
    enum NavigationDestination: Hashable {
        case profilePicker
        case studentHome
        case landlordHome
    }

    var body: some View {
        if !isLoading {
            VStack(spacing: 20) {
                Spacer(minLength: 50)

                // Title
                Text(pages[1].title)
                    .font(.custom("LeagueSpartan-ExtraBold", size: 48).bold())
                    .foregroundColor(Color(hex: "#1B3A68"))
                    .multilineTextAlignment(.leading)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.leading, 27)

                // Subtitle
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

                    // Google Sign-In Button
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

                    // Divider with "Or log in with Email"
                    HStack {
                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.black)

                        Text("Or log in with Email")
                            .font(.custom("Montserrat-Regular", size: 15))
                            .foregroundColor(.black)

                        Rectangle()
                            .frame(height: 1)
                            .foregroundColor(Color.black)
                    }

                    // Log in with Google Button
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
                }

                Spacer()

                HStack {
                    CustomIndicatorView(totalPages: pages.count, currentPage: pages[1].tag)
                    Spacer()
                }
                .padding(.bottom, 70)
                .padding(.trailing, 20)
                .padding(.leading, 20)

                // Programmatic NavigationLink
                
            }
            .padding()
            .background(Color(hex: "#C5DDFF"))
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            
        }
        else{
            VStack {
                ProgressView("Atuhenticating...")
                    .progressViewStyle(CircularProgressViewStyle(tint: Color(red: 12/255, green: 53/255, blue: 106/255)))
                    .foregroundColor(Color(red: 12/255, green: 53/255, blue: 106/255))
                    .font(.headline)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                NavigationLink(
                    destination: getDestinationView(),  // Navigate based on destination
                    isActive: Binding(
                        get: { destination != nil },
                        set: { _ in destination = nil }  // Reset after navigation
                    )
                ) {
                    EmptyView()  // Invisible NavigationLink
                }
            }
            .navigationBarBackButtonHidden(true)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color(red: 197/255, green: 221/255, blue: 255/255))
            .transition(.opacity) // Añadir transición de opacidad
        }
        
        
    }

    // Google Sign-In logic
    private func signInWithGoogle() {
        Task {
            isLoading = true
            let isSuccess = await authViewModel.signInWithGoogle()
            if isSuccess {
                // Set the destination based on user role after sign-in
                if let user = authViewModel.currentUser {
                    switch user.typeUser {
                    case .notDefined:
                        destination = .profilePicker
                    case .student:
                        destination = .studentHome
                    case .landlord:
                        destination = .landlordHome
                    }
                }
            }
        }
    }

    // Function to get the correct destination view
    @ViewBuilder
    private func getDestinationView() -> some View {
        switch destination {
        case .profilePicker:
            ProfilePickerView(authViewModel: authViewModel)
        case .studentHome:
            MainTabView()
        case .landlordHome:
            MainTabLandlordView()
        case .none:
            EmptyView()
        }
    }
}
