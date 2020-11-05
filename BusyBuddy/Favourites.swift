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
import SwiftUI
import os.log

class Favourites: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "Favourites")
    
    @Published private var placeIds: [String]
    private let saveKey = "Favourites"
    private let defaults = UserDefaults.standard
    
    init() {
        if let data = UserDefaults.standard.object(forKey: "Favourites") {
            self.placeIds = data as? [String] ?? [String]()
            return
        }
        self.placeIds = [String]()
    }
    
    public func ids() -> [String] {
        return self.placeIds
    }
    
    public func contains(place: Place) -> Bool {
        return self.placeIds.contains(place.id)
    }
    
    public func add(place: Place) {
        objectWillChange.send()
        self.placeIds.append(place.id)
        save()
    }
    
    public func remove(place: Place) {
        objectWillChange.send()
        self.placeIds.remove(at: self.placeIds.firstIndex(of: place.id)!)
        save()
    }
    
    private func save() {
        defaults.set(self.placeIds, forKey: saveKey)
        logger.info("INFO: UserDefaults save successful.")
    }
}
