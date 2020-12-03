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
        bookmarksManager.add(place: ExamplePlace.place)
        let places = bookmarksManager.getPlaces()
        
        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places[0].id, ExamplePlace.place.id)
    }

    func testremovePlace() throws {
        bookmarksManager.add(place: ExamplePlace.place)
        XCTAssertFalse(bookmarksManager.getPlaces().isEmpty)
        
        bookmarksManager.remove(place: ExamplePlace.place)
        XCTAssertTrue(bookmarksManager.getPlaces().isEmpty)
    }
    
    func testContainsPlaceTrue() throws {
        bookmarksManager.add(place: ExamplePlace.place)
        XCTAssertTrue(bookmarksManager.contains(place: ExamplePlace.place))
    }
}
