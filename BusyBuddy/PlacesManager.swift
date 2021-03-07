//
//  PlacesManager.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 25/11/2020.
//

import Foundation
import UIKit
import os.log

class PlacesManager: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesManager")
    private var networkClient: NetworkClient
    private var cache: PlacesCache
    let feedback = UINotificationFeedbackGenerator()
    
    @Published private var places = [Place]()
    
    init(client: NetworkClient, cache: PlacesCache = PlacesCache()) {
        self.networkClient = client
        self.cache = cache
        self.loadPlaces()
    }
    
    public func getPlaces() -> [Place] {
        return self.places.sorted(by: { $0.commonName < $1.commonName })
    }
    
    public func getPlaceWith(id: String) -> Place? {
        return self.places.first(where: { $0.id == id })
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
                
                let busyScore = ML.currentModel().run(on: [image]).first!
                
                DispatchQueue.main.async { [weak self] in
                    self?.objectWillChange.send()
                    self?.places[index].updateBusyScore(busyScore: busyScore)
                    self?.feedback.notificationOccurred(.success)
                    self?.logger.info("INFO: Finished updating BusyScores.")
                }
            }
        }
    }
    
    private func loadPlaces() {
        if let cachedPlaces = self.cache.getPlaces() {
            self.logger.info("INFO: Cache hit.")
            self.places = cachedPlaces
        } else {
            self.logger.info("INFO: Cache miss.")
            self.fetchPlacesFromAPI()
        }
    }
    
    private func fetchPlacesFromAPI() {
        objectWillChange.send()
        self.logger.info("INFO: Fetching places from TfL Unified API.")
        TfLUnifiedAPI.fetchAllJamCams(client: self.networkClient) { places in
            self.logger.info("INFO: Fetching success.")
            self.cache.setPlaces(places: places)
            DispatchQueue.main.async { [weak self] in
                self?.places = places
            }
        }
    }
}
