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

//  Responsible for saving Places data to persitent storage via Core Data, and for loading data from storage to memory

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
    
    public func savePlaces(places: [PlaceResource]) {
        managedObjectContext.performAndWait {
            places.forEach { place in
                let cdPlace = Place(context: self.managedObjectContext)
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
        var results = [Place]()

        let request = Place.createFetchRequest()
        let sort = NSSortDescriptor(key: "commonName", ascending: true)
        request.sortDescriptors = [sort]
        
        do {
            results = try persistentContainer.viewContext.fetch(request)
        } catch {
            self.logger.error("ERROR: Fetch failed: \(error as NSObject, privacy: .public)")
        }
        
        self.places = results
    }
    
    public func loadSavedPlaces(by commonName: String) -> [Place] {
        var results = [Place]()
        
        let request = Place.createFetchRequest()
        request.sortDescriptors = []
        request.predicate = NSPredicate(format: "commonName CONTAINS[c] %@", commonName)
        
        do {
            results = try persistentContainer.viewContext.fetch(request)
        } catch {
            self.logger.error("ERROR: Fetch failed: \(error as NSObject, privacy: .public)")
        }
        
        return results
    }
    
    public func loadSavedPlace(with id: String) -> Place? {
        var results = [Place]()

        let request = Place.createFetchRequest()
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
        self.loadAllSavedPlaces()
        // Used for clearing storage
        self.places.forEach{ place in
            self.managedObjectContext.delete(place)
        }
        self.saveContext(message: "Successfully deleted all saved places.")
        self.loadAllSavedPlaces()
    }
    
    public func deleteSavedPlace(with id: String) {
        if let place = self.loadSavedPlace(with: id) {
            self.managedObjectContext.delete(place)
            self.saveContext(message: "Successfully deleted place with id \(id)")
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
