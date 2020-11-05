//
//  CoreDataTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 01/11/2020.
//
//  With help from
//  https://www.donnywals.com/setting-up-a-core-data-store-for-unit-tests/
//  https://www.raywenderlich.com/11349416-unit-testing-core-data-in-ios#toc-anchor-010
//  https://www.swiftbysundell.com/articles/unit-testing-asynchronous-swift-code/

import XCTest
import CoreData
import os.log

@testable import BusyBuddy

class PlacesDataManagerTests: XCTestCase {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesDataManager")
    
    var persistentContainer: NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext!
    var placesDataManager: PlacesDataManager!
    
    var gowerSt: PlaceResource!
    var places: [PlaceResource]!
    
    override func setUpWithError() throws {
        persistentContainer = PersistenceManager(.memory).container
        managedObjectContext = persistentContainer.viewContext
        placesDataManager = PlacesDataManager(persistentContainer: persistentContainer, managedObjectContext: managedObjectContext)
        
        gowerSt = PlaceResource(id: "JamCams_00001.07389", commonName: "University St/Gower St", placeType: "JamCam", additionalProperties: [AdditionalProperty(key: "imageUrl", value: "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.07389.jpg")], lat: 51.5239, lon: -0.1341)
        places = [gowerSt]
    }
    
    override func tearDownWithError() throws {
        placesDataManager.deleteAllSavedPlaces()
    }
    
    func testSavePlaces() throws {
            expectation(
                forNotification: .NSManagedObjectContextDidSave,
                object: managedObjectContext
            ) { _ in
                return true
            }
            
            placesDataManager.savePlaces(places: places)
            
            waitForExpectations(timeout: 1) { error in
                XCTAssertNil(error, "Save failed")
            }
    }

    func testLoadAllSavedPlaces() throws {
        placesDataManager.savePlaces(places: places)
        
        let places = placesDataManager.places
        
        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places[0].commonName, gowerSt.commonName)
        XCTAssertEqual(places[0].placeType, gowerSt.placeType)
        XCTAssertEqual(places[0].lat, gowerSt.lat)
        XCTAssertEqual(places[0].lon, gowerSt.lon)
    }
    
    func testLoadSavedPlacesByCommonName() throws {
        placesDataManager.savePlaces(places: places)
        let loadedPlaces = placesDataManager.loadSavedPlaces(by: "University St/Gower St")

        XCTAssertEqual(loadedPlaces.count, 1)
        XCTAssertEqual(loadedPlaces[0].commonName, gowerSt.commonName)

    }

    func testLoadSavedPlaceById() throws {
        placesDataManager.savePlaces(places: places)
        let loadedPlace = placesDataManager.loadSavedPlace(with: gowerSt.id)

        XCTAssertEqual(loadedPlace!.id, gowerSt.id)

    }

    func testLoadSavedPlaceNoMatchReturnsNil() throws {
        placesDataManager.savePlaces(places: places)
        let loadedPlace = placesDataManager.loadSavedPlace(with: "Random ID")
        
        XCTAssertNil(loadedPlace)
    }
    
    func testFindPlace() throws {
        placesDataManager.savePlaces(places: places)
        let place = placesDataManager.findPlace(with: gowerSt.id)
        
        XCTAssertEqual(place!.id, gowerSt.id)
    }

    func testDeleteAllSavedPlaces() throws {
        placesDataManager.savePlaces(places: places)
        placesDataManager.loadAllSavedPlaces()
        
        XCTAssertTrue(!placesDataManager.places.isEmpty)

        placesDataManager.deleteAllSavedPlaces()
        
        XCTAssertTrue(placesDataManager.places.isEmpty)
    }

    func testDeleteSavedPlaceWithId() {
        placesDataManager.savePlaces(places: places)
        let loadedPlace = placesDataManager.loadSavedPlace(with: gowerSt.id)
        placesDataManager.deleteSavedPlace(with: loadedPlace!.id)
        
        XCTAssertNil(placesDataManager.loadSavedPlace(with: gowerSt.id))
    }
    
}
