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
    
    init(_ defaults: UserDefaults = UserDefaults.standard) {
        self.defaults = defaults
        if let data = self.defaults.object(forKey: saveKey) as? Data {
            if let bookmarks = try? JSONDecoder().decode([Place].self, from: data) {
                self.places = bookmarks
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
    
    public func add(place: Place, busyScore: BusyScore? = nil) {
        objectWillChange.send()
        if !self.contains(place: place) {
            self.places.append(place)
            self.places.sort(by: { $0.commonName < $1.commonName })
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) already in Bookmarks.")
        }
    }
    
    public func remove(place: Place) {
        objectWillChange.send()
        if self.contains(place: place) {
            self.places.removeAll(where: { $0.id == place.id })
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) is not in Bookmarks.")
        }
    }
    
    public func contains(place: Place) -> Bool {
        return self.places.contains(where: { $0.id == place.id })
    }
    
    public func updateScores() {
        self.objectWillChange.send()
        self.places.forEach { place in
            place.updateBusyScore(busyScore: BusyScore())
        }
        
        self.logger.info("INFO: Updating BusyScores...")
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            
            let output = ML.model.run(on: self.places)

            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
                for i in 0..<self!.places.count {
                    let image = output[i].0
                    let result = output[i].1
                    if result.getObjectConfidences() != nil {
                        let peopleCount = (result.objects.filter { $0.objClass == "person" && $0.confidence >= ML.model.threshold }).count
                        self?.places[i].updateBusyScore(busyScore: BusyScore(count: peopleCount, image: image))
                    } else {
                        self?.places[i].updateBusyScore(busyScore: BusyScore(count: -2, image: image))
                    }
                }
                self?.logger.info("INFO: Finished updating BusyScores.")
                self?.feedback.notificationOccurred(.success)
            }
        }

    }
    
    public func updateScoreFor(id: String) {
        if let place = places.first(where: { $0.id == id } ) {
            if let currentScore = place.busyScore {
                place.updateBusyScore(busyScore: BusyScore())
                    if currentScore.isExpired() || currentScore.score == .none {
                        self.logger.info("INFO: BusyScore for id \(place.id) is expired - updating...")
                        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                            guard let self = self else {
                                return
                            }
                            
                            let output = ML.model.run(on: [place]).first!
                            
                            DispatchQueue.main.async { [weak self] in
                                self?.objectWillChange.send()
                                let image = output.0
                                let result = output.1
                                if result.getObjectConfidences() != nil {
                                    let peopleCount = (result.objects.filter { $0.objClass == "person" && $0.confidence >= ML.model.threshold }).count
                                    place.updateBusyScore(busyScore: BusyScore(count: peopleCount, image: image))
                                } else {
                                    place.updateBusyScore(busyScore: BusyScore(count: -2, image: image))
                                }
                            }
                        }
                        
                    } else {
                        self.logger.info("INFO: BusyScore for id \(place.id) is not expired - no need for update.")
                        place.updateBusyScore(busyScore: currentScore)
                    }
                }
            }
    }
    
//    public func updateScoreFor(place: Place) {
//        if let currentScore = self.scores.first(where: { $0.id == place.id }) {
//
//            // Set BusyScore to "Loading" first
//            let index = self.scores.firstIndex(where: { $0.id == place.id })!
//            self.scores[index] = BusyScore(id: place.id)
//
//            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
//                guard let self = self else {
//                    return
//                  }
//
//                var score: BusyScore
//                if currentScore.isExpired() || currentScore.score == .none {
//                    self.logger.info("INFO: BusyScore for id \(place.id) is stale - updating...")
//                    score = ML.model.run(on: [place]).first!
//                } else {
//                    self.logger.info("INFO: BusyScore for id \(place.id) is not stale - no need for update.")
//                    score = BusyScore(id: place.id, count: currentScore.count, image: currentScore.image, date: currentScore.date)
//                }
//
//                DispatchQueue.main.async { [weak self] in
//                    self?.scores.removeAll(where: { $0.id == place.id })
//                    self?.scores.append(score)
//                    self?.feedback.notificationOccurred(.success)
//                }
//            }
//        }
//    }
    
//    public func getScores() -> [BusyScore] {
//        if self.scores.isEmpty {
//            self.places.forEach { place in
//                self.scores.append(BusyScore(id: place.id))
//            }
//        }
//        return self.scores
//    }
//
//    public func getScoreFor(id: String) -> BusyScore? {
//        return self.scores.first(where: { $0.id == id })
//    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(self.places) {
            self.defaults.set(encoded, forKey: saveKey)
            logger.info("INFO: UserDefaults save successful.")
        }
    }
}
