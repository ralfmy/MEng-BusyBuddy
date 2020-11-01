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
    case DISK, MEMORY
}

class CoreDataContainer {
    let persistentContainer: NSPersistentContainer
    
    init(_ storageType: StorageType = .DISK) {
        self.persistentContainer = NSPersistentContainer(name: "BusyBuddy")
        
        if storageType == .MEMORY {
            let description = NSPersistentStoreDescription()
            description.url = URL(fileURLWithPath: "/dev/null")
            self.persistentContainer.persistentStoreDescriptions = [description]
        }
        
        self.persistentContainer.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
    }
}

