//
//  Pin.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/16/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import CoreData

@objc(Pin)
class Pin: NSManagedObject {
    
    @NSManaged var latitude: Double
    @NSManaged var longitude: Double
    @NSManaged var pictures: [Photo]
    
    struct Keys {
        static let latitude = "latitude"
        static let longitude = "longitude"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Pin", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        latitude = dictionary[Keys.latitude] as! Double
        longitude = dictionary[Keys.longitude] as! Double
        try! context.save()
    }
}