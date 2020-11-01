//
//  CoreDataManager.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

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
    
    func savePlaces(places: [Place]) {
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
    
    func loadSavedPlaces() -> [CoreDataPlace] {
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
    
    func deleteAllPlaces() {
        self.savedPlaces.forEach{ place in
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
