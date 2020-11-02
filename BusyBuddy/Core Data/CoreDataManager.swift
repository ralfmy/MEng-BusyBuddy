//
//  CoreDataManager.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//
//  With help from
//  https://www.hackingwithswift.com/read/38/overview
//  https://www.donnywals.com/fetching-objects-from-core-data-in-a-swiftui-project/

import Foundation
import CoreData
import os.log

class CoreDataManager {
    private var persistentContainer: NSPersistentContainer
    private var managedObjectContext: NSManagedObjectContext
    private var loadedPlaces = [CoreDataPlace]()
    
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "CoreDataManager")

    init(persistentContainer: NSPersistentContainer, managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.persistentContainer = persistentContainer
    }
    
    public func savePlaces(places: [Place]) {
        managedObjectContext.performAndWait {
            places.forEach { place in
                let cdPlace = CoreDataPlace(context: self.managedObjectContext)
                cdPlace.id = place.id
                cdPlace.commonName = place.commonName
                cdPlace.placeType = place.placeType
                cdPlace.imageUrl = place.getImageUrl()
                cdPlace.lat = place.lat
                cdPlace.lon = place.lon
            }
        }
        
        if self.managedObjectContext.hasChanges {
            do {
                try self.managedObjectContext.save()
                self.logger.info("INFO: Places saved successfully.")
            } catch {
                self.logger.error("ERROR: Error occurred while saving: \(error as NSObject, privacy: .public)")
            }
        } else {
            self.logger.info("INFO: No changes made.")
        }
    }
    
    public func loadAllSavedPlaces() -> [CoreDataPlace] {
        let request = CoreDataPlace.createFetchRequest()
        let sort = NSSortDescriptor(key: "commonName", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            self.loadedPlaces = try persistentContainer.viewContext.fetch(request)
        } catch {
            self.logger.error("ERROR: Fetch failed: \(error as NSObject, privacy: .public)")
        }
        
        return self.loadedPlaces
    }
    
    public func loadSavedPlace(by commonName: String) {
        let request = CoreDataPlace.createFetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "commonName == %@", commonName)
        
        do {
            self.loadedPlaces = try persistentContainer.viewContext.fetch(request)
        } catch {
            self.logger.error("ERROR: Fetch failed: \(error as NSObject, privacy: .public)")
        }
    }
    
    public func deleteAllSavedPlaces() {
        let savedPlaces = self.loadAllSavedPlaces()
        savedPlaces.forEach{ place in
            self.managedObjectContext.delete(place)
        }
        
        do {
            try self.managedObjectContext.save()
            self.logger.info("INFO: All saved places successfully deleted")
        } catch {
            self.logger.error("ERROR: Error occurred while deleting: \(error as NSObject, privacy: .public)")
        }
    }
}
