//
//  ImageCache.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 07/11/2020.
//
//  With help from
//  https://schwiftyui.com/swiftui/downloading-and-caching-images-in-swiftui/

import Foundation
import UIKit
import os.log

class ImageCache: ObservableObject {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "ImageCache")
    private var countLimit: Int
    
    @Published private var cache = NSCache<NSString, ImageCacheEntry>()
    
    init(countLimit: Int = 3) {
        self.countLimit = countLimit
    }
    
    public func getImages(forKey: String) -> [UIImage]? {
        return self.cache.object(forKey: NSString(string: forKey))?.images
    }
    
    public func addImage(forKey: String, image: UIImage) {
        if var images = self.getImages(forKey: forKey) {
            self.logger.debug("DEBUG: Cache hit.")
            // Cache maximum the latest 3 images
            if images.count == self.countLimit {
                self.logger.debug("DEBUG: Max array size.")
                images.removeFirst()
            }
            images.append(image)
            print(images)
            self.cache.setObject(ImageCacheEntry(images), forKey: NSString(string: forKey))
        } else {
            self.logger.debug("DEBUG: Cache miss.")
            self.cache.setObject(ImageCacheEntry([image]), forKey: NSString(string: forKey))
        }
        self.logger.info("INFO: Image successfully saved to cache.")
    }
}

class ImageCacheEntry {
    var images : [UIImage]
    
    init(_ images: [UIImage]) {
        self.images = images
    }
}

// Singleton
struct Cache {
    static let images = ImageCache()
    private init () {}
}
