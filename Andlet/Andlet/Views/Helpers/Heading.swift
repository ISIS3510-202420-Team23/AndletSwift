import SwiftUI
import FirebaseAuth

struct Heading: View {
    @StateObject var authViewModel = AuthenticationViewModel() // Usamos el view model para obtener la info del usuario desde Firestore
    @State private var isProfileViewActive = false
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Welcome,")
                    .font(.custom("LeagueSpartan-ExtraBold", size: 32))
                    .foregroundColor(Color(hex: "0C356A"))
                    .fontWeight(.bold)
                
                // Mostrar solo el primer nombre del usuario desde Firestore
                Text(getFirstName(fullName: authViewModel.currentUser?.name ?? "Guest"))
                    .font(.custom("LeagueSpartan-ExtraBold", size: 32))
                    .foregroundColor(Color(hex: "FFB900"))
                    .fontWeight(.bold)
            }
            Spacer()

            // Imagen de perfil del usuario desde el authViewModel
            if let photoURL = authViewModel.currentUser?.photo, !photoURL.isEmpty {
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
            NavigationLink(destination: ProfileView(authViewModel: authViewModel, userImageURL: authViewModel.currentUser?.photo), isActive: $isProfileViewActive) {
                EmptyView()
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 3)
        .padding(.top, 55)
        .onAppear {
            // Llama a la función de verificación de usuario al cargar la vista
            authViewModel.checkIfUserIsLoggedIn()
        }
    }

    // Función para obtener el primer nombre del usuario
    func getFirstName(fullName: String) -> String {
        return fullName.components(separatedBy: " ").first ?? fullName
    }
}
