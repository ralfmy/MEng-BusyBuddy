//
//  BusyBuddyUITests.swift
//  BusyBuddyUITests
//
//  Created by Ralf Michael Yap on 01/11/2020.
//

import XCTest

class BusyBuddyUITests: XCTestCase {
    var app: XCUIApplication!

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.

        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false

        app = XCUIApplication()
        app.launchArguments = ["enable-testing"]
        app.launch()
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testLaunchOnBookmarksTab() throws {
        XCTAssertTrue(app.navigationBars["Bookmarks"].exists)
    }
    
    func testBookmarksNavigationBarItems() throws {
        let navigationBarItems = app.navigationBars["Bookmarks"].buttons
        XCTAssertTrue(navigationBarItems["magnifyingglass"].isHittable)
        XCTAssertTrue(navigationBarItems["arrow.clockwise"].isHittable)
    }
    
    func testBookmarksGridItems() throws {
        let bookmarksGrid = app.otherElements["BookmarksGrid"]
        XCTAssertTrue(bookmarksGrid.exists)
        XCTAssertEqual(bookmarksGrid.buttons.count, 4)
    }

//    func testLaunchPerformance() throws {
//        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, *) {
//            // This measures how long it takes to launch your application.
//            measure(metrics: [XCTApplicationLaunchMetric()]) {
//                XCUIApplication().launch()
//            }
//        }
//    }
}
