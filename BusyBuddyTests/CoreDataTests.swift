//
//  CoreDataTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 01/11/2020.
//
//  With help from
//  https://www.donnywals.com/setting-up-a-core-data-store-for-unit-tests/
//  https://www.raywenderlich.com/11349416-unit-testing-core-data-in-ios#toc-anchor-010

import XCTest
import CoreData

@testable import BusyBuddy

class CoreDataTests: XCTestCase {
    var persistentContainer: NSPersistentContainer!
    var managedObjectContext: NSManagedObjectContext!
    var coreDataManager: CoreDataManager!
    
    let places = [Place(id: "Unique ID", commonName: "Common Name", placeType: "Place Type", additionalProperties: [AdditionalProperty(key: "imageUrl", value: "Image URL")], lat: 4.20, lon: 6.9)]
    
    override func setUpWithError() throws {
        self.persistentContainer = CoreDataPersistence(.memory).container
        self.managedObjectContext = self.persistentContainer.viewContext
        self.coreDataManager = CoreDataManager(persistentContainer: self.persistentContainer, managedObjectContext: self.managedObjectContext)
    }
    

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testSavePlaces() throws {
        expectation(
            forNotification: .NSManagedObjectContextDidSave,
            object: managedObjectContext
        ) { _ in
            return true
        }
        
        self.coreDataManager.savePlaces(places: self.places)
        
        waitForExpectations(timeout: 1) { error in
            XCTAssertNil(error, "Save failed")
        }
    }

    func testLoadAllloadedPlaces() throws {
        self.coreDataManager.savePlaces(places: self.places)
        
        let loadedPlaces = self.coreDataManager.loadAllSavedPlaces()
        
        XCTAssertEqual(loadedPlaces.count, 1)
        XCTAssertEqual(loadedPlaces[0].commonName, "Common Name")
        XCTAssertEqual(loadedPlaces[0].placeType, "Place Type")
        XCTAssertEqual(loadedPlaces[0].lat, 4.20)
        XCTAssertEqual(loadedPlaces[0].lon, 6.9)
    }
    
    func testLoadSavedPlacesByCommonName() throws {
        self.coreDataManager.savePlaces(places: self.places)
        
        let loadedPlaces = self.coreDataManager.loadSavedPlaces(by: "Common Name")
        
        XCTAssertEqual(loadedPlaces.count, 1)
        XCTAssertEqual(loadedPlaces[0].commonName, "Common Name")
        
    }
    
    func testLoadSavedPlaceById() throws {
        self.coreDataManager.savePlaces(places: self.places)
        
        let loadedPlace = self.coreDataManager.loadSavedPlace(with: "Unique ID")
        
        XCTAssertEqual(loadedPlace!.id, "Unique ID")

    }
    
    func testLoadSavedPlaceNoMatchReturnsNil() throws {
        self.coreDataManager.savePlaces(places: self.places)
        let loadedPlace = self.coreDataManager.loadSavedPlace(with: "Random ID")
        XCTAssertNil(loadedPlace)
    }
    
    func testDeleteAllSavedPlaces() throws {
        self.coreDataManager.savePlaces(places: self.places)
        var loadedPlaces = self.coreDataManager.loadAllSavedPlaces()
        XCTAssertTrue(!loadedPlaces.isEmpty)

        self.coreDataManager.deleteAllSavedPlaces()
        loadedPlaces = self.coreDataManager.loadAllSavedPlaces()
        XCTAssertTrue(loadedPlaces.isEmpty)
    }
    
    func testDeleteSavedPlaceWithId() {
        self.coreDataManager.savePlaces(places: self.places)
        let loadedPlace = self.coreDataManager.loadSavedPlace(with: "Unique ID")
        self.coreDataManager.deleteSavedPlace(with: loadedPlace!.id)
        XCTAssertNil(self.coreDataManager.loadSavedPlace(with: "Unique ID"))
    }
}
