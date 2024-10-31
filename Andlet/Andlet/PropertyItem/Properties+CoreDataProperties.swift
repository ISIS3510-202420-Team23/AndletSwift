//
//  Properties+CoreDataProperties.swift
//  Andlet
//
//  Created by Thais Tamaio on 31/10/24.
//
//

import Foundation
import CoreData
import UIKit


extension Properties {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Properties> {
        return NSFetchRequest<Properties>(entityName: "Properties")
    }

    @NSManaged public var address: String?
    @NSManaged public var complex_name: String?
    @NSManaged public var description_property: String?
    @NSManaged public var location: String?
    @NSManaged public var minues_from_campus: Int64
    @NSManaged public var photo_1: UIImage?
    @NSManaged public var photo_2: UIImage?
    @NSManaged public var title: String?

}

extension Properties : Identifiable {

}
