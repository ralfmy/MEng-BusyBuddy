//
//  ImageCacheTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 07/11/2020.
//

import XCTest

@testable import BusyBuddy

class ImageCacheTests: XCTestCase {
    
    let universitySt = UIImage(named: "StGiles_busy.jpg")
    let oxfordSt = UIImage(named: "RegentSt_busy.jpg")
    let horseferryRd = UIImage(named: "test_HorseferryRd_MarshamSt.jpg")
    var imageCache: ImageCache!

    override func setUpWithError() throws {
        imageCache = ImageCache()
    }

    override func tearDownWithError() throws {

    }

    func testAddImageToCache() throws {
        imageCache.addImage(forKey: "test", image: universitySt!)
        let cachedImages = imageCache.getImages(forKey: "test")!
        
        XCTAssertEqual(cachedImages.count, 1)
        XCTAssertEqual(cachedImages.first, universitySt)
    }
    
    func testAddTwoImagesToCache() throws {
        imageCache.addImage(forKey: "test", image: universitySt!)
        imageCache.addImage(forKey: "test", image: oxfordSt!)
        let cachedImages = imageCache.getImages(forKey: "test")!

        XCTAssertEqual(cachedImages.count, 2)
        XCTAssertEqual(cachedImages.first, universitySt)
        XCTAssertEqual(cachedImages.last, oxfordSt)
    }
    
    func testCacheEntryAdheresToCountLimit() throws {
        imageCache.addImage(forKey: "test", image: universitySt!)
        imageCache.addImage(forKey: "test", image: oxfordSt!)
        imageCache.addImage(forKey: "test", image: horseferryRd!)
        var cachedImages = imageCache.getImages(forKey: "test")!
        
        XCTAssertEqual(cachedImages.count, 3)

        imageCache.addImage(forKey: "test", image: universitySt!)
        cachedImages = imageCache.getImages(forKey: "test")!
        
        XCTAssertEqual(cachedImages.count, 3)
        XCTAssertEqual(cachedImages[0], oxfordSt)
        XCTAssertEqual(cachedImages[1], horseferryRd)
        XCTAssertEqual(cachedImages[2], universitySt)
    }
    
}
