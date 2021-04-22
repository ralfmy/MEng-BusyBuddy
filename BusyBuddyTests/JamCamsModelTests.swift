//
//  JamCamsModelTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 10/02/2021.
//

import XCTest

@testable import BusyBuddy

class JamCamsModelTests: XCTestCase {
    private var busyModel: BusyModel!
    private var networkClient: NetworkClient!
    private var jamCamsCache: JamCamsCache!
    private var userDefaults: UserDefaults!
    private var jamCamsManager: JamCamsManager!

    override func setUpWithError() throws {
        busyModel = BusyModelMock()
        networkClient = NetworkClientMock()
        jamCamsCache = JamCamsCache()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        jamCamsManager = JamCamsManager(model: busyModel,
                                    client: networkClient,
                                    cache: jamCamsCache,
                                    defaults: userDefaults)
        
        let expectation = self.expectation(description: "Get JamCams")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)
    }
    
    override func tearDownWithError() throws {
        jamCamsManager.removeBookmark(id: ExampleJamCams.oxfordCircus.id)
        jamCamsManager.removeBookmark(id: ExampleJamCams.gowerSt.id)
    }
    
    func testGetAllJamCams() throws {
        let jamCams = jamCamsManager.getAllJamCams()
        
        XCTAssertEqual(jamCams.count, 2)
        XCTAssertTrue(jamCams[0].commonName < jamCams[1].commonName)
    }
    
    func testAddBookmark() throws {
        jamCamsManager.addBookmark(id: ExampleJamCams.gowerSt.id)
        let bookmarkedJamCams = jamCamsManager.getBookmarkedJamCams()
        let bookmarkIds = jamCamsManager.getBookmarkIds()
        let savedBookmarks = try! JSONDecoder().decode([JamCam].self, from: self.userDefaults.object(forKey: "Bookmarks") as! Data)
        
        XCTAssertEqual(bookmarkedJamCams.count, 1)
        XCTAssertEqual(bookmarkIds.count, 1)
        XCTAssertTrue(bookmarkedJamCams.contains(ExampleJamCams.gowerSt))
        XCTAssertTrue(bookmarkIds.contains(ExampleJamCams.gowerSt.id))
        XCTAssertTrue(savedBookmarks.elementsEqual(bookmarkedJamCams))
    }
    
    func testAddExistingBookmark() throws {
        jamCamsManager.addBookmark(id: ExampleJamCams.gowerSt.id)
        jamCamsManager.addBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertEqual(jamCamsManager.getBookmarkIds().count, 1)
    }
    
    func testRemoveJamCam() throws {
        jamCamsManager.addBookmark(id: ExampleJamCams.gowerSt.id)
        jamCamsManager.removeBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertTrue(jamCamsManager.getBookmarkIds().isEmpty)
    }
    
    func testRemoveJamCamNotBookmarked() throws {
        jamCamsManager.addBookmark(id: ExampleJamCams.oxfordCircus.id)
        jamCamsManager.removeBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertEqual(jamCamsManager.getBookmarkIds().count, 1)
    }
    
    func testIsBookmarkTrue() throws {
        jamCamsManager.addBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertTrue(jamCamsManager.isBookmark(id: ExampleJamCams.gowerSt.id))
    }
    
    func testIsBookmarkFalse() throws {
        jamCamsManager.addBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertFalse(jamCamsManager.isBookmark(id: ExampleJamCams.oxfordCircus.id))
    }
    
    func testUpdateBookmarksScores() throws {
        jamCamsManager.addBookmark(id: ExampleJamCams.gowerSt.id)
        let jamCam = jamCamsManager.getJamCamWithId(ExampleJamCams.gowerSt.id)!
        
        XCTAssertNil(jamCam.busyScore)

        let expectation = self.expectation(description: "Update BusyScores")
        self.measure {
            jamCamsManager.updateBookmarksScores()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }

        wait(for: [expectation], timeout: 3)
        XCTAssertNotNil(jamCam.busyScore)
        XCTAssertEqual(jamCam.busyScore!.score, .busy)
    }
    
    func testUpdateScoreForId() throws {
        let oxfordCircus = jamCamsManager.getJamCamWithId(ExampleJamCams.oxfordCircus.id)!
        let gowerSt = jamCamsManager.getJamCamWithId(ExampleJamCams.gowerSt.id)!
         
        jamCamsManager.updateScoreFor(id: ExampleJamCams.gowerSt.id)
        
        let expectation = self.expectation(description: "Update BusyScores")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        XCTAssertNotNil(gowerSt.busyScore)
        XCTAssertEqual(gowerSt.busyScore!.score, .busy)
        
        XCTAssertNil(oxfordCircus.busyScore)
    }
    
    func testLoadJamCamsCacheHit() throws {
        jamCamsCache.setJamCams(jamCams: [ExampleJamCams.exhibitionRd, ExampleJamCams.stGilesCircus])
        
        jamCamsManager = JamCamsManager(model: busyModel,
                                    client: networkClient,
                                    cache: jamCamsCache,
                                    defaults: userDefaults)

        let expectation = self.expectation(description: "Load JamCams")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        let jamCams = jamCamsManager.getAllJamCams()
        
        XCTAssertEqual(jamCams.count, 2)
        XCTAssertTrue(jamCamsCache.getJamCams().elementsEqual(jamCams))
    }

}
