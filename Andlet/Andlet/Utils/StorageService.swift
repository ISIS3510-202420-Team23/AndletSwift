//
//  StorageService.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 23/09/24.
//

import FirebaseStorage
import UIKit
import Foundation



class StorageService {
    let storageRef = Storage.storage().reference()

    // Upload a photo to Firebase Storage and return the download URL
    func uploadPhoto(_ image: UIImage, completion: @escaping (URL?) -> Void) {
        guard let imageData = image.jpegData(compressionQuality: 0.8) else {
            completion(nil)
            return
        }

        // Create a unique name for the image
        let imageName = UUID().uuidString
        let imageRef = storageRef.child("photos/\(imageName).jpg")

        // Upload image to Firebase Storage
        imageRef.putData(imageData, metadata: nil) { metadata, error in
            guard metadata != nil else {
                print("Error uploading image: \(String(describing: error))")
                completion(nil)
                return
            }

            // Get the download URL
            imageRef.downloadURL { url, error in
                guard let downloadURL = url else {
                    print("Error fetching download URL: \(String(describing: error))")
                    completion(nil)
                    return
                }

                completion(downloadURL)
            }
        }
    }
}
