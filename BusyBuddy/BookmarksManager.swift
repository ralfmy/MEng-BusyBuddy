//
//  Bookmarks.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 05/11/2020.
//
//  With help from:
//  https://www.hackingwithswift.com/books/ios-swiftui/letting-the-user-mark-favorites
//  https://www.hackingwithswift.com/example-code/system/how-to-save-user-settings-using-userdefaults
//  https://www.hackingwithswift.com/books/ios-swiftui/saving-and-loading-data-with-userdefaults
//  https://www.hackingwithswift.com/example-code/system/how-to-load-and-save-a-struct-in-userdefaults-using-codable
//  https://hackernoon.com/swift-multi-threading-using-gcd-for-beginners-2581b7aa21cb
//  https://www.raywenderlich.com/5370-grand-central-dispatch-tutorial-for-swift-4-part-1-2

import Foundation
import UIKit
import os.log

class BookmarksManager: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "BookmarksManager")
    
    private var defaults: UserDefaults
    private let saveKey = "Bookmarks"
    private let feedback = UINotificationFeedbackGenerator()
    
    @Published var places: [Place]
    @Published var scores: [BusyScore]
    
    init(_ defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
        self.scores = []
        if let data = self.defaults.object(forKey: saveKey) as? Data {
            if let bookmarks = try? JSONDecoder().decode([Place].self, from: data) {
                self.places = bookmarks
                if self.scores.isEmpty {
                    self.places.forEach { place in
                        self.scores.append(BusyScore(id: place.id))
                    }
                }
                return
            }
        }
        self.places = []
        
    }
    
    public func getPlaces() -> [Place] {
//        self.logger.debug("DEBUG: Image urls \(self.places.map { $0.getImageUrl() } )")
        return self.places
    }
    
    public func getPlaceWith(id: String) -> Place? {
        return self.places.first(where: { $0.id == id })
    }
    
    public func getPlaceAt(index: Int) -> Place? {
        self.places.sort(by: { $0.commonName < $1.commonName })
        return places[index]
    }
    
    public func add(place: Place, busyScore: BusyScore) {
        objectWillChange.send()
        if !self.contains(place: place) {
            self.places.append(place)
            self.places.sort(by: { $0.commonName < $1.commonName })
            self.scores.append(busyScore)
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) already in Bookmarks.")
        }
    }
    
    public func remove(place: Place) {
        objectWillChange.send()
        if self.contains(place: place) {
            self.places.removeAll(where: { $0.id == place.id })
            self.scores.removeAll(where: { $0.id == place.id })
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) is not in Bookmarks.")
        }
    }
    
    public func contains(place: Place) -> Bool {
        return self.places.contains(where: { $0.id == place.id })
    }
    
    public func updateScores() {
        self.scores = self.scores.map( { BusyScore(id: $0.id) } )
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
              }
            let scores = ML.model.run(on: self.places)
            DispatchQueue.main.async { [weak self] in
                self?.scores = scores
                self?.feedback.notificationOccurred(.success)
            }
        }
    }
    
    public func updateScoreFor(place: Place) {
        if let currentScore = self.scores.first(where: { $0.id == place.id }) {
            
            // Set BusyScore to "Loading" first
            let index = self.scores.firstIndex(where: { $0.id == place.id })!
            self.scores[index] = BusyScore(id: place.id)
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else {
                    return
                  }
                
                var score: BusyScore
                if currentScore.isExpired() || currentScore.score == .none {
                    self.logger.info("INFO: BusyScore for id \(place.id) is stale - updating...")
                    score = ML.model.run(on: [place]).first!
                } else {
                    self.logger.info("INFO: BusyScore for id \(place.id) is not stale - no need for update.")
                    score = BusyScore(id: place.id, count: currentScore.count, date: currentScore.date)
                }
                
                DispatchQueue.main.async { [weak self] in
                    self?.scores.removeAll(where: { $0.id == place.id })
                    self?.scores.append(score)
                    self?.feedback.notificationOccurred(.success)
                }
            }
        }
    }
    
    public func getScores() -> [BusyScore] {
        if self.scores.isEmpty {
            self.places.forEach { place in
                self.scores.append(BusyScore(id: place.id))
            }
        }
        return self.scores
    }
    
    public func getScoreFor(id: String) -> BusyScore? {
        return self.scores.first(where: { $0.id == id })
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(self.places) {
            self.defaults.set(encoded, forKey: saveKey)
            logger.info("INFO: UserDefaults save successful.")
        }
    }
}
