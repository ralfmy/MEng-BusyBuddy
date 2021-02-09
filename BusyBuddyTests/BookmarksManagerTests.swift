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
    private var busyModel: BusyModel!
    private var bookmarksManager: BookmarksManager!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        busyModel = BusyModelMock()
        bookmarksManager = BookmarksManager(model: busyModel, defaults: userDefaults)
    }
    
    override func tearDownWithError() throws {
        bookmarksManager.remove(place: ExamplePlaces.oxfordCircus)
        bookmarksManager.remove(place: ExamplePlaces.gowerSt)
    }

    func testGetPlaces() throws {
        let places = bookmarksManager.getPlaces()
        XCTAssertTrue(places.isEmpty)
    }
    
    func testAddPlace() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        let places = bookmarksManager.getPlaces()
        XCTAssertEqual(places.count, 1)
        XCTAssertTrue(places.contains(ExamplePlaces.oxfordCircus))
        
        let bookmarks = try! JSONDecoder().decode([Place].self, from: self.userDefaults.object(forKey: "Bookmarks") as! Data)
        XCTAssertTrue(bookmarks.elementsEqual(places))
    }
    
    func testBookmarksAlphabeticalOrder() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        bookmarksManager.add(place: ExamplePlaces.gowerSt)
        let places = bookmarksManager.getPlaces()
        
        XCTAssertTrue(places[0].commonName < places[1].commonName)
    }
    
    func testAddExistingPlace() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        XCTAssertEqual(bookmarksManager.getPlaces().count, 1)
    }

    func testRemovePlace() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        bookmarksManager.remove(place: ExamplePlaces.oxfordCircus)
        XCTAssertFalse(bookmarksManager.getPlaces().contains(ExamplePlaces.oxfordCircus))
        XCTAssertTrue(bookmarksManager.getPlaces().isEmpty)
    }
    
    func testRemovePlaceNotBookmarked() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        bookmarksManager.remove(place: ExamplePlaces.gowerSt)
        XCTAssertEqual(bookmarksManager.getPlaces().count, 1)
    }
    
    func testContainsPlaceTrue() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        XCTAssertTrue(bookmarksManager.contains(place: ExamplePlaces.oxfordCircus))
    }
    
    func testUpdateAllScores() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        let place = bookmarksManager.getPlaces().first!
        XCTAssertNil(place.busyScore)

        let expectation = self.expectation(description: "Update BusyScores")

        bookmarksManager.updateScores()

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            XCTAssertNotNil(place.busyScore)
            XCTAssertEqual(place.busyScore!.count, 5)
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
    
    func testUpdateScoreForId() throws {
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
        bookmarksManager.add(place: ExamplePlaces.gowerSt)
        
        let oxfordCircus = bookmarksManager.getPlaceWith(id: ExamplePlaces.oxfordCircus.id)!
        let gowerSt = bookmarksManager.getPlaceWith(id: ExamplePlaces.gowerSt.id)!
        
        oxfordCircus.updateBusyScore(busyScore: BusyScore())
                
        let expectation = self.expectation(description: "Update BusyScores")
         
        bookmarksManager.updateScoreFor(id: ExamplePlaces.oxfordCircus.id)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
            XCTAssertNotNil(oxfordCircus.busyScore)
            XCTAssertEqual(oxfordCircus.busyScore!.count, 5)
            
            XCTAssertNil(gowerSt.busyScore)

            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 5)
    }
}
