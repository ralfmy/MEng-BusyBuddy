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
    var placesDataManager: PlacesDataManager!
    
    override func setUpWithError() throws {
        self.persistentContainer = CoreDataPersistence(.memory).container
        self.managedObjectContext = self.persistentContainer.viewContext
        self.placesDataManager = PlacesDataManager(persistentContainer: self.persistentContainer, managedObjectContext: self.managedObjectContext)
    }
    

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
}
