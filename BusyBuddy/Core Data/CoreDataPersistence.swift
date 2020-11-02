//
//  File.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//
//  With help from
//  https://www.donnywals.com/setting-up-a-core-data-store-for-unit-tests/

import Foundation
import CoreData

enum StorageType {
    case disk, memory
}

class CoreDataPersistence {
    let container: NSPersistentContainer
    
    init(_ storageType: StorageType = .disk) {
        self.container = NSPersistentContainer(name: "BusyBuddy")
        
        if storageType == .memory {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.container.persistentStoreDescriptions = [description]
        }
        
        self.container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            self.container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
    }
}

