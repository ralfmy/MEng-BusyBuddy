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
    
//    func testGetAllJamCamsReturn() {
//        let session = URLSessionMock()
//        let api = TfLUnifiedAPI(session: session)
//
//        let place = CoreDataPlace(commonName: "Oxford St", placeType: "JamCam", additionalProperties: [], lat: 0, lon: 0)
//        let encoder = JSONEncoder()
//        let data = try? encoder.encode(place)
//        session.data = data
//
//        let url = URL(fileURLWithPath: "url")
//
//        var result: Result<[CoreDataPlace], Error>?
//        api.getAllJamCams() {
//            result = $0
//        }
//    }

}
