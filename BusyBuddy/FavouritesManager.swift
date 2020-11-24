//
//  Favourites.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//
//  With help from:
//  https://www.hackingwithswift.com/books/ios-swiftui/letting-the-user-mark-favorites
//  https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults
//  https://www.hackingwithswift.com/books/ios-swiftui/saving-and-loading-data-with-userdefaults
//  https://www.hackingwithswift.com/example-code/system/how-to-load-and-save-a-struct-in-userdefaults-using-codable

import Foundation
import os.log

class FavouritesManager: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "FavouritesManager")
    
    private var defaults: UserDefaults
    private let saveKey = "Favourites"
    
    @Published private var places: [Place]
    
    init(_ defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
        if let data = defaults.object(forKey: saveKey) as? Data {
            if let favourites = try? JSONDecoder().decode([Place].self, from: data) {
                self.places = favourites
                return
            }
        }
        self.places = []
    }
    
    public func getPlaces() -> [Place] {
        let sorted = self.places.sorted(by: { $0.commonName < $1.commonName })
        self.logger.debug("DEBUG: Image urls \(sorted.map { $0.getImageUrl() } )")
        return sorted
    }
    
    public func add(place: Place) {
        objectWillChange.send()
        if !self.contains(place: place) {
            self.places.append(place)
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) already in Favourites.")
        }
        
    }
    
    public func remove(place: Place) {
        objectWillChange.send()
        if self.contains(place: place) {
            self.places.removeAll(where: { $0.id == place.id })
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) is not in Favourites.")
        }
        
    }
    
    public func contains(place: Place) -> Bool {
        return self.places.contains(where: { $0.id == place.id })
    }
    
    public func updateBusyScores() {
        if self.places.filter({ $0.busyScore.score == .none }).count == self.places.count {
            ML.model.run(on: self.places)
        } else {
            var needsUpdate = [Place]()
            self.places.forEach { place in
                if place.busyScoreNeedsUpdate() {
                    needsUpdate.append(place)
                }
            }
            ML.model.run(on: needsUpdate)
        }
    }
    
    public func updateBusyScoreFor(place: Place) {
        if place.busyScoreNeedsUpdate() {
            ML.model.run(on: [place])
        }
    }
    
    private func busyScoreNeedsUpdate(place: Place) -> Bool {
        let busyScore = place.busyScore
        if busyScore.count != -1 {
            if busyScore.date.addingTimeInterval(5 * 60) > Date() {
                self.logger.info("INFO: BusyScore older than 5 minutes, requires update.")
                return true
            } else {
                return false
            }
        } else {
            return false
        }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(self.places) {
            self.defaults.set(encoded, forKey: saveKey)
            logger.info("INFO: UserDefaults save successful.")
        }
    }
}
