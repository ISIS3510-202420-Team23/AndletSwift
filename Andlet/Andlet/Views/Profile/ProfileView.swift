import SwiftUI

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    @StateObject private var bugViewModel = BugViewModel()
    @StateObject private var networkMonitor = NetworkMonitor()
    let primaryColor = Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255)
    @State private var isLoading = false
    @State private var isUserSignedOut = false
    @State private var showPendingAlert = false
    @State private var isAccordionExpanded = false
    @State private var isHowItWorksExpanded = false
    @State private var isBugExpanded = false
    @State private var isPrivacyPolicyExpanded = false
    @State private var bugText = ""
    @State private var notificationMessage: String?
    @State private var notificationColor: Color?
    @Environment(\.dismiss) var dismiss
    
    var body: some View {
        NavigationStack {
            ZStack {
                // Fondo principal
                Color.white
                    .ignoresSafeArea()
                    .onTapGesture { hideKeyboard() }

                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        // Botón de regreso y título
                        HStack {
                            backButton
                            Spacer()
                        }
                        
                        Text("Profile")
                            .font(.custom("League Spartan", size: 32))
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                            .padding(.top, 8)
                        
                        // Información del usuario
                        profileSection
                        
                        Divider().frame(height: 1).background(Color.greyDivider).padding(.vertical, 16)
                        
                        Text("Options")
                            .font(.custom("League Spartan", size: 28))
                            .fontWeight(.bold)
                            .foregroundColor(primaryColor)
                        
                        // Secciones de opciones
                        createOptionSection(icon: "info.circle", title: "How Andlet works?", isExpanded: $isHowItWorksExpanded) {
                            optionContent(text: """
                                    Andlet connects students and landlords through a secure, user-friendly platform that simplifies housing searches near Los Andes University. Students create profiles, set preferences, and explore verified listings using advanced filters, while landlords manage and update properties seamlessly.
                                    """)
                        }
                        
                        Divider().frame(height: 1).background(Color.greyDivider)
                        
                        createOptionSection(icon: "pencil.circle", title: "Report a bug", isExpanded: $isBugExpanded) {
                            CustomBugInputField(
                                placeholder: "Awesome report...",
                                text: $bugText,
                                maxCharacters: 200,
                                height: 100,
                                cornerRadius: 8,
                                onSubmit: submitBug,
                                notificationMessage: $notificationMessage,
                                notificationColor: $notificationColor,
                                isConnected: networkMonitor.isConnected
                            )
                        }
                        
                        Divider().frame(height: 1).background(Color.greyDivider)
                        
                        createOptionSection(icon: "shield.checkerboard", title: "Privacy policy", isExpanded: $isPrivacyPolicyExpanded) {
                            Text("""
                                        **Andlet** ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our app. By using Andlet, you agree to the terms outlined below.

                                        **1. Information We Collect**
                                        • Personal Information: Name, email address, profile photo, and university affiliation, provided during registration.
                                        • Location Data: Your location, if you grant permission, to provide location-based features.
                                        • Usage Data: Information about how you interact with the app, including search preferences, saved listings, and communication with landlords.

                                        **2. How We Use Your Information**
                                        We use your information to:
                                        • Provide, personalize, and improve the app experience.
                                        • Match you with housing options tailored to your preferences.
                                        • Facilitate communication between students and landlords.
                                        • Send notifications about updates, new listings, or app features.
                                        • Ensure trust and security by verifying user profiles and listings.

                                        **3. Sharing Your Information**
                                        We do not sell your personal information. However, we may share your information:
                                        • With landlords: When you interact with a listing, landlords may see limited details like your name and contact information.
                                        • With service providers: Trusted third-party services that help us operate the app (e.g., hosting, analytics).
                                        • As required by law: To comply with legal obligations or enforce our policies.

                                        **4. Data Security**
                                        We take appropriate technical and organizational measures to protect your data against unauthorized access, loss, or misuse. However, no system is completely secure, and we cannot guarantee the absolute security of your data.

                                        **5. Your Rights**
                                        You have the right to:
                                        • Access and update your personal information.
                                        • Request the deletion of your account and associated data.
                                        • Control your privacy settings, such as location-sharing permissions.
                                        • Opt out of non-essential communications.
                                        To exercise these rights, please contact us at [Insert Support Email].

                                        **6. Third-Party Links**
                                        Andlet may contain links to third-party websites or services. We are not responsible for their privacy practices or content. Please review their privacy policies before sharing any information.

                                        **7. Changes to This Privacy Policy**
                                        We may update this Privacy Policy from time to time. Any changes will be posted in the app, and your continued use of Andlet constitutes acceptance of the updated policy.

                                        **8. Contact Us**
                                        If you have any questions or concerns about this Privacy Policy, please contact us at support-andlet@gmail.com.
                                        """)
                                .font(.custom("League Spartan", size: 14))
                                .foregroundColor(.black)
                        }
                        
                        Divider().frame(height: 1).background(Color.greyDivider)
                        
                        Spacer(minLength: 220)
                        
                        // Cerrar sesión
                        logoutSection
                    }
                    .padding()
                    .alert(isPresented: $showPendingAlert) {
                        Alert(
                            title: Text("Pending Property"),
                            message: Text("You have a property pending to be published."),
                            dismissButton: .default(Text("OK"))
                        )
                    }
                }
                
                // Cargando...
                if isLoading { loadingView }
                
                // Notificación
                if let message = notificationMessage, let color = notificationColor {
                    notificationView(message: message, color: color)
                }
            }
            .navigationBarHidden(true)
        }
    }
    
    // MARK: - Subviews

    private var backButton: some View {
        Button(action: { dismiss() }) {
            Image(systemName: "arrow.left")
                .font(.title2)
                .foregroundColor(primaryColor)
        }
        .padding(.top)
    }

    private var profileSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack(spacing: 16) {
                profileImageView(for: authViewModel.currentUser?.photo)
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(userFirstName)
                        .font(.custom("League Spartan", size: 20))
                        .foregroundColor(.black)
                    
                    toggleButton(title: "Show Profile", isExpanded: $isAccordionExpanded)
                }
                
                Spacer()
            }
            
            if isAccordionExpanded {
                VStack(alignment: .leading, spacing: 8) {
                    userInfoRow(title: "Legal Name", value: userName)
                    userInfoRow(title: "Email", value: userEmail)
                }
                .padding(.top, 16)
                .transition(.opacity)
            }
        }
    }

    private var logoutSection: some View {
        VStack {
            HStack {
                Image(systemName: "arrow.right.circle").foregroundColor(.customDarkGray)
                Button(action: checkPendingPropertyBeforeSignOut) {
                    Text("Log out")
                        .font(.custom("League Spartan", size: 15))
                        .foregroundColor(.customDarkGray)
                        .underline()
                }
                Spacer()
            }
            Divider().frame(height: 1).background(Color.greyDivider)
        }
    }
    
    private var loadingView: some View {
        ZStack {
            Color(red: 0.9, green: 0.95, blue: 1.0)
                .ignoresSafeArea()
            VStack(spacing: 20) {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: primaryColor))
                    .scaleEffect(2)
                Text("Uploading Bug Report...")
                    .font(.headline)
                    .foregroundColor(primaryColor)
            }
        }
    }
    
    // MARK: - Helper Views and Functions

    private func profileImageView(for url: String?) -> some View {
        if let url = url, !url.isEmpty, networkMonitor.isConnected, let imageURL = URL(string: url) {
            return AnyView(
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .success(let image):
                        image.resizable().aspectRatio(contentMode: .fill).frame(width: 50, height: 50).clipShape(Circle())
                    case .failure:
                        defaultProfileImage
                    case .empty:
                        ProgressView()
                    @unknown default:
                        defaultProfileImage
                    }
                }
            )
        } else {
            return AnyView(defaultProfileImage)
        }
    }
    
    private var defaultProfileImage: some View {
        Image(systemName: "person.circle.fill")
            .resizable()
            .frame(width: 50, height: 50)
            .clipShape(Circle())
            .foregroundColor(.customDarkGray)
    }
    
    private var userFirstName: String {
        authViewModel.currentUser?.name.split(separator: " ").first.map(String.init) ?? "User"
    }

    private var userName: String {
        authViewModel.currentUser?.name ?? "User Name"
    }

    private var userEmail: String {
        authViewModel.currentUser?.id ?? "user@example.com"
    }

    private func toggleButton(title: String, isExpanded: Binding<Bool>) -> some View {
        Button(action: {
            withAnimation { isExpanded.wrappedValue.toggle() }
        }) {
            HStack {
                Text(title)
                    .font(.custom("League Spartan", size: 14))
                    .foregroundColor(.showGrey)
                Spacer()
                Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.right")
                    .font(.headline)
                    .foregroundColor(.customDarkGray)
            }
        }
    }

    private func userInfoRow(title: String, value: String) -> some View {
        HStack {
            Text(title).font(.custom("League Spartan", size: 16)).foregroundColor(.black)
            Spacer()
            Text(value).font(.custom("League Spartan", size: 16)).foregroundColor(.customDarkGray)
        }
    }

    private func notificationView(message: String, color: Color) -> some View {
        VStack {
            Text(message)
                .foregroundColor(.white)
                .font(.system(size: 14, weight: .medium))
                .padding()
                .background(color)
                .cornerRadius(10)
                .shadow(radius: 5)
                .frame(maxWidth: 300)
                .transition(.opacity)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                withAnimation {
                    notificationMessage = nil
                    notificationColor = nil
                }
            }
        }
    }
    
    private func optionContent(text: String) -> some View {
        Text(text)
            .font(.custom("League Spartan", size: 14))
            .foregroundColor(.black)
            .padding(.top, 8)
    }

        private func createOptionSection<Content: View>(icon: String, title: String, isExpanded: Binding<Bool>, @ViewBuilder content: @escaping () -> Content) -> some View {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Image(systemName: icon)
                        .foregroundColor(.customDarkGray)
                    Button(action: {
                        withAnimation {
                            isExpanded.wrappedValue.toggle()
                        }
                    }) {
                        HStack {
                            Text(title)
                                .font(.custom("League Spartan", size: 15))
                                .foregroundColor(.customDarkGray)
                            Spacer()
                            Image(systemName: isExpanded.wrappedValue ? "chevron.down" : "chevron.right")
                                .font(.headline)
                                .foregroundColor(.customDarkGray)
                        }
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                if isExpanded.wrappedValue {
                    content()
                        .padding(.top, 8)
                        .transition(.opacity)
                }
            }
        .padding(.vertical, 8)
    }

    private func submitBug(_ bug: String) {
        guard networkMonitor.isConnected else {
            withAnimation {
                notificationMessage = "⚠️ No Internet Connection, you cannot submit bug while you are offline."
                notificationColor = .orange
            }
            return
        }

        guard !bug.isEmpty else {
            withAnimation {
                notificationMessage = "Bug cannot be empty. Please write something."
                notificationColor = .red.opacity(0.8)
            }
            return
        }

        isLoading = true // Mostrar la pantalla de carga

        bugViewModel.submitBug(bug) { result in
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) { // Reducir tiempo de simulación
                isLoading = false // Ocultar pantalla de carga
                switch result {
                case .success:
                    bugText = "" // Limpia el campo de texto
                    withAnimation {
                        notificationMessage = "Bug submitted successfully."
                        notificationColor = .green
                    }
                case .failure:
                    withAnimation {
                        notificationMessage = "There was an error submitting your bug."
                        notificationColor = .red.opacity(0.8)
                    }
                }
            }
        }
    }

    private func checkPendingPropertyBeforeSignOut() {
        if let pendingProperty = PropertyOfferData().loadFromJSON() {
            print("Pending property found: \(pendingProperty)")
            showPendingAlert = true
        } else {
            signOutUser()
        }
    }

    private func signOutUser() {
        authViewModel.signOut()
        authViewModel.isAuthenticated = false
        isUserSignedOut = true // Trigger NavigationLink
    }
    }

    struct ProfileView_Previews: PreviewProvider {
        static var previews: some View {
            ProfileView(authViewModel: AuthenticationViewModel())
        }

}
