//
//  JamCamsManager.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 25/11/2020.
//

import Foundation
import UIKit
import WidgetKit
import os.log

class JamCamsManager: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "JamCamsModel")
    
    private var model: BusyModel
    private var networkClient: NetworkClient
    private var cache: JamCamsCache
    private var defaults: UserDefaults
    private let feedback = UINotificationFeedbackGenerator()
    
    @Published private var jamCams = [JamCam]()
    @Published private var bookmarkIds = [String]()
    private var bookmarkIndices = [Int]()
    
    @Published public var apiHasReturned = false
    
    init(model: BusyModel = ML.currentModel(),
         client: NetworkClient = NetworkClient(),
         cache: JamCamsCache = JamCamsCache(),
         defaults: UserDefaults = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!) {
        self.model = model
        self.networkClient = client
        self.cache = cache
        self.defaults = defaults
        
        self.loadJamCams()
        
//        #if DEBUG
//        if CommandLine.arguments.contains("ui-testing") {
//            self.logger.debug("DEBUG: HERE")
//            let testDefaults = UserDefaults(suiteName: "com.zcabrmy.BusyBuddyUITests")
//            let bookmarkIds = [ExampleJamCams.gowerSt.id, ExampleJamCams.oxfordCircus.id, ExampleJamCams.stGilesCircus.id, ExampleJamCams.exhibitionRd.id]
//            self.defaults.setValue(bookmarkIds, forKey: "BookmarksIDs")
//            self.logger.info("INFO: UserDefaults save successful.")
//            self.defaults = testDefaults!
//        }
//        #endif
    }
    
    public func getAllJamCams() -> [JamCam] {
        return self.jamCams
    }
    
    public func getJamCamWithId(_ id: String) -> JamCam? {
//        if let index = self.getIndexOfId(id) {
//            return self.jamCams[index]
//        }
//        return nil
        return self.jamCams.first(where: { $0.id == id })
    }
    
    public func getBookmarkedJamCams() -> [JamCam] {
        return self.jamCams.filter { self.bookmarkIds.contains($0.id) }
    }
    
    public func getBookmarkIds() -> [String] {
        return self.bookmarkIds
    }
    
    public func isBookmark(id: String) -> Bool {
        if let jamCam = self.jamCams.first(where: { $0.id == id }) {
            return jamCam.isBookmark
        } else {
            return false
        }
    }
    
    public func addBookmark(id: String) {
        self.objectWillChange.send()
        if !self.isBookmark(id: id) {
            let index = self.getIndexOfId(id)!
            self.jamCams[index].toggleBookmark()
            self.bookmarkIndices.append(index)
            self.bookmarkIds.append(id)
            self.saveBookmarks()
        } else {
            self.logger.info("INFO: JamCam with id \(id) already in Bookmarks.")
        }
    }
    
    public func removeBookmark(id: String) {
        self.objectWillChange.send()
        if self.isBookmark(id: id) {
            let index = self.getIndexOfId(id)!
            self.jamCams[index].toggleBookmark()
            self.bookmarkIndices.append(index)
            self.bookmarkIds.removeAll(where: { $0 == id })
            self.saveBookmarks()
        } else {
            self.logger.info("INFO: JamCam with id \(id) is not in Bookmarks.")
        }
    }
    
    public func updateBookmarksScores() {
        self.logger.info("INFO: Updating BusyScores...")
        
        self.objectWillChange.send()
        self.bookmarkIndices.forEach { index in
            self.jamCams[index].updateBusyScore(busyScore: nil)
        }
        
        DispatchQueue.global(qos: .userInteractive).async { [weak self] in
            guard let self = self else {
                return
            }
            
            var busyScores = [BusyScore]()
            
            self.bookmarkIndices.forEach { index in
                let image = self.jamCams[index].downloadImage()
                let busyScore = self.model.run(on: [image]).first!
                busyScores.append(busyScore)
            }
            
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
                self?.bookmarkIndices.enumerated().forEach { (i, index) in
                    self?.jamCams[index].updateBusyScore(busyScore: busyScores[i])
                }
                self?.feedback.notificationOccurred(.success)
                WidgetCenter.shared.reloadTimelines(ofKind: "com.zcabrmy.busy-widgets")
                self?.logger.info("INFO: Finished updating BusyScores.")
            }
        }
    }
    
    public func updateScoreFor(id: String) {
        if let index = self.jamCams.firstIndex(where: { $0.id == id }) {
            self.objectWillChange.send()
            self.jamCams[index].updateBusyScore(busyScore: nil)
            
            self.logger.info("INFO: BusyScore for id \(self.jamCams[index].id) is expired - updating...")
            
            DispatchQueue.global(qos: .userInteractive).async { [weak self] in
                guard let self = self else {
                    return
                }
                
                let image = self.jamCams[index].downloadImage()
                let busyScore = self.model.run(on: [image]).first!
                
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                    self?.jamCams[index].updateBusyScore(busyScore: busyScore)
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
    
    private func loadJamCams() {
        let cachedJamCams = self.cache.getJamCams()
        if !cachedJamCams.isEmpty {
            self.logger.info("INFO: JamCamsCache hit.")
            self.jamCams = cachedJamCams
            self.setBookmarkedJamCams()
        } else {
            self.logger.info("INFO: JamCamsCache miss.")
            self.fetchJamCamsFromAPI()
        }
    }
    
    private func fetchJamCamsFromAPI() {
        self.logger.info("INFO: Fetching JamCams from TfL Unified API.")
        TfLUnifiedAPIClient.fetchAllJamCams(client: self.networkClient) { jamCams in
            self.logger.info("INFO: Fetching success.")
            DispatchQueue.main.async { [weak self] in
                self?.objectWillChange.send()
                self?.jamCams = jamCams.sorted(by: { $0.commonName < $1.commonName })
                self?.cache.setJamCams(jamCams: jamCams)
                self?.setBookmarkedJamCams()
                self?.apiHasReturned = true
            }
        }
    }
    
    private func setBookmarkedJamCams() {
        self.bookmarkIds = self.defaults.object(forKey: "BookmarksIDs") as? [String] ?? [String]()
        for (index, jamCam) in self.jamCams.enumerated() {
            if self.bookmarkIds.contains(jamCam.id) {
                self.jamCams[index].toggleBookmark()
                self.bookmarkIndices.append(index)
            }
        }
        self.saveBookmarks()
        self.updateBookmarksScores()
    }
    
    private func saveBookmarks() {
        self.defaults.setValue(self.bookmarkIds, forKey: "BookmarksIDs")
        let bookmarkedJamCams = self.getBookmarkedJamCams()
        if let encoded = try? JSONEncoder().encode(bookmarkedJamCams) {
            self.defaults.set(encoded, forKey: "Bookmarks")
        }
        self.logger.info("INFO: UserDefaults save successful.")
    }
    
    private func getIndexOfId(_ id: String) -> Int? {
        return self.jamCams.firstIndex(where: { $0.id == id })
    }
}
