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

class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void
    
    init(closure: @escaping () -> Void) {
        self.closure = closure
    }
    
    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void
    
    var data: Data?
    var error: Error?
    
    override func dataTask(with url: URL, completionHandler: @escaping CompletionHandler) -> URLSessionDataTask {
        let data = self.data
        let error = self.error
        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}

class TfLUnifiedAPITests: XCTestCase {
    
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "PlacesDataManager")
    
    override func setUpWithError() throws {

    }

    override func tearDownWithError() throws {

    }

    func testGetAllJamCamsAPICall() {
        let api = TfLUnifiedAPI()

        var count = -1;
        let expectation = self.expectation(description: "API Call")
        
        api.fetchAllJamCams() { result in
            switch result {
            case .success(let places):
                count = places.count
                expectation.fulfill()
            case .failure(let err):
                self.logger.error("ERROR: Failure to fetch: \(err as NSObject)")
            }
        }
        
        waitForExpectations(timeout: 5, handler: nil)
        XCTAssertEqual(count, 910)
    }
    
//    func testGetAllJamCamsReturn() {
//        let session = URLSessionMock()
//        let api = TfLUnifiedAPI(session: session)
//
//        let place = Place(commonName: "Oxford St", placeType: "JamCam", additionalProperties: [], lat: 0, lon: 0)
//        let encoder = JSONEncoder()
//        let data = try? encoder.encode(place)
//        session.data = data
//
//        let url = URL(fileURLWithPath: "url")
//
//        var result: Result<[Place], Error>?
//        api.getAllJamCams() {
//            result = $0
//        }
//    }

}
