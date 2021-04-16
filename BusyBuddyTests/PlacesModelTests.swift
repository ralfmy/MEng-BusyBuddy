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
    private var jamCamsModel: JamCamsModel!

    override func setUpWithError() throws {
        busyModel = BusyModelMock()
        networkClient = NetworkClientMock()
        jamCamsCache = JamCamsCache()
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        jamCamsModel = JamCamsModel(model: busyModel,
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
        jamCamsModel.removeBookmark(id: ExampleJamCams.oxfordCircus.id)
        jamCamsModel.removeBookmark(id: ExampleJamCams.gowerSt.id)
    }
    
    func testGetAllJamCams() throws {
        let jamCams = jamCamsModel.getAllJamCams()
        
        XCTAssertEqual(jamCams.count, 2)
        XCTAssertTrue(jamCams[0].commonName < jamCams[1].commonName)
    }
    
    func testAddBookmark() throws {
        jamCamsModel.addBookmark(id: ExampleJamCams.gowerSt.id)
        let bookmarkedJamCams = jamCamsModel.getBookmarkedJamCams()
        let bookmarkIds = jamCamsModel.getBookmarkIds()
        let savedBookmarks = try! JSONDecoder().decode([JamCam].self, from: self.userDefaults.object(forKey: "Bookmarks") as! Data)
        
        XCTAssertEqual(bookmarkedJamCams.count, 1)
        XCTAssertEqual(bookmarkIds.count, 1)
        XCTAssertTrue(bookmarkedJamCams.contains(ExampleJamCams.gowerSt))
        XCTAssertTrue(bookmarkIds.contains(ExampleJamCams.gowerSt.id))
        XCTAssertTrue(savedBookmarks.elementsEqual(bookmarkedJamCams))
    }
    
    func testAddExistingBookmark() throws {
        jamCamsModel.addBookmark(id: ExampleJamCams.gowerSt.id)
        jamCamsModel.addBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertEqual(jamCamsModel.getBookmarkIds().count, 1)
    }
    
    func testRemoveJamCam() throws {
        jamCamsModel.addBookmark(id: ExampleJamCams.gowerSt.id)
        jamCamsModel.removeBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertTrue(jamCamsModel.getBookmarkIds().isEmpty)
    }
    
    func testRemoveJamCamNotBookmarked() throws {
        jamCamsModel.addBookmark(id: ExampleJamCams.oxfordCircus.id)
        jamCamsModel.removeBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertEqual(jamCamsModel.getBookmarkIds().count, 1)
    }
    
    func testIsBookmarkTrue() throws {
        jamCamsModel.addBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertTrue(jamCamsModel.isBookmark(id: ExampleJamCams.gowerSt.id))
    }
    
    func testIsBookmarkFalse() throws {
        jamCamsModel.addBookmark(id: ExampleJamCams.gowerSt.id)
        
        XCTAssertFalse(jamCamsModel.isBookmark(id: ExampleJamCams.oxfordCircus.id))
    }
    
    func testUpdateBookmarksScores() throws {
        jamCamsModel.addBookmark(id: ExampleJamCams.gowerSt.id)
        let jamCam = jamCamsModel.getJamCamWithId(ExampleJamCams.gowerSt.id)!
        
        XCTAssertNil(jamCam.busyScore)

        let expectation = self.expectation(description: "Update BusyScores")
        self.measure {
            jamCamsModel.updateBookmarksScores()
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        XCTAssertNotNil(jamCam.busyScore)
        XCTAssertEqual(jamCam.busyScore!.count, 5)
    }
    
    func testUpdateScoreForId() throws {
        let oxfordCircus = jamCamsModel.getJamCamWithId(ExampleJamCams.oxfordCircus.id)!
        let gowerSt = jamCamsModel.getJamCamWithId(ExampleJamCams.gowerSt.id)!
         
        jamCamsModel.updateScoreFor(id: ExampleJamCams.gowerSt.id)
        
        let expectation = self.expectation(description: "Update BusyScores")
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
            expectation.fulfill()
        }
        
        wait(for: [expectation], timeout: 3)
        
        XCTAssertNotNil(gowerSt.busyScore)
        XCTAssertEqual(gowerSt.busyScore!.count, 5)
        
        XCTAssertNil(oxfordCircus.busyScore)
    }
    
    func testLoadJamCamsCacheHit() throws {
        jamCamsCache.setJamCams(jamCams: [ExampleJamCams.exhibitionRd, ExampleJamCams.stGilesCircus])
        
        jamCamsModel = JamCamsModel(model: busyModel,
                                    client: networkClient,
                                    cache: jamCamsCache,
                                    defaults: userDefaults)

        let expectation = self.expectation(description: "Load JamCams")
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            expectation.fulfill()
        }
        wait(for: [expectation], timeout: 1)

        let jamCams = jamCamsModel.getAllJamCams()
        
        XCTAssertEqual(jamCams.count, 2)
        XCTAssertTrue(jamCamsCache.getJamCams().elementsEqual(jamCams))
    }

}
