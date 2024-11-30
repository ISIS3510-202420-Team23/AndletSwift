import FirebaseFirestore
import FirebaseAuth
import Foundation

class BugViewModel: ObservableObject {
    private let db = Firestore.firestore()

    func submitBug(_ bugText: String, completion: @escaping (Result<Void, Error>) -> Void) {
        guard let currentUser = Auth.auth().currentUser else {
            completion(.failure(NSError(domain: "AuthError", code: 401, userInfo: [NSLocalizedDescriptionKey: "User not authenticated"])))
            return
        }

        let userID = currentUser.email ?? "unknown_user"
        let userDocRef = db.collection("feedbacks").document(userID)
        
        userDocRef.getDocument { document, error in
            if let error = error {
                completion(.failure(error))
                return
            }
            
            let newBugID: String
            if let document = document, document.exists {
                let existingBugIDs = document.data()?.keys.compactMap { Int($0) } ?? []
                let nextID = (existingBugIDs.max() ?? 0) + 1
                newBugID = "\(nextID)"
            } else {
                newBugID = "1"
            }
            
            let bugData: [String: Any] = [
                "date": FieldValue.serverTimestamp(),
                "description": bugText.removingExtraSpaces().removingEmojis()
            ]
            
            userDocRef.updateData([newBugID: bugData]) { error in
                if let error = error {
                    if (error as NSError).code == FirestoreErrorCode.notFound.rawValue {
                        userDocRef.setData([newBugID: bugData]) { error in
                            if let error = error {
                                completion(.failure(error))
                            } else {
                                completion(.success(()))
                            }
                        }
                    } else {
                        completion(.failure(error))
                    }
                } else {
                    completion(.success(()))
                }
            }
        }
    }
}
