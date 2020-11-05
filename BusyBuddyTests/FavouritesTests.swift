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
    
    var favourites: Favourites!
    var gowerSt: Place!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        favourites = Favourites(userDefaults)
        
        gowerSt = Place(context: PersistenceManager(.memory).container.viewContext)
        gowerSt.id = "JamCams_00001.07389"
        gowerSt.commonName = "University St/Gower St"
        gowerSt.placeType = "JamCam"
        gowerSt.imageUrl = "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.07389.jpg"
        gowerSt.lat = 51.5239
        gowerSt.lon = -0.1341
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testNoFavouritesReturnsEmptyArray() throws {
        XCTAssertTrue(favourites.ids().isEmpty)
    }
    
    func testAddPlace() throws {
        favourites.add(place: gowerSt)
        let ids = favourites.ids()
        
        XCTAssertEqual(ids.count, 1)
        XCTAssertEqual(ids[0], gowerSt.id)
    }

    func testremovePlace() throws {
        favourites.add(place: gowerSt)
        XCTAssertFalse(favourites.ids().isEmpty)
        
        favourites.remove(place: gowerSt)
        XCTAssertTrue(favourites.ids().isEmpty)
    }
    
    func testContainsPlaceTrue() throws {
        favourites.add(place: gowerSt)
        XCTAssertTrue(favourites.contains(place: gowerSt))
    }
    
    func testContainsPlaceFalse() throws {
        favourites.add(place: gowerSt)
        gowerSt.id = "not the real id"
        XCTAssertFalse(favourites.contains(place: gowerSt))
    }
}
