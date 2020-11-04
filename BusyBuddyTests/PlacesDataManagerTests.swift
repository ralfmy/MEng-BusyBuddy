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
    
    var gowerSt: Place!
    var places: [Place]!
    
    override func setUpWithError() throws {
        self.persistentContainer = CoreDataPersistence(.memory).container
        self.managedObjectContext = self.persistentContainer.viewContext
        self.placesDataManager = PlacesDataManager(persistentContainer: self.persistentContainer, managedObjectContext: self.managedObjectContext)
        
        self.gowerSt = Place(id: "JamCams_00001.07389", commonName: "University St/Gower St", placeType: "JamCam", additionalProperties: [AdditionalProperty(key: "imageUrl", value: "https://s3-eu-west-1.amazonaws.com/jamcams.tfl.gov.uk/00001.07389.jpg")], lat: 51.5239, lon: -0.1341)
        self.places = [gowerSt]
    }
    
    override func tearDownWithError() throws {
        self.placesDataManager.deleteAllSavedPlaces()
    }
    
    func testSavePlaces() throws {
            expectation(
                forNotification: .NSManagedObjectContextDidSave,
                object: managedObjectContext
            ) { _ in
                return true
            }
            
            self.placesDataManager.savePlaces(places: self.places)
            
            waitForExpectations(timeout: 1) { error in
                XCTAssertNil(error, "Save failed")
            }
    }

    func testLoadAllSavedPlaces() throws {
        self.placesDataManager.savePlaces(places: self.places)
        self.placesDataManager.loadAllSavedPlaces()
        
        let places = self.placesDataManager.places
        
        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places[0].commonName, gowerSt.commonName)
        XCTAssertEqual(places[0].placeType, gowerSt.placeType)
        XCTAssertEqual(places[0].lat, gowerSt.lat)
        XCTAssertEqual(places[0].lon, gowerSt.lon)
    }
    
    func testLoadSavedPlacesByCommonName() throws {
        self.placesDataManager.savePlaces(places: self.places)
        let loadedPlaces = self.placesDataManager.loadSavedPlaces(by: "University St/Gower St")

        XCTAssertEqual(loadedPlaces.count, 1)
        XCTAssertEqual(loadedPlaces[0].commonName, gowerSt.commonName)

    }

    func testLoadSavedPlaceById() throws {
        self.placesDataManager.savePlaces(places: self.places)
        let loadedPlace = self.placesDataManager.loadSavedPlace(with: gowerSt.id)

        XCTAssertEqual(loadedPlace!.id, gowerSt.id)

    }

    func testLoadSavedPlaceNoMatchReturnsNil() throws {
        self.placesDataManager.savePlaces(places: self.places)
        let loadedPlace = self.placesDataManager.loadSavedPlace(with: "Random ID")
        
        XCTAssertNil(loadedPlace)
    }

    func testDeleteAllSavedPlaces() throws {
        self.placesDataManager.savePlaces(places: self.places)
        self.placesDataManager.loadAllSavedPlaces()
        
        XCTAssertTrue(!self.placesDataManager.places.isEmpty)

        self.placesDataManager.deleteAllSavedPlaces()
        
        XCTAssertTrue(self.placesDataManager.places.isEmpty)
    }

    func testDeleteSavedPlaceWithId() {
        self.placesDataManager.savePlaces(places: self.places)
        let loadedPlace = self.placesDataManager.loadSavedPlace(with: gowerSt.id)
        self.placesDataManager.deleteSavedPlace(with: loadedPlace!.id)
        
        XCTAssertNil(self.placesDataManager.loadSavedPlace(with: gowerSt.id))
    }
    
}
