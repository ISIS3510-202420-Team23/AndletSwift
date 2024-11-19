//
//  NotificationView.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 18/11/24.
//

import SwiftUI

struct NotificationView: View {
    let image: String
    let title: String
    let message: String
    let date: String

    var body: some View {
        ZStack(alignment: .topLeading) {
            // Fondo principal de la notificación
            HStack(alignment: .top, spacing: 12) {
                // Imagen del inmueble
                Image(image)
                    .resizable()
                    .scaledToFill()
                    .frame(width: 60, height: 60)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.white, lineWidth: 2))
        

                // Contenido textual
                VStack(alignment: .leading, spacing: 4) {
                    Text(title) // Título
                        .font(.custom("LeagueSpartan-SemiBold", size: 16))
                        .foregroundColor(Color(hex: "0C356A"))
                        .lineLimit(1)

                    Text(message) // Mensaje
                        .font(.custom("LeagueSpartan-Light", size: 14))
                        .foregroundColor(.black)
                        .lineLimit(2)

                    Text(date) // Fecha
                        .font(.custom("LeagueSpartan-Thin", size: 12))
                        .foregroundColor(.gray)
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
    }
}


struct Notifications2View: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // Datos falsos para previsualizar las notificaciones
                NotificationView(
                    image: "exampleImage1", // Cambiar al nombre de una imagen en el Assets
                    title: "Apartment - T2 - 1102",
                    message: "2 people have saved your property in the last day.",
                    date: "01/08/2024 16:45:14"
                )
                NotificationView(
                    image: "exampleImage2",
                    title: "Beautiful house",
                    message: "4 people have saved your property in the last day.",
                    date: "02/08/2024 10:30:00"
                )
                NotificationView(
                    image: "exampleImage3",
                    title: "Cozy Studio",
                    message: "1 person saved your property recently.",
                    date: "03/08/2024 08:15:22"
                )
            }
            .padding()
        }
        .navigationTitle("Notifications")
        .navigationBarTitleDisplayMode(.inline)
    }
}

