//
//  Photo.swift
//  
//
//  Created by Marius Horga on 9/18/15.
//
//

import Foundation
import CoreData

class Photo: NSManagedObject {

    @NSManaged var url: String
    @NSManaged var pin: Pin

    struct Keys {
        static let url = "url"
        static let pin = "pin"
    }
    
    override init(entity: NSEntityDescription, insertIntoManagedObjectContext context: NSManagedObjectContext?) {
        super.init(entity: entity, insertIntoManagedObjectContext: context)
    }
    
    init(dictionary: [String: AnyObject], context: NSManagedObjectContext) {
        let entity = NSEntityDescription.entityForName("Photo", inManagedObjectContext: context)!
        super.init(entity: entity, insertIntoManagedObjectContext: context)
        url = dictionary[Keys.url] as! String
        pin = dictionary[Keys.pin] as! Pin
        context.save(nil)
    }
    
    override func prepareForDeletion() {
        let docPath = NSSearchPathForDirectoriesInDomains(NSSearchPathDirectory.DocumentDirectory, NSSearchPathDomainMask.UserDomainMask, true).first as! String
        let fullPath = docPath + url
        NSFileManager.defaultManager().removeItemAtPath(fullPath, error: nil)
    }
}
