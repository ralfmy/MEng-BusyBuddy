//
//  CoreDataManager.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//
//  With help from
//  https://www.donnywals.com/fetching-objects-from-core-data-in-a-swiftui-project/

import Foundation
import CoreData

class CoreDataManager {
    private var persistentContainer: NSPersistentContainer
    private var managedObjectContext: NSManagedObjectContext
    private var savedPlaces = [CoreDataPlace]()

    init(persistentContainer: NSPersistentContainer, managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.persistentContainer = persistentContainer
    }
    
    public func savePlaces(places: [Place]) {
        managedObjectContext.performAndWait {
            places.forEach { place in
                let cdPlace = CoreDataPlace(context: self.managedObjectContext)
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
                print("-- CHANGES SAVED --")
            } catch {
                print("Error occurred while saving: \(error)")
            }
        } else {
            print("-- NO CHANGES --")
        }
    }
    
    public func loadSavedPlaces() -> [CoreDataPlace] {
        let request = CoreDataPlace.createFetchRequest()
        let sort = NSSortDescriptor(key: "commonName", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            self.savedPlaces = try persistentContainer.viewContext.fetch(request)
        } catch {
            print("Fetch failed: \(error)")
        }
        
        return self.savedPlaces
    }
    
    public func deleteAllPlaces() {
        let savedPlaces = self.loadSavedPlaces()
        savedPlaces.forEach{ place in
            self.managedObjectContext.delete(place)
        }
        
        do {
            try self.managedObjectContext.save()
            print("-- SUCCESSFULLY DELETED --")
        } catch {
            print("Error occurred while deleting: \(error)")
        }
    }
}
