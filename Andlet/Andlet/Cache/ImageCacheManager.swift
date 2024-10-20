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
    
    private let fileManager = FileManager.default
    private let cacheDirectory: URL

    private init() {
        // Directorio de caché local
        cacheDirectory = fileManager.urls(for: .cachesDirectory, in: .userDomainMask)[0]
    }

    // Obtener el path de la imagen en el directorio de caché local
    private func localFilePath(forKey key: String) -> URL {
        return cacheDirectory.appendingPathComponent(key)
    }

    // Guardar la imagen tanto en memoria como en disco
    func saveImageToCache(_ image: UIImage, forKey key: String) {
        cache.setObject(image, forKey: key as NSString)

        let fileURL = localFilePath(forKey: key)

        if let imageData = image.jpegData(compressionQuality: 0.8) {
            try? imageData.write(to: fileURL, options: .atomic)
            print("Imagen guardada en caché: \(fileURL.path)")
        }
    }

    // Obtener la imagen desde el caché de memoria o de disco
    func getImage(forKey key: String, completion: @escaping (UIImage?) -> Void) {
        if let cachedImage = cache.object(forKey: key as NSString) {
            // Imagen encontrada en memoria
            completion(cachedImage)
            print("Imagen obtenida desde caché de memoria: \(key)")
            return
        }

        // Buscar la imagen en el disco
        let fileURL = localFilePath(forKey: key)
        if let imageFromDisk = UIImage(contentsOfFile: fileURL.path) {
            cache.setObject(imageFromDisk, forKey: key as NSString)  // Guardar en caché de memoria
            completion(imageFromDisk)
            print("Imagen obtenida desde caché de disco: \(key)")
            return
        }

        // Si no está en caché, descargarla de Firebase
        print("Descargando imagen de Firebase: \(key)")
        let storage = Storage.storage().reference().child("properties/\(key)")
        storage.downloadURL { url, error in
            guard let url = url, error == nil else {
                print("Error al obtener la URL de la imagen \(key): \(String(describing: error))")
                completion(nil)
                return
            }

            URLSession.shared.dataTask(with: url) { data, _, error in
                guard let data = data, let image = UIImage(data: data), error == nil else {
                    print("Error al descargar la imagen \(key): \(String(describing: error))")
                    completion(nil)
                    return
                }

                // Guardar imagen en caché y en disco
                self.saveImageToCache(image, forKey: key)
                DispatchQueue.main.async {
                    completion(image)
                }
            }.resume()
        }
    }
}
