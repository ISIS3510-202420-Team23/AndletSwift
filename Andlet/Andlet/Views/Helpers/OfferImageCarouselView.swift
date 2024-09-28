//
//  OfferDetailView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 16/09/24.
//

import SwiftUI
import FirebaseStorage

struct OfferImageCarouselView: View {
    let property: PropertyModel
    @State private var imageURLs: [URL] = []
    
    var body: some View {
        TabView {
            if imageURLs.isEmpty {
                // Placeholder cuando no hay imágenes
                Text("No images available")
            } else {
                ForEach(imageURLs, id: \.self) { url in
                    AsyncImage(url: url) { image in
                        image
                            .resizable()
                            .scaledToFill()
                    } placeholder: {
                        // Placeholder mientras se carga la imagen
                        ProgressView()
                    }
                }
            }
        }
        .tabViewStyle(.page)
        .onAppear {
            loadImages()
        }
    }
    
    func loadImages() {
        let storage = Storage.storage()
        var urls: [URL] = []
        
        // Iterar sobre las rutas de las imágenes en el array "photos"
        for photo in property.photos {
            let storageRef = storage.reference().child("properties/\(photo)")
            
            // Obtener la URL de descarga
            storageRef.downloadURL { url, error in
                if let error = error {
                    // Manejo de errores
                    print("Error al obtener la URL de la imagen \(photo): \(error.localizedDescription)")
                    return
                }
                
                if let url = url {
                    urls.append(url)
                    
                    // Actualizar el estado en el hilo principal
                    DispatchQueue.main.async {
                        imageURLs = urls
                    }
                } else {
                    print("Error: No se pudo obtener la URL para la imagen \(photo)")
                }
            }
        }
    }
    
}

//#Preview{
//    OfferImageCarouselView()
//}
