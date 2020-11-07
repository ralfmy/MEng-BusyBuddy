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

    @Published private var cache = NSCache<NSString, ImageCacheEntry>()
    
    init() {
        self.cache.countLimit = 3
    }
    
    func getImages(forKey: String) -> [UIImage]? {
        return self.cache.object(forKey: NSString(string: forKey))?.images
    }
    
    func addImage(forKey: String, image: UIImage) {
        if var images = self.getImages(forKey: forKey) {
            self.logger.debug("DEBUG: Cache hit.")
            if images.count == 3 {
                self.logger.debug("DEBUG: Max array size.")
                images.removeFirst()
            }
            images.append(image)
            self.cache.setObject(ImageCacheEntry(images), forKey: NSString(string: forKey))
        } else {
            self.logger.debug("DEBUG: Cache miss.")
            self.cache.setObject(ImageCacheEntry([]), forKey: NSString(string: forKey))
        }
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
