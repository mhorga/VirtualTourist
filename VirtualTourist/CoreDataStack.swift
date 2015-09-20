//
//  CoreDataStack.swift
//  VirtualTourist
//
//  Created by Marius Horga on 9/15/15.
//  Copyright (c) 2015 Marius Horga. All rights reserved.
//

import CoreData

class CoreDataStack: NSObject {
    
    class func sharedInstance() -> CoreDataStack {
        struct Static {
            static let singleton = CoreDataStack()
        }
        return Static.singleton
    }
    
    lazy var managedObjectContext: NSManagedObjectContext = {
        let context = NSManagedObjectContext()
        context.persistentStoreCoordinator = self.persistentStoreCoordinator
        return context
        }()
    
    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("VirtualTourist.sqlite")
        let store = try? coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        if store == nil {
            abort()
        }
        return coordinator
        }()
    
    lazy var managedObjectModel: NSManagedObjectModel = {
        let url = NSBundle.mainBundle().URLForResource("Model", withExtension: "momd")!
        let model = NSManagedObjectModel(contentsOfURL: url)!
        return model
        }()
    
    lazy var applicationDocumentsDirectory: NSURL = {
        let fileManager = NSFileManager.defaultManager()
        return fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
        }()
    
    func saveContext() {
        if managedObjectContext.hasChanges {
            // if managedObjectContext.save()
            abort()
        }
    }
//    
//    func saveContext () {
//        if let moc = self.managedObjectContext {
//            var error: NSError? = nil
//            if moc.hasChanges && !moc.save(&error) {
//                NSLog("Unresolved error \(error), \(error!.userInfo)")
//                abort()
//            }
//        }
//    }
}
