import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    var userImageURL: String?  // URL for the user's image
    @State private var isUserSignedOut = false  // Trigger for navigation
    @State private var showPendingAlert = false  // Estado para mostrar alerta de propiedad pendiente
    @StateObject private var networkMonitor = NetworkMonitor()

    var body: some View {
        NavigationStack {
            VStack {
                Spacer()

                // Load the user's image (from URL or default image)
                if let userImageURL = authViewModel.currentUser?.photo, !userImageURL.isEmpty, networkMonitor.isConnected, let url = URL(string: userImageURL) {
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
                    Image("Icon")
                        .resizable()
                        .frame(width: 150, height: 150)
                        .clipShape(Circle())
                        .foregroundColor(.gray)
                        .padding(.bottom, 40)
                }

                // Sign Out Button
                Button(action: {
                    checkPendingPropertyBeforeSignOut()  // Comprobar propiedad pendiente antes de intentar cerrar sesión
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
            // Mostrar la alerta si hay una propiedad pendiente
            .alert(isPresented: $showPendingAlert) {
                Alert(
                    title: Text("Pending Property"),
                    message: Text("You have a property pending to be published. Please connect to the internet to complete the upload before signing out."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
    }

    // Verificar si hay una propiedad pendiente antes de cerrar sesión
    private func checkPendingPropertyBeforeSignOut() {
        if let pendingProperty = PropertyOfferData().loadFromJSON() {  // Comprobar si hay datos sin publicar
            print("Pending property found: \(pendingProperty)")
            showPendingAlert = true  // Mostrar alerta para impedir el cierre de sesión
        } else {
            signOutUser()  // Procede con el cierre de sesión si no hay pendientes
        }
    }

    // Sign out logic
    private func signOutUser() {
        authViewModel.signOut()  // Sign out the user
        authViewModel.isAuthenticated = false
        isUserSignedOut = true  // Trigger navigation to WelcomePageView
    }
}
