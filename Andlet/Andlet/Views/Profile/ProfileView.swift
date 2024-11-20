import SwiftUI

extension Color {
    static let customDarkGray = Color(red: 60 / 255, green: 60 / 255, blue: 60 / 255)
    
    static let greyDivider = Color(red: 151 / 255, green: 151 / 255, blue: 151 / 255)
    
    static let showGrey = Color(red: 73 / 255, green: 69 / 255, blue: 79 / 255)
}

struct ProfileView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel
    var userImageURL: String?
    @State private var isUserSignedOut = false
    @State private var showPendingAlert = false
    @StateObject private var networkMonitor = NetworkMonitor()

    @State private var isAccordionExpanded = false
    @State private var isHowItWorksExpanded = false
    @State private var isFeedbackExpanded = false
    @State private var isPrivacyPolicyExpanded = false
    @State private var feedbackText = ""

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 16) {
                // Back Button and Title
                Button(action: {
                    isUserSignedOut = true
                }) {
                    Image(systemName: "arrow.left")
                        .font(.title2)
                        .foregroundColor(Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255))
                }
                .padding(.top)

                Text("Profile")
                    .font(.custom("League Spartan", size: 32))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255))
                    .padding(.top, 8)

                // User's Profile Picture and Info with Accordion
                VStack(alignment: .leading, spacing: 8) {
                    HStack(spacing: 16) {
                        // Profile Picture
                        if let userImageURL = authViewModel.currentUser?.photo,
                           !userImageURL.isEmpty,
                           networkMonitor.isConnected,
                           let url = URL(string: userImageURL) {
                            AsyncImage(url: url) { phase in
                                switch phase {
                                case .success(let image):
                                    image
                                        .resizable()
                                        .aspectRatio(contentMode: .fill)
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                case .failure(_):
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .foregroundColor(.customDarkGray)
                                case .empty:
                                    ProgressView()
                                @unknown default:
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 50, height: 50)
                                        .clipShape(Circle())
                                        .foregroundColor(.customDarkGray)
                                }
                            }
                        } else {
                            Image("Icon")
                                .resizable()
                                .frame(width: 50, height: 50)
                                .clipShape(Circle())
                                .foregroundColor(.customDarkGray)
                        }

                        // User Information
                        VStack(alignment: .leading, spacing: 4) {
                            let firstName = authViewModel.currentUser?.name.split(separator: " ").first.map(String.init) ?? "User"
                            Text(firstName)
                                .font(.custom("League Spartan", size: 20))
                                .foregroundColor(.black)

                            Button(action: {
                                withAnimation {
                                    isAccordionExpanded.toggle()
                                }
                            }) {
                                HStack {
                                    Text("Show Profile")
                                        .font(.custom("League Spartan", size: 14))
                                        .foregroundColor(.showGrey)
                                    Spacer()
                                    Image(systemName: isAccordionExpanded ? "chevron.down" : "chevron.right")
                                        .font(.headline)
                                        .foregroundColor(.customDarkGray)
                                }
                            }
                            .buttonStyle(PlainButtonStyle())
                        }

                        Spacer()
                    }

                    if isAccordionExpanded {
                        VStack(alignment: .leading, spacing: 8) {
                            HStack {
                                Text("Legal Name")
                                    .font(.custom("League Spartan", size: 16))
                                    .foregroundColor(.black)
                                Spacer()
                                Text("Email")
                                    .font(.custom("League Spartan", size: 16))
                                    .foregroundColor(.black)
                            }

                            HStack {
                                Text(authViewModel.currentUser?.name ?? "User Name")
                                    .font(.custom("League Spartan", size: 16))
                                    .foregroundColor(.customDarkGray)
                                Spacer()
                                Text(authViewModel.currentUser?.id ?? "user@example.com")
                                    .font(.custom("League Spartan", size: 16))
                                    .foregroundColor(.customDarkGray)
                            }
                        }
                        .padding(.top, 16)
                        .transition(.opacity)
                    }
                }

                Divider()
                    .frame(height: 1)
                    .background(Color.greyDivider)
                    .padding(.vertical, 16)

                Text("Options")
                    .font(.custom("League Spartan", size: 28))
                    .fontWeight(.bold)
                    .foregroundColor(Color(red: 12 / 255, green: 53 / 255, blue: 106 / 255))

                // How Andlet Works
                createOptionSection(
                    icon: "info.circle",
                    title: "How Andlet works?",
                    isExpanded: $isHowItWorksExpanded,
                    content: {
                        Text("""
                            Andlet connects students and landlords through a secure, user-friendly platform that simplifies housing searches near Los Andes University. Students create profiles, set preferences, and explore verified listings using advanced filters, while landlords manage and update properties seamlessly.
                            """)
                        .font(.custom("League Spartan", size: 14))
                        .foregroundColor(.black)
                        .multilineTextAlignment(.leading)
                        .fixedSize(horizontal: false, vertical: true)
                        .padding(.top, 8)
                    }
                )

                Divider()
                    .frame(height: 1)
                    .background(Color.greyDivider)

                // Give Us Feedback
                createOptionSection(
                    icon: "pencil.circle",
                    title: "Give us feedback",
                    isExpanded: $isFeedbackExpanded,
                    content: {
                        CustomFeedbackInputField(
                            placeholder: "Awesome feedback",
                            text: $feedbackText,
                            maxCharacters: 200,
                            height: 100,
                            cornerRadius: 8
                        )
                    }
                )

                Divider()
                    .frame(height: 1)
                    .background(Color.greyDivider)

                // Privacy Policy
                createOptionSection(
                    icon: "shield.checkerboard",
                    title: "Privacy policy",
                    isExpanded: $isPrivacyPolicyExpanded,
                    content: {
                        VStack(alignment: .leading, spacing: 8) {
                            Text("""
                                Andlet ("we," "our," or "us") is committed to protecting your privacy. This Privacy Policy explains how we collect, use, and safeguard your information when you use our app. By using Andlet, you agree to the terms outlined below.
                                """)
                            .font(.custom("League Spartan", size: 14))
                            .foregroundColor(.black)
                            .multilineTextAlignment(.leading)
                            .fixedSize(horizontal: false, vertical: true)

                            Text("1. Information We Collect")
                                .font(.custom("League Spartan", size: 14))
                                .fontWeight(.bold)
                                .foregroundColor(.black)

                            VStack(alignment: .leading, spacing: 4) {
                                Text("• Personal Information: Name, email address and profile photo, provided during registration.")
                                Text("• Location Data: Your location, if you grant permission, to provide location-based features.")
                                Text("• Usage Data: Information about how you interact with the app, including search preferences, saved listings, and communication with landlords.")
                            }
                            .font(.custom("League Spartan", size: 14))
                            .foregroundColor(.black)
                        }
                    }
                )

                Divider()
                    .frame(height: 1)
                    .background(Color.greyDivider)

                Spacer(minLength: 50)

                // Log Out Option
                VStack {
                    HStack {
                        Image(systemName: "arrow.right.circle")
                            .foregroundColor(.customDarkGray)
                        Button(action: {
                            checkPendingPropertyBeforeSignOut()
                        }) {
                            Text("Log out")
                                .font(.custom("League Spartan", size: 15))
                                .foregroundColor(.customDarkGray)
                                .underline()
                        }
                        Spacer()
                    }
                    Divider()
                        .frame(height: 1)
                        .background(Color.greyDivider)
                }
            }
            .padding()
            .alert(isPresented: $showPendingAlert) {
                Alert(
                    title: Text("Pending Property"),
                    message: Text("You have a property pending to be published. Please connect to the internet to complete the upload before signing out."),
                    dismissButton: .default(Text("OK"))
                )
            }
        }
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

    private func checkPendingPropertyBeforeSignOut() {
        if let pendingProperty = PropertyOfferData().loadFromJSON() {
            showPendingAlert = true
        } else {
            signOutUser()
        }
    }

    private func signOutUser() {
        authViewModel.signOut()
        authViewModel.isAuthenticated = false
        isUserSignedOut = true
    }
}

struct ProfileView_Previews: PreviewProvider {
    static var previews: some View {
        ProfileView(authViewModel: AuthenticationViewModel())
    }
}
