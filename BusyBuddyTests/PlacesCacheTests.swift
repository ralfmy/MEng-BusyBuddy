//
//  PlacesCacheTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 24/01/2021.
//

import XCTest
import os.log

@testable import BusyBuddy

class PlacesCacheTests: XCTestCase {
    
    private var placesCache = PlacesCache()
    
    func testGetPlaces() {
        let places = placesCache.getPlaces()
        XCTAssertNil(places)
    }

    func testSetPlaces() {
        placesCache.setPlaces(places: [ExamplePlaces.gowerSt])
        let cachedPlaces = placesCache.getPlaces()
        XCTAssertEqual(cachedPlaces!.count, 1)
        XCTAssertEqual(cachedPlaces![0], ExamplePlaces.gowerSt)
    }

}
