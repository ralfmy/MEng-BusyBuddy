//
//  JamCamsCacheTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 24/01/2021.
//

import XCTest
import os.log

@testable import BusyBuddy

class JamCamsCacheTests: XCTestCase {
    
    private var jamCamsCache = JamCamsCache()
    
    func testGetJamCams() {
        let jamCams = jamCamsCache.getJamCams()
        XCTAssertTrue(jamCams.isEmpty)
    }

    func testSetJamCams() {
        jamCamsCache.setJamCams(jamCams: [ExampleJamCams.gowerSt])
        let cachedJamCams = jamCamsCache.getJamCams()
        XCTAssertEqual(cachedJamCams.count, 1)
        XCTAssertEqual(cachedJamCams[0], ExampleJamCams.gowerSt)
    }

}
