//
//  PlacesModelTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 10/02/2021.
//

import XCTest

@testable import BusyBuddy

class PlacesModelTests: XCTestCase {
    private var networkClient: NetworkClient!

    override func setUpWithError() throws {
        networkClient = NetworkClientMock()
    }
    
    func testGetPlaces() throws {
        let placesModel = PlacesModel(client: networkClient)
        
        let expectation = self.expectation(description: "Get Places")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        
        let places = placesModel.getAllPlaces
        XCTAssertEqual(places.count, 2)
        XCTAssertTrue(places[0].commonName < places[1].commonName)
    }
    
    func testLoadPlacesCacheHit() throws {
        let placesCache = PlacesCache()
        // Different from NetworkClientMock
        placesCache.setPlaces(places: [ExamplePlaces.exhibitionRd, ExamplePlaces.stGilesCircus])
        
        let placesModel = PlacesModel(client: networkClient, cache: placesCache)
        
        let expectation = self.expectation(description: "Load Places")
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 3)
        
        let places = placesModel.getAllPlaces
        XCTAssertEqual(places.count, 2)
        XCTAssertTrue(placesCache.getPlaces()!.elementsEqual(places))
    }

}
