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

class CoreDataTests: XCTestCase {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesDataManager")
    
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
