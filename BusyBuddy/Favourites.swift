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

import Foundation
import os.log

class Favourites: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "Favourites")
    
    private var defaults: UserDefaults
    private let saveKey = "Favourites"
    
    @Published private var placeIds: [String]
    
    init(_ defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
        if let data = defaults.object(forKey: "Favourites") {
            self.placeIds = data as? [String] ?? [String]()
            return
        }
        self.placeIds = [String]()
    }
    
    public func ids() -> [String] {
        return self.placeIds
    }
    
    public func add(place: Place) {
        objectWillChange.send()
        if !self.contains(place: place) {
            self.placeIds.append(place.id)
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) already in Favourites.")
        }
        
    }
    
    public func remove(place: Place) {
        objectWillChange.send()
        if self.contains(place: place) {
            self.placeIds.remove(at: self.placeIds.firstIndex(of: place.id)!)
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) is not in Favourites.")
        }
        
    }
    
    public func contains(place: Place) -> Bool {
        return self.placeIds.contains(place.id)
    }
    
    private func save() {
        defaults.set(self.placeIds, forKey: saveKey)
        logger.info("INFO: UserDefaults save successful.")
    }
}
