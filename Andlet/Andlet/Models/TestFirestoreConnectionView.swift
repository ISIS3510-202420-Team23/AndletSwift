import SwiftUI
import FirebaseFirestore

struct TestFirestoreConnectionView: View {
    @State private var message = "Checking Firestore connection..."
    
    var body: some View {
        Text(message)
            .padding()
            .onAppear {
                fetchOfferAndRelatedProperty()
            }
    }
    
    func fetchOfferAndRelatedProperty() {
        let db = Firestore.firestore()
        
        // Fetch the offer by its document ID
        db.collection("offers").document("E2amoJzmIbhtLq65ScpY").getDocument { document, error in
            if let error = error {
                message = "Error: \(error.localizedDescription)"
                print("Error fetching offer: \(error)")
            } else if let document = document, document.exists {
                if let offerData = document.data() {
                    print("Offer fields: \(offerData.keys)")  // Debug: Print the keys
                    
                    // Access the dictionary under the key "1" (or the matching key)
                    if let offerDetails = offerData["1"] as? [String: Any] {
                        // Extract the id_property from the nested data
                        if let propertyId = offerDetails["id_property"] as? Int {
                            message = "Offer fetched: \(offerDetails)"
                            print("Offer details: \(offerDetails)")
                            
                            // Fetch the corresponding property using propertyId
                            fetchRelatedProperty(propertyId: propertyId)
                        } else {
                            message = "Error: id_property not found in the offer"
                            print("id_property not found in offer details")
                        }
                    } else {
                        message = "Error: Couldn't access the offer details under key '1'"
                        print("Couldn't access offer details under key '1'")
                    }
                }
            } else {
                message = "Offer document does not exist!"
                print("Offer document does not exist")
            }
        }
    }
    
    // Fetch the related property based on the id_property field (here 1)
    func fetchRelatedProperty(propertyId: Int) {
        let db = Firestore.firestore()
        
        // Query the entire "properties" collection
        db.collection("properties").getDocuments { snapshot, error in
            if let error = error {
                message = "Error fetching properties: \(error.localizedDescription)"
                print("Error fetching properties: \(error)")
            } else if let snapshot = snapshot {
                // Loop through all documents in the properties collection
                for document in snapshot.documents {
                    if let propertyData = document.data() as? [String: Any] {
                        // Check if the property ID matches the id_property from the offer
                        if let propertyDetails = propertyData["\(propertyId)"] as? [String: Any] {
                            message = "Property fetched: \(propertyDetails)"
                            print("Property details: \(propertyDetails)")
                            return  // Stop after finding the first matching property
                        }
                    }
                }
                // If no matching property was found
                message = "Property with id_property \(propertyId) not found!"
                print("Property with id_property \(propertyId) not found!")
            }
        }
    }
}

#Preview {
    TestFirestoreConnectionView()
}
