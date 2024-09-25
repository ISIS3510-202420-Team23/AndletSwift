//
//  OfferTypeService.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 23/09/24.
//

import FirebaseDatabase

class OfferTypeService {
    private var ref: DatabaseReference!

    init() {
        // Reference to the Firebase Realtime Database, to the "offers" collection
        ref = Database.database().reference().child("offers")
    }

    // Fetch all offers in real-time
    func fetchOffers(completion: @escaping ([OfferModel]) -> Void) {
        ref.observe(.value) { snapshot in
            var offers = [OfferModel]()
            for child in snapshot.children {
                if let childSnapshot = child as? DataSnapshot,
                   let offer = OfferModel(snapshot: childSnapshot) {
                    offers.append(offer)
                }
            }
            completion(offers)
        }
    }

    // Fetch a single offer by ID
    func fetchOffer(byId id: String, completion: @escaping (OfferModel?) -> Void) {
        ref.child(id).observeSingleEvent(of: .value) { snapshot in
            guard let offer = OfferModel(snapshot: snapshot) else {
                completion(nil)
                return
            }
            completion(offer)
        }
    }

    // Save offer to Firebase
    func saveOffer(_ offer: OfferModel, completion: @escaping (Error?) -> Void) {
        // Ensure that "type" is valid before saving
        guard offer.type == "entire_place" || offer.type == "shared_place" else {
            print("Invalid type: \(offer.type). Must be 'entire_place' or 'shared_place'.")
            completion(NSError(domain: "", code: 400, userInfo: [NSLocalizedDescriptionKey: "Invalid type"]))
            return
        }

        let newOfferRef = ref.childByAutoId()
        newOfferRef.setValue(offer.toDictionary()) { error, _ in
            completion(error)
        }
    }
}
