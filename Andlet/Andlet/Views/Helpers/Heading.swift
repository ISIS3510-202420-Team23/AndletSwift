//
//  Heading.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 16/09/24.
//

import SwiftUI
import FirebaseAuth

struct Heading: View {
    // TODO: CHANGED TO THE PERSISTANT USER
    let currentUser = Auth.auth().currentUser
    @State private var isProfileViewActive = false
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("Welcome,")
                    .font(.custom("LeagueSpartan-ExtraBold", size: 32))
                    .foregroundColor(Color(hex: "0C356A"))
                    .fontWeight(.bold)
                Text("\(currentUser?.displayName?.components(separatedBy: " ").first ?? "")")
                    .font(.custom("LeagueSpartan-ExtraBold", size: 32))
                    .foregroundColor(Color(hex: "FFB900"))
                    .fontWeight(.bold)
                
            }
            Spacer()
            // Imagen de perfil
            let photoURL = currentUser?.photoURL
            if  (photoURL != nil){
    
                AsyncImage(url: photoURL) { image in
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
                }
            } else {
                // Placeholder si no hay imagen disponible
                Image("Icon")
                                    .resizable()
                                    .frame(width: 67, height: 67)
                                    .clipShape(Circle())
                                    .shadow(radius: 5)
            }
            NavigationLink(destination: ProfileView(authViewModel: AuthenticationViewModel()), isActive: $isProfileViewActive){
                
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 3)
        .padding(.top, 55)
                }
                
               
            }
//#Preview {
//    Heading()
//}
