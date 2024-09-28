//
//  Heading.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 16/09/24.
//

import SwiftUI
import FirebaseAuth

struct Heading: View {
    let currentUser = Auth.auth().currentUser
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
            if let photoURL = currentUser?.photoURL {
    
                AsyncImage(url: photoURL) { image in
                    image
                        .resizable()
                        .frame(width: 67, height: 67)
                        .clipShape(Circle())
                        .shadow(radius: 5)
                } placeholder: {
                    // Placeholder mientras se carga la imagen
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 67, height: 67)
                }
            } else {
                // Placeholder si no hay imagen disponible
                Circle()
                    .fill(Color.gray.opacity(0.3))
                    .frame(width: 67, height: 67)
            }
        }
        .padding(.horizontal)
        .padding(.bottom, 3)
        .padding(.top, 5)
        .onAppear {
                    // Si quieres ver el photoURL, lo puedes imprimir aquí
                    if let photoURL = currentUser?.photoURL {
                        print("AQUI ESTA LA FOTO")
                        print(photoURL)
                    }
                    if let user = currentUser {
                            print("Información completa del usuario:")
                            print(user)
                        }
                }
    }
}

#Preview {
    Heading()
}
