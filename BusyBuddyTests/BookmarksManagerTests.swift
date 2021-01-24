//
//  BookmarksTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import XCTest
import Vision
import CoreML
import os.log

@testable import BusyBuddy

class BookmarksManagerTests: XCTestCase {
    private var userDefaults: UserDefaults!
    private var bookmarksManager: BookmarksManager!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        bookmarksManager = BookmarksManager(defaults: userDefaults, model: BusyModelMock())
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
    }

    override func tearDownWithError() throws {

    }
    
    func testAddPlace() throws {
        let places = bookmarksManager.getPlaces()
        
        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places[0].id, ExamplePlaces.oxfordCircus.id)
    }

    func testRemovePlace() throws {
        bookmarksManager.remove(place: ExamplePlaces.oxfordCircus)
        XCTAssertTrue(bookmarksManager.getPlaces().isEmpty)
    }
    
    func testContainsPlaceTrue() throws {
        XCTAssertTrue(bookmarksManager.contains(place: ExamplePlaces.oxfordCircus))
    }
    
    func testUpdateScores() {
        let place = bookmarksManager.getPlaces()[0]
        XCTAssertNil(place.busyScore)
        bookmarksManager.updateScores()
        XCTAssertNotNil(place.busyScore)
        let busyScore = place.busyScore!
        XCTAssertEqual(busyScore.count, -1)
    }
}
