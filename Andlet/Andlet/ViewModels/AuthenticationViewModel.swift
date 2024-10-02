//
//  AuthenticationViewModel.swift
//  SwiftApp
//
//  Created by Daniel Arango Cruz on 18/09/24.
//

import Foundation
import GoogleSignIn
import GoogleSignInSwift
import FirebaseAuth
import FirebaseCore
import FirebaseFirestore

@MainActor
final class AuthenticationViewModel: ObservableObject{
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: UserModel? = nil
    @Published var errorMessage: String = ""
    
    private let db = Firestore.firestore()
    private let usersDocumentID = "eBbttobInFQe6i9wLHSF" 
    
    
    init() {
        checkIfUserIsLoggedIn()
    }
    
    func checkIfUserIsLoggedIn() {
        if let currentUser = Auth.auth().currentUser{
            isAuthenticated = true
            print("User \(currentUser.displayName ?? "Unknown") is already logged in.")
            
            Task {
                await fetchOrCreateUser(
                    userEmail: currentUser.email ?? "No email",
                    name: currentUser.displayName ?? "Unkown",
                    phone: currentUser.phoneNumber ?? "No number",
                    photo: currentUser.photoURL?.absoluteString ?? ""
                )
            }
        }
        else {
            isAuthenticated = false
            currentUser = nil
            print("No user is logged in")
        }
    }
    
    func signInWithGoogle() async -> Bool {
        guard let clientID = FirebaseApp.app()?.options.clientID else {
          fatalError("No client ID found in Firebase configuration")
        }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.configuration = config

        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let window = windowScene.windows.first,
              let rootViewController = window.rootViewController else {
          print("There is no root view controller!")
          return false
        }

          do {
            let userAuthentication = try await GIDSignIn.sharedInstance.signIn(withPresenting: rootViewController)

            let user = userAuthentication.user
            guard let idToken = user.idToken else { throw AuthenticationError.tokenError(message: "ID token missing") }
            let accessToken = user.accessToken

            let credential = GoogleAuthProvider.credential(withIDToken: idToken.tokenString,
                                                           accessToken: accessToken.tokenString)

            let result = try await Auth.auth().signIn(with: credential)
            let firebaseUser = result.user
              print("User \(String(describing: firebaseUser.displayName)) signed in with email \(firebaseUser.email ?? "unknown")")
            await fetchOrCreateUser (
                userEmail: firebaseUser.email ?? "No specified",
                name: firebaseUser.displayName ?? "Unkown",
                phone: firebaseUser.phoneNumber ?? "300000",
                photo: firebaseUser.photoURL?.absoluteString ?? ""
              )
             isAuthenticated = true
             return true
          }
          catch {
            print(error.localizedDescription)
            self.errorMessage = error.localizedDescription
            return false
          }
      }
    func signOut(){
        do{
            try Auth.auth().signOut()
        }
        catch{
            print("There was an error trying to sign out")
            errorMessage = error.localizedDescription
            print(errorMessage)
        }
            
    }
    func fetchOrCreateUser(userEmail: String, name: String, phone: String, photo: String) async {
        let userRef = db.collection("users").document(usersDocumentID)
        
        let safeEmail = userEmail.replacingOccurrences(of: ".", with: "_")
        
        do{
            let document = try await userRef.getDocument()
            if document.exists {
                if let usersData = document.data() {
                    if let userData = usersData[safeEmail] as? [String: Any] {
                        let user = UserModel(
                            id: userEmail,
                            favoriteOffers: userData["favorite_offers"] as? [Int],
                            isAndes: userData["is_andes"] as? Bool ?? false,
                            name: userData["name"] as? String ?? "No name",
                            phone: userData["phone"] as? String ?? "No phone",
                            typeUser: UserType(rawValue: userData["type_user"] as? String ?? "student") ?? .student,
                            photo: userData["photo"] as? String ?? ""
                        )
                        self.currentUser = user
                        print("Fetched existing user: \(user.name)")
                    }
                    else{
                        await addNewUser(userEmail: userEmail, name: name, phone: phone, photo: photo)
                    }
                    
                }
            }
            else{
                print("No users document found")
            }
        }
        catch{
            print("Error fetching document: \(error.localizedDescription)")
        }
        
    }
    func addNewUser(userEmail: String, name: String, phone: String, photo: String) async {
        let userRef = db.collection("users").document(usersDocumentID)
        let safeEmail = userEmail.replacingOccurrences(of: ".", with: "_")
        let newUser: [String: Any] = [
            "favorite_offers": [],
            "is_andes": true,
            "name": name,
            "phone": phone,
            "type_user": "notDefined",
            "photo": photo,
            "email": userEmail
        ]
        do {
            try await userRef.setData([safeEmail: newUser], merge: true)
            print("Added new user with email: \(userEmail)")
            self.currentUser = UserModel(
                id: userEmail,
                isAndes: true,
                name: name,
                phone: phone,
                typeUser: .notDefined,
                photo: photo
            )
            
        }
        catch{
            print("Error creating new user: \(error.localizedDescription)")
        }
    }
    func addUserRole(userEmail: String, role: UserType) async{
        let userRef = db.collection("users").document(usersDocumentID)
        
        let safeEmail = userEmail.replacingOccurrences(of: ".", with: "_")
        
        do{
            try await userRef.updateData([
                "\(safeEmail).type_user": role.rawValue
            ])
            
            if var currentUser = currentUser {
                currentUser.typeUser = role
                self.currentUser = currentUser
                print("Current Role \(currentUser.typeUser) of \(currentUser.name)")
            }
        }
        catch{
            print("Error updating user role: \(error.localizedDescription)")
        }
    }
}

enum AuthenticationError: Error {
  case tokenError(message: String)
}
