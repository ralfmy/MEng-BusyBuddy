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
import WidgetKit
import os.log

class BookmarksManager: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "BookmarksManager")
    
    private var model: BusyModel
    private var defaults: UserDefaults
    private let saveKey = "Bookmarks"
    private let feedback = UINotificationFeedbackGenerator()
    
    @Published var bookmarks: [Place]
    
    init(defaults: UserDefaults = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!, model: BusyModel = ML.model) {
        self.model = model
        self.defaults = defaults
        if let data = self.defaults.object(forKey: saveKey) as? Data {
            if let bookmarks = try? JSONDecoder().decode([Place].self, from: data) {
                self.bookmarks = bookmarks
//                if let encoded = try? JSONEncoder().encode(self.places) {
//                    UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!.set(encoded, forKey: saveKey)
//                    logger.info("INFO: UserDefaults save successful.")
//                }
                return
            }
        }
        self.bookmarks = []
    }
    
    public func getPlaces() -> [Place] {
//        self.logger.debug("DEBUG: Image urls \(self.places.map { $0.getImageUrl() } )")
        return self.bookmarks
    }
    
    public func getPlaceWith(id: String) -> Place? {
        return self.bookmarks.first(where: { $0.id == id })
    }
    
    public func getPlaceAt(index: Int) -> Place? {
        self.bookmarks.sort(by: { $0.commonName < $1.commonName })
        return bookmarks[index]
    }
    
    public func add(place: Place, busyScore: BusyScore? = nil) {
        objectWillChange.send()
        if !self.contains(place: place) {
            self.bookmarks.append(place)
            self.bookmarks.sort(by: { $0.commonName < $1.commonName })
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) already in Bookmarks.")
        }
    }
    
    public func remove(place: Place) {
        objectWillChange.send()
        if self.contains(place: place) {
            self.bookmarks.removeAll(where: { $0.id == place.id })
            save()
        } else {
            self.logger.info("INFO: Place with id \(place.id) is not in Bookmarks.")
        }
    }
    
    public func contains(place: Place) -> Bool {
        return self.bookmarks.contains(where: { $0.id == place.id })
    }
    
    public func updateScores() {
        self.objectWillChange.send()
        self.bookmarks.forEach { place in
            place.updateBusyScore(busyScore: BusyScore())
        }
        
        self.logger.info("INFO: Updating BusyScores...")
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            
            var images = [UIImage]()
            self.bookmarks.forEach { place in
                let image = place.downloadImage()
                images.append(image)
            }
            
            let busyScores = self.model.run(on: images)

            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
                for i in 0..<self!.bookmarks.count {
                    self?.bookmarks[i].updateBusyScore(busyScore: busyScores[i])
                }
                self?.logger.info("INFO: Finished updating BusyScores.")
                self?.feedback.notificationOccurred(.success)
                WidgetCenter.shared.reloadTimelines(ofKind: "com.mygame.busy-widgets")
            }
        }

    }
    
    public func updateScoreFor(id: String) {
        if let place = bookmarks.first(where: { $0.id == id } ) {
            if let currentScore = place.busyScore {
                place.updateBusyScore(busyScore: BusyScore())
                    if currentScore.isExpired() || currentScore.score == .none {
                        self.logger.info("INFO: BusyScore for id \(place.id) is expired - updating...")
                        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                            guard let self = self else {
                                return
                            }
                            
                            let image = place.downloadImage()
                            
                            let busyScore = self.model.run(on: [image]).first!
                            
                            DispatchQueue.main.async { [weak self] in
                                self?.objectWillChange.send()
                                place.updateBusyScore(busyScore: busyScore)
                                WidgetCenter.shared.reloadTimelines(ofKind: "com.mygame.busy-widgets")
                            }
                        }
                        
                    } else {
                        self.logger.info("INFO: BusyScore for id \(place.id) is not expired - no need for update.")
                        place.updateBusyScore(busyScore: currentScore)
                    }
                }
            }
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(self.bookmarks) {
            self.defaults.set(encoded, forKey: saveKey)
            logger.info("INFO: UserDefaults save successful.")
        }
    }
}
