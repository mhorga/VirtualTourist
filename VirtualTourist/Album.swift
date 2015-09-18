//
//  Album.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/16/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import CoreData

class Album: NSManagedObject {

    @NSManaged var created: NSDate
    @NSManaged var name: String
    
    struct Keys {
        static let created = "created"
        static let name = "name"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String:AnyObject], context: NSManagedObjectContext) {
        let entity =  NSEntityDescription.entityForName("Album", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        created = dictionary[Keys.created] as! NSDate
        name = dictionary[Keys.name] as! String
    }
}
