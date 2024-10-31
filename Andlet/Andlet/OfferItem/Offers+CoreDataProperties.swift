//
//  Offers+CoreDataProperties.swift
//  Andlet
//
//  Created by Thais Tamaio on 31/10/24.
//
//

import Foundation
import CoreData


extension Offers {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Offers> {
        return NSFetchRequest<Offers>(entityName: "Offers")
    }

    @NSManaged public var final_date: Date?
    @NSManaged public var initial_date: Date?
    @NSManaged public var is_active: Bool
    @NSManaged public var num_baths: Int64
    @NSManaged public var num_beds: Int64
    @NSManaged public var num_rooms: Int64
    @NSManaged public var price_per_month: Int64
    @NSManaged public var only_andes: Bool
    @NSManaged public var roommates: Int64
    @NSManaged public var type: String?
    @NSManaged public var user_id: String?
    @NSManaged public var views: Int64

}

extension Offers : Identifiable {

}
