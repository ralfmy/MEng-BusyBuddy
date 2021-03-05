//
//  PlacesCache.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 25/11/2020.
//

import UIKit
import os.log

public final class PlacesCache {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesCache")
    private let key = "Places"
    
    private var cache = NSCache<NSString, NSArray>()
    
    init() {
//        https://www.raywenderlich.com/16126261-instruments-tutorial-with-swift-getting-started#toc-anchor-006
      NotificationCenter.default.addObserver(
        forName: UIApplication.didReceiveMemoryWarningNotification,
        object: nil,
        queue: .main) { [weak self] _ in
        self?.cache.removeAllObjects()
      }
    }
    
    public func getPlaces() -> [Place]? {
        return self.cache.object(forKey: NSString(string: self.key)) as? [Place]
    }
    
    public func setPlaces(places: [Place]) {
        self.cache.setObject(places as NSArray, forKey: NSString(string: self.key))
        self.logger.info("INFO: Cache save success.")
    }
}
