import SwiftUI

struct ProfilePickerView: View {
    @ObservedObject var authViewModel: AuthenticationViewModel

    // Enum to manage different destinations
    enum NavigationDestination: Hashable {
        case studentHome
        case landlordHome
    }

    @State private var navigateToStudentHome = false
    @State private var navigateToLandlordHome = false

    var body: some View {
        VStack {
            // Top Section: Title
            VStack(alignment: .leading, spacing: 8) {
                Text("Let's start!\nFirst...")
                    .font(.custom("LeagueSpartan-ExtraBold", size: 45))
                    .foregroundColor(Color(hex: "#1B3A68"))
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
            .padding(.horizontal)
            .padding(.top, 60)

            Spacer()

            // Middle Section: Question and Buttons
            VStack(spacing: 20) {
                Text("What are you\nlooking for?")
                    .font(.custom("Montserrat-Light", size: 22))
                    .foregroundColor(Color(hex: "#1B3A68"))
                    .multilineTextAlignment(.center)

                // Button for "I want to rent a place!"
                NavigationLink(
                    destination: MainTabView(),
                    isActive: $navigateToStudentHome) {
                        Button(action: {
                            saveUserRole(role: .student)
                            navigateToStudentHome = true
                        }) {
                            Text("I want to rent a place!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 280, height: 50)
                                .background(Color(hex: "#F7B500"))  // Yellow background
                                .cornerRadius(25)  // Rounded button
                        }
                    }

                // Button for "I want to list my place!"
                NavigationLink(
                    destination: MainTabLandlordView(),
                    isActive: $navigateToLandlordHome) {
                        Button(action: {
                            saveUserRole(role: .landlord)
                            navigateToLandlordHome = true
                        }) {
                            Text("I want to list my place!")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(width: 280, height: 50)
                                .background(Color(hex: "#1B3A68"))  // Dark blue background
                                .cornerRadius(25)  // Rounded button
                        }
                    }
            }

            Spacer()  // Pushes the content up from the bottom

            // Bottom Section: Custom Page Indicator
            HStack {
                CustomIndicatorView(totalPages: 3, currentPage: 2)
                Spacer()
            }
            .padding(.bottom, 70)
            .padding(.leading, 40)
        }
        .padding()
        .background(Color(hex: "#C5DDFF"))  // Light blue background
        .edgesIgnoringSafeArea(.all)  // Full-screen background
        .navigationBarBackButtonHidden(true)
    }

    // Save the user role and navigate accordingly
    private func saveUserRole(role: UserType) {
        if let currentUserEmail = authViewModel.currentUser?.id {
            Task {
                await authViewModel.addUserRole(userEmail: currentUserEmail, role: role)
            }
        }
    }
}
