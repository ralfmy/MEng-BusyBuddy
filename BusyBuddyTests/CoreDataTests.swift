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
    
    let places = [Place(commonName: "Common Name", placeType: "Place Type", additionalProperties: [AdditionalProperty(key: "imageUrl", value: "Image URL")], lat: 4.20, lon: 6.9)]
    
    override func setUpWithError() throws {
        self.persistentContainer = CoreDataContainer(.MEMORY).persistentContainer
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

    func testLoadPlaces() throws {
        self.coreDataManager.savePlaces(places: self.places)
        
        let savedPlaces = self.coreDataManager.loadSavedPlaces()
        
        XCTAssertEqual(savedPlaces.count, 1)
        XCTAssertEqual(savedPlaces[0].commonName, "Common Name")
        XCTAssertEqual(savedPlaces[0].placeType, "Place Type")
        XCTAssertEqual(savedPlaces[0].lat, 4.20)
        XCTAssertEqual(savedPlaces[0].lon, 6.9)
    }
    
    func testDeleteAllPlaces() throws {
        self.coreDataManager.savePlaces(places: self.places)
        var savedPlaces = self.coreDataManager.loadSavedPlaces()
        XCTAssertTrue(!savedPlaces.isEmpty)

        self.coreDataManager.deleteAllPlaces()
        savedPlaces = self.coreDataManager.loadSavedPlaces()
        XCTAssertTrue(savedPlaces.isEmpty)
    }
}
