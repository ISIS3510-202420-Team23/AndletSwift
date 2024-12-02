import SwiftUI
import FirebaseAuth

struct HeaderNotificationsView: View {
    @StateObject var authViewModel = AuthenticationViewModel()
    @State private var isProfileViewActive = false
    @State private var userImage: UIImage?
    @StateObject private var networkMonitor = NetworkMonitor()
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Your")
                    .font(.custom("LeagueSpartan-ExtraBold", size: 32))
                    .foregroundColor(Color(hex: "FFB900"))
                    .fontWeight(.bold)
                
                // Mostrar solo el primer nombre del usuario desde Firestore
                Text("Notifications")
                    .font(.custom("LeagueSpartan-ExtraBold", size: 32))
                    .foregroundColor(Color(hex: "0C356A"))
                    .fontWeight(.bold)
            }
            Spacer()

//             Imagen de perfil del usuario desde el authViewModel
            if let photoURL = authViewModel.currentUser?.photo, !photoURL.isEmpty, networkMonitor.isConnected {
                AsyncImage(url: URL(string: photoURL)) { image in
                    image
                        .resizable()
                        .frame(width: 67, height: 67)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                        .onTapGesture {
                            isProfileViewActive = true
                        }
                } placeholder: {
                    // Placeholder mientras se carga la imagen
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 67, height: 67)
                        .onTapGesture {
                            isProfileViewActive = true
                        }
                }
            
            } else {
                // Placeholder si no hay imagen disponible (ícono predeterminado)
                Image("Icon")
                    .resizable()
                    .frame(width: 67, height: 67)
                    .clipShape(Circle())
                    .shadow(radius: 5)
                    .onTapGesture {
                        isProfileViewActive = true
                    }
            }
            
            // Navegación a la vista del perfil
            NavigationLink(destination: ProfileView(authViewModel: authViewModel), isActive: $isProfileViewActive) {
                EmptyView()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 3)
        .padding(.top, 55)
        .onAppear {
            // Llama a la función de verificación de usuario al cargar la vista
            authViewModel.checkIfUserIsLoggedIn()
            loadUserImage()
        }
    }

    // Función para obtener el primer nombre del usuario
    func getFirstName(fullName: String) -> String {
        return fullName.components(separatedBy: " ").first ?? fullName
    }
    
    private func loadUserImage() {
            guard networkMonitor.isConnected, let photoURL = authViewModel.currentUser?.photo, !photoURL.isEmpty else {
                return
            }
            
            downloadAndCacheImage(photoURL)
        }
        
    private func downloadAndCacheImage(_ url: String) {
        guard let photoURL = URL(string: url) else { return }
        URLSession.shared.dataTask(with: photoURL) { data, _, error in
            guard let data = data, let image = UIImage(data: data), error == nil else { return }
            
            DispatchQueue.main.async {
                self.userImage = image
                ImageCacheManager.shared.saveImageToCache(image, forKey: url)  // Guardar en caché
            }
        }.resume()
    }
}
