//
//  Pin.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/16/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import CoreData

class Pin: NSManagedObject {

    @NSManaged var latitude: NSNumber
    @NSManaged var longitude: NSNumber
    @NSManaged var name: String
    @NSManaged var albums: NSSet

    struct Keys {
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let name = "name"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        latitude = dictionary[Keys.latitude] as! Double
        longitude = dictionary[Keys.longitude] as! Double
        name = dictionary[Keys.name] as! String
    }
}
