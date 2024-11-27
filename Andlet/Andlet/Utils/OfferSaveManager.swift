//
//  OfferSaveManager.swift
//  Andlet
//
//  Created by Daniel Arango Cruz on 26/11/24.
//


import FirebaseFirestore
import FirebaseAuth

class OfferSaveManager: ObservableObject {
    private let db = Firestore.firestore()

    func saveOffer(offerId: String, completion: @escaping (Error?) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        // Explicitly set the `offerId` as the key
        db.collection("user_saved").document(userEmail).setData([
            offerId: Timestamp(date: Date())  // Key is the offerId, value is the save timestamp
        ], merge: true) { error in
            if let error = error {
                completion(error)
                return
            }

            // Update property_saved_by for the property
            self.db.collection("property_saved_by").document(offerId).setData([
                userEmail: Timestamp(date: Date())
            ], merge: true, completion: completion)
        }
    }

    func unsaveOffer(offerId: String, completion: @escaping (Error?) -> Void) {
        guard let userEmail = Auth.auth().currentUser?.email else {
            completion(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not logged in"]))
            return
        }

        // Remove the `offerId` from user_saved
        db.collection("user_saved").document(userEmail).updateData([
            offerId: FieldValue.delete()
        ]) { error in
            if let error = error {
                completion(error)
                return
            }

            // Remove the user from property_saved_by
            let propertySavedByDoc = self.db.collection("property_saved_by").document(offerId)
            propertySavedByDoc.getDocument { document, error in
                if let error = error {
                    print("Error checking property_saved_by document: \(error.localizedDescription)")
                    completion(error)
                    return
                }
                
                // If the document exists, remove the userEmail field
                if document?.exists == true {
                    var currentData = document!.data() ?? [:]
                    
                    // Step 3: Remove the `userEmail` field
                    currentData.removeValue(forKey: userEmail)
                    
                    // Step 4: Update the document with the modified data
                    propertySavedByDoc.setData(currentData) { error in
                        if let error = error {
                            print("Error updating property_saved_by document: \(error.localizedDescription)")
                            completion(error)
                        } else {
                            print("Successfully removed userEmail from property_saved_by.")
                            completion(nil)
                        }
                    }
                }
            }
        }
    }
}
