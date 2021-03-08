//
//  PlacesModel.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 25/11/2020.
//

import Foundation
import UIKit
import WidgetKit
import os.log

class PlacesModel: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesModel")
    
    private var model: BusyModel
    private var networkClient: NetworkClient
    private var cache: PlacesCache
    private var defaults: UserDefaults
    
    private let saveKey = "BookmarksIDs"
    private let feedback = UINotificationFeedbackGenerator()
    
    @Published private var places = [Place]()
    @Published private var bookmarkIndices = [Int]()
    private var bookmarkIds = [String]()
    
    init(model: BusyModel = ML.currentModel(),
         client: NetworkClient = NetworkClient(),
         cache: PlacesCache = PlacesCache(),
         defaults: UserDefaults = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!) {
        self.model = model
        self.networkClient = client
        self.cache = cache
        self.defaults = defaults
        self.loadPlaces()
    }
    
    public func getAllPlaces() -> [Place] {
        return self.places
    }
    
    public func getPlaceWithId(_ id: String) -> Place? {
        if let index = self.getIndexOfId(id) {
            return self.places[index]
        }
        return nil
    }
    
    public func getBookmarkedPlaces() -> [Place] {
        return self.places.filter { self.bookmarkIds.contains($0.id) }
    }
    
    public func getBookmarkIds() -> [String] {
        return self.bookmarkIds
    }
    
    public func isBookmark(id: String) -> Bool {
        if let place = self.places.first(where: { $0.id == id }) {
            return place.isBookmark
        } else {
            return false
        }
    }
    
    public func addBookmark(id: String) {
        self.objectWillChange.send()
        if !self.isBookmark(id: id) {
            let index = self.getIndexOfId(id)!
            self.places[index].toggleBookmark()
            self.bookmarkIndices.append(index)
            self.bookmarkIds.append(id)
            self.saveBookmarks()
        } else {
            self.logger.info("INFO: Place with id \(id) already in Bookmarks.")
        }
    }
    
    public func removeBookmark(id: String) {
        self.objectWillChange.send()
        if self.isBookmark(id: id) {
            let index = self.getIndexOfId(id)!
            self.places[index].toggleBookmark()
            self.bookmarkIndices.append(index)
            self.bookmarkIds.removeAll(where: { $0 == id })
            self.saveBookmarks()
        } else {
            self.logger.info("INFO: Place with id \(id) is not in Bookmarks.")
        }
    }
    
    public func updateBookmarksScores() {
        self.logger.info("INFO: Updating BusyScores...")
        
        self.objectWillChange.send()
        self.bookmarkIndices.forEach { index in
            self.places[index].updateBusyScore(busyScore: nil)
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            
            var busyScores = [BusyScore]()
            
            self.bookmarkIndices.forEach { index in
                let image = self.places[index].downloadImage()
                let busyScore = self.model.run(on: [image]).first!
                busyScores.append(busyScore)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
                self?.bookmarkIndices.enumerated().forEach { (i, index) in
                    self?.places[index].updateBusyScore(busyScore: busyScores[i])
                }
                WidgetCenter.shared.reloadTimelines(ofKind: "com.zcabrmy.busy-widgets")
                self?.logger.info("INFO: Finished updating BusyScores.")
            }
        }
    }
    
    public func updateScoreFor(id: String) {
        if let index = self.places.firstIndex(where: { $0.id == id }) {
            self.objectWillChange.send()
            self.places[index].updateBusyScore(busyScore: nil)
            
            self.logger.info("INFO: BusyScore for id \(self.places[index].id) is expired - updating...")
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else {
                    return
                }
                
                let image = self.places[index].downloadImage()
                
                let busyScore = self.model.run(on: [image]).first!
                
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                    self?.places[index].updateBusyScore(busyScore: busyScore)
                    self?.feedback.notificationOccurred(.success)
                    self?.logger.info("INFO: Finished updating BusyScores.")
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
        self.updateBookmarksScores()
    }
    
    private func loadPlaces() {
        let cachedPlaces = self.cache.getPlaces()
        if !cachedPlaces.isEmpty {
            self.logger.info("INFO: PlacesCache hit.")
            self.places = cachedPlaces
            self.setBookmarkedPlaces()
        } else {
            self.logger.info("INFO: PlacesCache miss.")
            self.fetchPlacesFromAPI()
        }
    }
    
    private func fetchPlacesFromAPI() {
        objectWillChange.send()
        self.logger.info("INFO: Fetching Places from TfL Unified API.")
        TfLUnifiedAPI.fetchAllJamCams(client: self.networkClient) { places in
            self.logger.info("INFO: Fetching success.")
            DispatchQueue.main.async { [weak self] in
                self?.places = places.sorted(by: { $0.commonName < $1.commonName })
                self?.cache.setPlaces(places: places)
                self?.setBookmarkedPlaces()
            }
        }
    }
    
    private func setBookmarkedPlaces() {
        self.bookmarkIds = self.defaults.object(forKey: saveKey) as? [String] ?? [String]()
        for (index, place) in self.places.enumerated() {
            if self.bookmarkIds.contains(place.id) {
                self.places[index].toggleBookmark()
                self.bookmarkIndices.append(index)
            }
        }
        self.saveBookmarks()
        self.updateBookmarksScores()
    }
    
    private func saveBookmarks() {
        self.defaults.setValue(self.bookmarkIds, forKey: "BookmarksIDs")
        let bookmarkedPlaces = self.getBookmarkedPlaces()
        if let encoded = try? JSONEncoder().encode(bookmarkedPlaces) {
            self.defaults.set(encoded, forKey: "Bookmarks")
        }
        self.logger.info("INFO: UserDefaults save successful.")
    }
    
    private func getIndexOfId(_ id: String) -> Int? {
        return self.places.firstIndex(where: { $0.id == id })
    }
}
