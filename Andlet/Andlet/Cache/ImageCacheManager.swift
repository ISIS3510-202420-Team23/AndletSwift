//
//  ImageCacheManager.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 16/10/24.
//

import SwiftUI
import FirebaseStorage
import Combine

class ImageCacheManager {
    static let shared = ImageCacheManager()
    private var cache = NSCache<NSString, UIImage>()
    
    // Función para obtener la imagen desde el caché o descargarla si no está en caché
    func getImage(forKey key: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: key as NSString) {
            // Si la imagen ya está en caché, devolverla
            completion(cachedImage)
        } else {
            // Si no está en caché, descargarla
            let storage = Storage.storage().reference().child("properties/\(key)")
            storage.downloadURL { url, error in
                guard let url = url, error == nil else {
                    print("Error al obtener la URL de la imagen \(key): \(String(describing: error))")
                    completion(nil)
                    return
                }
                
                // Descargar la imagen desde la URL
                URLSession.shared.dataTask(with: url) { data, response, error in
                    guard let data = data, let image = UIImage(data: data), error == nil else {
                        print("Error al descargar la imagen \(key): \(String(describing: error))")
                        completion(nil)
                        return
                    }
                    
                    // Almacenar la imagen en el caché
                    self.cache.setObject(image, forKey: key as NSString)
                    DispatchQueue.main.async {
                        completion(image)
                    }
                }.resume()
            }
        }
    }
}
