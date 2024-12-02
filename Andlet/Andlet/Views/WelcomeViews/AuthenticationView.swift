import SwiftUI
import GoogleSignIn
import GoogleSignInSwift
import Network

class ConnectivityChecker: ObservableObject {
    @Published var isConnected: Bool = true
    private var monitor: NWPathMonitor
    private let queue = DispatchQueue(label: "NetworkMonitor")

    init() {
        self.monitor = NWPathMonitor()
        self.startMonitoring()
    }

    deinit {
        monitor.cancel()
    }

    private func startMonitoring() {
        monitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
            }
        }
        monitor.start(queue: queue)
    }
}


@MainActor
struct AuthenticationView: View {
    var pages: [Page]
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    @ObservedObject var authViewModel: AuthenticationViewModel
    @State private var isLoading: Bool = false
    @State private var destination: NavigationDestination?  // Manage navigation state
    @State private var errorMessage: String? = nil  // To display errors
    @StateObject private var connectivityChecker: ConnectivityChecker = ConnectivityChecker()

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
                    }

                    // Google Sign-In Button
                    Button(action: checkConnectivityBeforeSignIn) {
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
                    Button(action: checkConnectivityBeforeSignIn) {
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

            }
            .padding()
            .background(Color(hex: "#C5DDFF"))
            .edgesIgnoringSafeArea(.all)
            .navigationBarHidden(true)
            .alert(isPresented: Binding(get: { errorMessage != nil }, set: { _ in errorMessage = nil })) {
                Alert(
                    title: Text(connectivityChecker.isConnected ? "Authentication Error" : "Connection Error"),
                    message: Text(errorMessage ?? "Unknown error"),
                    dismissButton: .default(Text("OK"))
                )
            }
        } else {
            VStack {
                ProgressView("Authenticating...")
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                    .foregroundColor(primaryColor)
                    .font(.headline)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
                    .shadow(radius: 10)
                NavigationLink(
                    destination: getDestinationView(),
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
            .transition(.opacity)
        }
    }
    private func checkConnectivityBeforeSignIn() {
        if connectivityChecker.isConnected {
            signInWithGoogle()
        } else {
            errorMessage = "No internet connection. Please connect to the internet and try again."
        }
    }

    // Google Sign-In logic with error handling
    private func signInWithGoogle() {
        Task {
            isLoading = true
            errorMessage = nil  // Reset any previous error message
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
            } else {
                // If sign-in failed, reset loading and show an error message
                isLoading = false
                if !authViewModel.errorMessage.isEmpty {
                    if authViewModel.errorMessage.contains("Network error") {
                        errorMessage = "There was a connection issue. Please try again later."
                        
                    }
                    else{
                        errorMessage = authViewModel.errorMessage
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
