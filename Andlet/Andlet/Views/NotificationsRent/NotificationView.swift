//
//  NotificationView.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 18/11/24.
//

import SwiftUI

struct NotificationView: View {
    let imageKey: String
    let title: String
    let message: String
    let date: String
    
    @State private var uiImage: UIImage?

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Fondo principal de la notificación
            HStack(alignment: .top, spacing: 12) {
                // Imagen del inmueble
                if let uiImage = uiImage {
                    Image(uiImage: uiImage)
                        .resizable()
                        .scaledToFill()
                        .frame(width: 60, height: 60)
                        .clipShape(Circle())
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                } else {
                    
                    // Placeholder mientras se carga la imagen
                    Circle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(width: 60, height: 60)
                        .overlay(Circle().stroke(Color.white, lineWidth: 2))
                        .overlay(
                            ProgressView()
                                .progressViewStyle(CircularProgressViewStyle())
                        )
                }
                // Contenido textual
                VStack(alignment: .leading, spacing: 4) {
                    Text(title) // Título
                        .font(.custom("LeagueSpartan-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "0C356A"))
                        .lineLimit(1)
                    
                    Text(message) // Mensaje
                        .font(.custom("LeagueSpartan-Light", size: 16))
                        .foregroundColor(.black)
                        .lineLimit(2)
                    
                    HStack {
                        Spacer() // Empuja la fecha hacia la derecha
                        Text(date)
                            .font(.custom("LeagueSpartan-Thin", size: 12))
                            .foregroundColor(.gray)
                    }
                }
                Spacer()
            }
            .padding()
            .background(Color(hex: "FFFAE5"))
            .cornerRadius(15)
            .overlay(
                RoundedRectangle(cornerRadius: 15)
                    .stroke(Color(hex: "0C356A"), lineWidth: 1)
            )
            
            
            // Listón azul en la esquina superior izquierda
            Rectangle()
                .fill(Color(hex: "0C356A")) // Color azul
                .frame(width: 20, height: 40) // Tamaño del listón
                .cornerRadius(5, corners: [.topRight, .bottomRight])
                .offset(x: -10, y: 10) // Posición del listón
        }
        .padding(.horizontal)
        .onAppear {
            loadImage()
        }
    }
private func loadImage() {
        ImageCacheManager.shared.getImage(forKey: imageKey) { image in
            DispatchQueue.main.async {
                self.uiImage = image
            }
        }
    }
}
 
