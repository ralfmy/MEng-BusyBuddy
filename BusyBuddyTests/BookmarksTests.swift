//
//  BookmarksTests.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 05/11/2020.
//

import XCTest
import Vision
import CoreML
import os.log

@testable import BusyBuddy

final class BusyModelMock: BusyModel {
    var images: [UIImage]
    var observations: [[VNObservation]]
    var confidenceThreshold: VNConfidence
    
    let model = MLModel()
    
    lazy var request: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: self.model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processResults(for: request, error: error)
            })
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }

    }()
    
    init(confidenceThreshold: VNConfidence = 0.5) {
        self.images = []
        self.observations = []
        self.confidenceThreshold = confidenceThreshold
    }
    
    func processResults(for request: VNRequest, error: Error?) {
        let classifications = [VNClassificationObservation()]
        self.observations.append(classifications)
    }
    
    func generateBusyScores() -> [BusyScore] {
        return [BusyScore()]
    }
    
    
}

class BookmarksTests: XCTestCase {
    private var userDefaults: UserDefaults!
    
    var bookmarksManager: BookmarksManager!

    override func setUpWithError() throws {
        userDefaults = UserDefaults(suiteName: #file)
        userDefaults.removePersistentDomain(forName: #file)
        bookmarksManager = BookmarksManager(userDefaults)
        bookmarksManager.add(place: ExamplePlaces.oxfordCircus)
    }

    override func tearDownWithError() throws {

    }

    func testNobookmarksReturnsEmptyArray() throws {
        XCTAssertTrue(bookmarksManager.getPlaces().isEmpty)
    }
    
    func testAddPlace() throws {
        let places = bookmarksManager.getPlaces()
        
        XCTAssertEqual(places.count, 1)
        XCTAssertEqual(places[0].id, ExamplePlaces.oxfordCircus.id)
    }

    func testRemovePlace() throws {
        bookmarksManager.remove(place: ExamplePlaces.oxfordCircus)
        XCTAssertTrue(bookmarksManager.getPlaces().isEmpty)
    }
    
    func testContainsPlaceTrue() throws {
        XCTAssertTrue(bookmarksManager.contains(place: ExamplePlaces.oxfordCircus))
    }
    
    func testUpdateScores() {
        
    }
}
