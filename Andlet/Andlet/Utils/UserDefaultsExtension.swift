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
    }
    
    var roommateViews: Int {
        get { integer(forKey: Keys.roommateViews) }
        set { set(newValue, forKey: Keys.roommateViews) }
    }
    
    var noRoommateViews: Int {
        get { integer(forKey: Keys.noRoommateViews) }
        set { set(newValue, forKey: Keys.noRoommateViews) }
    }
}
