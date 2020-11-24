//
//  FavouritesTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import XCTest
import os.log

@testable import BusyBuddy

class FavouritesTests: XCTestCase {
    private var userDefaults: UserDefaults!
    
    var favouritesManager: FavouritesManager!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        favouritesManager = FavouritesManager(userDefaults)

    }

    override func tearDownWithError() throws {

    }

    func testNoFavouritesReturnsEmptyArray() throws {
        XCTAssertTrue(favouritesManager.getPlaces().isEmpty)
    }
    
    func testAddPlace() throws {
        favouritesManager.add(place: PlaceExample.place)
        let places = favouritesManager.getPlaces()
        
        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places[0].id, PlaceExample.place.id)
    }

    func testremovePlace() throws {
        favouritesManager.add(place: PlaceExample.place)
        XCTAssertFalse(favouritesManager.getPlaces().isEmpty)
        
        favouritesManager.remove(place: PlaceExample.place)
        XCTAssertTrue(favouritesManager.getPlaces().isEmpty)
    }
    
    func testContainsPlaceTrue() throws {
        favouritesManager.add(place: PlaceExample.place)
        XCTAssertTrue(favouritesManager.contains(place: PlaceExample.place))
    }
}
