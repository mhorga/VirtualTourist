//
//  Photo.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/16/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import CoreData

class Photo: NSManagedObject {

    @NSManaged var id: String
    @NSManaged var url: String
    @NSManaged var name: String
    @NSManaged var state: NSNumber
    @NSManaged var album: Album

}
