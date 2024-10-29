//
//  UserDefaultsExtension.swift
//  Andlet
//
//  Created by Sofía Torres Ramírez on 29/10/24.
//

import Foundation

extension UserDefaults {
    private enum Keys {
        static let roommateViews = "roommateViews"
        static let noRoommateViews = "noRoommateViews"
        static let offlineOfferViews = "offlineOfferViews"
    }
    
    var roommateViews: Int {
        get { integer(forKey: Keys.roommateViews) }
        set { set(newValue, forKey: Keys.roommateViews) }
    }
    
    var noRoommateViews: Int {
        get { integer(forKey: Keys.noRoommateViews) }
        set { set(newValue, forKey: Keys.noRoommateViews) }
    }
    
    var offlineOfferViews: [String: Int] {
            get {
                return dictionary(forKey: Keys.offlineOfferViews) as? [String: Int] ?? [:]
            }
            set {
                set(newValue, forKey: Keys.offlineOfferViews)
            }
        }
        
    func incrementOfflineView(for offerId: String) {
        var views = offlineOfferViews
        views[offerId, default: 0] += 1
        offlineOfferViews = views
    }
        
    func resetOfflineViews(for offerId: String) {
        var views = offlineOfferViews
        views[offerId] = 0
        offlineOfferViews = views
    }
}
