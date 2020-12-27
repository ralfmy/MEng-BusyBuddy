//
//  TfLUnifiedAPITests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 31/10/2020.
//
//  With help from
//  https://www.swiftbysundell.com/articles/unit-testing-asynchronous-swift-code/
//  https://www.swiftbysundell.com/articles/mocking-in-swift/

import XCTest
import os.log

@testable import BusyBuddy

class NetworkClientMock: NetworkClient {
    override public func runRequest(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        completion(.success(try! JSONEncoder().encode([ExamplePlace.place])))
    }
}

class TfLUnifiedAPITests: XCTestCase {
    
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "TfLUnifiedAPITests")
    
    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func testGetAllJamCamsAPICall() {
        var count = 0;
        let expectation = self.expectation(description: "API Call")
        
        TfLUnifiedAPI.fetchAllJamCams(client: NetworkClientMock()) { places in
            count = places.count
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(count, 1)
    }    

}
