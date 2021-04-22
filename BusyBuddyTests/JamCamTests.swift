//
//  JamCamTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 22/04/2021.
//

import XCTest

@testable import BusyBuddy

class JamCamTests: XCTestCase {
    
    private let gowerSt = ExampleJamCams.gowerSt

    func testGetImageUrl() throws {
        let url = gowerSt.getImageUrl()
        XCTAssertEqual(url, "https://gower-st.jpg")
    }
    
    func testGetCameraView() throws {
        let view = gowerSt.getCameraView()
        XCTAssertEqual(view, "gower-st-view")
    }
    
    func testFormattedCommonName() throws {
        let formattedCommonName = gowerSt.formattedCommonName()
        XCTAssertEqual(formattedCommonName, "University St/\nGower St")
    }
    
    func testToggleBookmarke() throws {
        gowerSt.toggleBookmark()
        XCTAssertTrue(gowerSt.isBookmark)
        gowerSt.toggleBookmark()
        XCTAssertFalse(gowerSt.isBookmark)
    }
    
    func testUpdateBusyScore() throws {
        let busyScore = BusyScore(score: .notbusy)
        gowerSt.updateBusyScore(busyScore: busyScore)
        XCTAssertEqual(gowerSt.busyScore?.score, busyScore.score)
    }
    
    func testDownloadImage() throws {
        let image = gowerSt.downloadImage()
        XCTAssertEqual(UIImage(), image)
    }
}
