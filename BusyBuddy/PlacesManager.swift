//
//  PlacesManager.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 25/11/2020.
//

import Foundation
import os.log

class PlacesManager: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesManager")
    private let cache = PlacesCache()
    
    @Published private var places = [Place]()
    
    init() {
        self.loadPlaces()
    }
    
    public func getPlaces() -> [Place] {
        return self.places.sorted(by: { $0.commonName < $1.commonName })
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
        self.logger.info("INFO: Fetching places from TfL Unified API.")
        TfLUnifiedAPI.fetchAllJamCams(client: NetworkClient()) { places in
            self.logger.info("INFO: Fetching success.")
            self.cache.setPlaces(places: places)
            DispatchQueue.main.async {
                self.places = places
            }
        }
    }
}
