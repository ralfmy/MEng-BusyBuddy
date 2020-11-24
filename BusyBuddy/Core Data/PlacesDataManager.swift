//
//  PlacesDataManager.swift
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

//  Responsible for saving Place data to persitent storage via Core Data, and for loading data from storage to memory

class PlacesDataManager: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesDataManager")
    
    private var persistentContainer: NSPersistentContainer
    private var managedObjectContext: NSManagedObjectContext
    
    @Published var places = [Place]()

    init(persistentContainer: NSPersistentContainer, managedObjectContext: NSManagedObjectContext) {
        self.managedObjectContext = managedObjectContext
        self.persistentContainer = persistentContainer
        self.loadAllSavedPlaces()
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
            saveContext(message: "INFO: Places saved successfully.")
        } else {
            self.logger.info("INFO: No changes made.")
        }
        
        self.loadAllSavedPlaces()
    }
        
    public func loadAllSavedPlaces() {
        var results = [CoreDataPlace]()

        let request = CoreDataPlace.createFetchRequest()
        let sort = NSSortDescriptor(key: "commonName", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            results = try persistentContainer.viewContext.fetch(request)
        } catch {
            self.logger.error("ERROR: Fetch failed: \(error as NSObject, privacy: .public)")
        }
        
        
        self.places = results.map { $0.asCodablePlace() }
    }
    
    public func findPlace(with id: String) -> Place? {
        var result = self.places.first(where: { $0.id == id})
        
        // If not found in memory, check persistent storage
        if result == nil {
            if let loadedPlace = loadSavedPlace(with: id) {
                result = loadedPlace.asCodablePlace()
            }
        }
        
        return result
    }
    
    private func loadSavedPlaces(by commonName: String) -> [CoreDataPlace] {
        var results = [CoreDataPlace]()
        
        let request = CoreDataPlace.createFetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "commonName CONTAINS[c] %@", commonName)
        
        do {
            results = try persistentContainer.viewContext.fetch(request)
        } catch {
            self.logger.error("ERROR: Fetch failed: \(error as NSObject, privacy: .public)")
        }
        
        return results
    }
    
    private func loadSavedPlace(with id: String) -> CoreDataPlace? {
        var results = [CoreDataPlace]()

        let request = CoreDataPlace.createFetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "id == %@", id)
        
        do {
            results = try persistentContainer.viewContext.fetch(request)
        } catch {
            self.logger.error("ERROR: Fetch failed: \(error as NSObject, privacy: .public)")
        }
        
        if results.isEmpty {
            self.logger.info("INFO: Place with id \(id) not found.")
            return nil
        } else {
            return results[0]
        }
    }
    
    public func deleteAllSavedPlaces() {
        // Used for clearing storage
        var results = [CoreDataPlace]()

        let request = CoreDataPlace.createFetchRequest()
        let sort = NSSortDescriptor(key: "commonName", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            results = try persistentContainer.viewContext.fetch(request)
        } catch {
            self.logger.error("ERROR: Fetch failed: \(error as NSObject, privacy: .public)")
        }
        
        results.forEach{ place in
            self.managedObjectContext.delete(place)
        }
        self.saveContext(message: "Successfully deleted all saved places.")
        self.loadAllSavedPlaces()
    }
    
    public func deleteSavedPlace(with id: String) {
        if let place = self.loadSavedPlace(with: id) {
            self.managedObjectContext.delete(place)
            self.saveContext(message: "Successfully deleted place with id \(id)")
            self.loadAllSavedPlaces()
        } else {
            self.logger.info("INFO: Place with id \(id) not found.")
        }
    }
    
    private func saveContext(message: String = "INFO: Save successful.") {
        do {
            try self.managedObjectContext.save()
            self.logger.info("\(message, privacy: .private)")
        } catch {
            self.logger.error("ERROR: Error occurred while saving: \(error as NSObject, privacy: .public)")
        }
    }
    
}
