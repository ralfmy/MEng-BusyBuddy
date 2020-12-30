//
//  BookmarksTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import XCTest
import os.log

@testable import BusyBuddy

class BookmarksTests: XCTestCase {
    private var userDefaults: UserDefaults!
    
    var bookmarksManager: BookmarksManager!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        bookmarksManager = BookmarksManager(userDefaults)

    }

    override func tearDownWithError() throws {

    }

    func testNobookmarksReturnsEmptyArray() throws {
        XCTAssertTrue(bookmarksManager.getPlaces().isEmpty)
    }
    
    func testAddPlace() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        let places = bookmarksManager.getPlaces()
        
        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places[0].id, ExamplePlaces.oxfordCircus.id)
    }

    func testremovePlace() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        XCTAssertFalse(bookmarksManager.getPlaces().isEmpty)
        
        bookmarksManager.remove(place: ExamplePlaces.oxfordCircus)
        XCTAssertTrue(bookmarksManager.getPlaces().isEmpty)
    }
    
    func testContainsPlaceTrue() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        XCTAssertTrue(bookmarksManager.contains(place: ExamplePlaces.oxfordCircus))
    }
}
