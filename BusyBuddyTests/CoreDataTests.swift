//
//  CoreDataTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

import XCTest
import CoreData

@testable import BusyBuddy

class CoreDataTests: XCTestCase {
    let view = ContentView(persistentContainer: CoreDataContainer(.MEMORY).persistentContainer)

    override func setUpWithError() throws {
        
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testExample() throws {
        XCTAssertEqual(view.savedPlaces.count, 10)
    }


}
