//
//  PlacesModelTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 10/02/2021.
//

import XCTest

@testable import BusyBuddy

class PlacesModelTests: XCTestCase {
    private var busyModel: BusyModel!
    private var networkClient: NetworkClient!
    private var placesCache: PlacesCache!
    private var userDefaults: UserDefaults!
    private var placesModel: PlacesModel!

    override func setUpWithError() throws {
        busyModel = BusyModelMock()
        networkClient = NetworkClientMock()
        placesCache = PlacesCache()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        placesModel = PlacesModel(model: busyModel,
                                    client: networkClient,
                                    cache: placesCache,
                                    defaults: userDefaults)
        
        let expectation = self.expectation(description: "Get Places")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    override func tearDownWithError() throws {
        placesModel.removeBookmark(id: ExamplePlaces.oxfordCircus.id)
        placesModel.removeBookmark(id: ExamplePlaces.gowerSt.id)
    }
    
    func testGetAllPlaces() throws {
        let places = placesModel.getAllPlaces()
        
        XCTAssertEqual(places.count, 2)
        XCTAssertTrue(places[0].commonName < places[1].commonName)
    }
    
    func testAddBookmark() throws {
        placesModel.addBookmark(id: ExamplePlaces.gowerSt.id)
        let bookmarkedPlaces = placesModel.getBookmarkedPlaces()
        let bookmarkIds = placesModel.getBookmarkIds()
        let savedBookmarks = try! JSONDecoder().decode([Place].self, from: self.userDefaults.object(forKey: "Bookmarks") as! Data)
        
        XCTAssertEqual(bookmarkedPlaces.count, 1)
        XCTAssertEqual(bookmarkIds.count, 1)
        XCTAssertTrue(bookmarkedPlaces.contains(ExamplePlaces.gowerSt))
        XCTAssertTrue(bookmarkIds.contains(ExamplePlaces.gowerSt.id))
        XCTAssertTrue(savedBookmarks.elementsEqual(bookmarkedPlaces))
    }
    
    func testAddExistingBookmark() throws {
        placesModel.addBookmark(id: ExamplePlaces.gowerSt.id)
        placesModel.addBookmark(id: ExamplePlaces.gowerSt.id)
        
        XCTAssertEqual(placesModel.getBookmarkIds().count, 1)
    }
    
    func testRemovePlace() throws {
        placesModel.addBookmark(id: ExamplePlaces.gowerSt.id)
        placesModel.removeBookmark(id: ExamplePlaces.gowerSt.id)
        
        XCTAssertTrue(placesModel.getBookmarkIds().isEmpty)
    }
    
    func testRemovePlaceNotBookmarked() throws {
        placesModel.addBookmark(id: ExamplePlaces.oxfordCircus.id)
        placesModel.removeBookmark(id: ExamplePlaces.gowerSt.id)
        
        XCTAssertEqual(placesModel.getBookmarkIds().count, 1)
    }
    
    func testIsBookmarkTrue() throws {
        placesModel.addBookmark(id: ExamplePlaces.gowerSt.id)
        
        XCTAssertTrue(placesModel.isBookmark(id: ExamplePlaces.gowerSt.id))
    }
    
    func testIsBookmarkFalse() throws {
        placesModel.addBookmark(id: ExamplePlaces.gowerSt.id)
        
        XCTAssertFalse(placesModel.isBookmark(id: ExamplePlaces.oxfordCircus.id))
    }
    
    func testUpdateBookmarksScores() throws {
        placesModel.addBookmark(id: ExamplePlaces.gowerSt.id)
        let place = placesModel.getPlaceWithId(ExamplePlaces.gowerSt.id)!
        
        XCTAssertNil(place.busyScore)

        let expectation = self.expectation(description: "Update BusyScores")
        self.measure {
            placesModel.updateBookmarksScores()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        XCTAssertNotNil(place.busyScore)
        XCTAssertEqual(place.busyScore!.count, 5)
    }
    
    func testUpdateScoreForId() throws {
        let oxfordCircus = placesModel.getPlaceWithId( ExamplePlaces.oxfordCircus.id)!
        let gowerSt = placesModel.getPlaceWithId( ExamplePlaces.gowerSt.id)!
         
        placesModel.updateScoreFor(id: ExamplePlaces.gowerSt.id)
        
        let expectation = self.expectation(description: "Update BusyScores")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        XCTAssertNotNil(gowerSt.busyScore)
        XCTAssertEqual(gowerSt.busyScore!.count, 5)
        
        XCTAssertNil(oxfordCircus.busyScore)
    }
    
    func testLoadPlacesCacheHit() throws {
        placesCache.setPlaces(places: [ExamplePlaces.exhibitionRd, ExamplePlaces.stGilesCircus])
        
        placesModel = PlacesModel(model: busyModel,
                                    client: networkClient,
                                    cache: placesCache,
                                    defaults: userDefaults)

        let expectation = self.expectation(description: "Load Places")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        let places = placesModel.getAllPlaces()
        
        XCTAssertEqual(places.count, 2)
        XCTAssertTrue(placesCache.getPlaces().elementsEqual(places))
    }

}
