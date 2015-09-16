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
    @NSManaged var location: Pin
    @NSManaged var photos: NSSet

}
