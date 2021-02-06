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
    
    @Published private var bookmarks: [Place]
    
    init(model: BusyModel = ML.currentModel(), defaults: UserDefaults = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!) {
        self.model = model
        self.defaults = defaults
        if let data = self.defaults.object(forKey: saveKey) as? Data {
            if let bookmarks = try? JSONDecoder().decode([Place].self, from: data) {
                self.bookmarks = bookmarks
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
    
    public func add(place: Place) {
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
        self.logger.info("INFO: Updating BusyScores...")
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            
            var busyScores = [BusyScore]()
            
            for index in 0..<self.bookmarks.count {
                let image = self.bookmarks[index].downloadImage()
                let busyScore = self.model.run(on: [image]).first!
                busyScores.append(busyScore)
            }
        
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
                self?.objectWillChange.send()
                for i in 0..<self!.bookmarks.count {
                    self?.bookmarks[i].updateBusyScore(busyScore: busyScores[i])
                }

            }
        }
        WidgetCenter.shared.reloadTimelines(ofKind: "com.mygame.busy-widgets")
        self.logger.info("INFO: Finished updating BusyScores.")
        
//        self.bookmarks.forEach { place in
//            place.updateBusyScore(busyScore: BusyScore())
//        }
        
//        self.logger.info("INFO: Updating BusyScores...")
//        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
//            guard let self = self else {
//                return
//            }
//
//            var images = [UIImage]()
//            self.bookmarks.forEach { place in
//                let image = place.downloadImage()
//                images.append(image)
//            }
//
//            let busyScores = self.model.run(on: images)
//
//            DispatchQueue.main.async { [weak self] in
//                self?.objectWillChange.send()
//                for i in 0..<self!.bookmarks.count {
//                    self?.bookmarks[i].updateBusyScore(busyScore: busyScores[i])
//                }
//                self?.feedback.notificationOccurred(.success)
//                WidgetCenter.shared.reloadTimelines(ofKind: "com.mygame.busy-widgets")
//                self?.logger.info("INFO: Finished updating BusyScores.")
//            }
//        }

    }
    
    public func updateScoreFor(id: String) {
        if let index = self.bookmarks.firstIndex(where: { $0.id == id } ) {
            if let currentScore = self.bookmarks[index].busyScore {
                self.bookmarks[index].updateBusyScore(busyScore: BusyScore())
                if currentScore.isExpired() || currentScore.score == .none {
                    self.logger.info("INFO: BusyScore for id \(self.bookmarks[index].id) is expired - updating...")
                    DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                        guard let self = self else {
                            return
                        }
                        
                        let image = self.bookmarks[index].downloadImage()
                        
                        let busyScore = self.model.run(on: [image]).first!
                        
                        DispatchQueue.main.async { [weak self] in
                            self?.objectWillChange.send()
                            self?.bookmarks[index].updateBusyScore(busyScore: busyScore)
                            self?.feedback.notificationOccurred(.success)
                            WidgetCenter.shared.reloadTimelines(ofKind: "com.mygame.busy-widgets")
                            self?.logger.info("INFO: Finished updating BusyScores.")
                        }
                    }
                    
                } else {
                    self.logger.info("INFO: BusyScore for id \(self.bookmarks[index].id) is not expired - no need for update.")
                    bookmarks[index].updateBusyScore(busyScore: currentScore)
                }
            }
        }
    }
    
    public func updateModel(_ model: BusyModel? = nil) {
        if model == nil {
            self.model = ML.currentModel(self.defaults)
        } else {
            self.model = model!
        }
        self.updateScores()
    }
    
    private func save() {
        if let encoded = try? JSONEncoder().encode(self.bookmarks) {
            self.defaults.set(encoded, forKey: saveKey)
            logger.info("INFO: UserDefaults save successful.")
        }
    }
}
