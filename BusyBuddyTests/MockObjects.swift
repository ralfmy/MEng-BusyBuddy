//
//  MockObjects.swift
//  BusyBuddyTests
//
//  Created by Ralf Michael Yap on 24/01/2021.
//

import XCTest
import UIKit
import CoreML
import Vision

@testable import BusyBuddy

public final class NetworkClientMock: NetworkClient {
    override public func runRequest(request: URLRequest, completion: @escaping (Result<Data, Error>) -> Void) {
        completion(.success(try! JSONEncoder().encode([ExamplePlaces.oxfordCircus])))
    }
}

public final class BusyModelMock: BusyModel {
    public var images: [UIImage]
    public var observations: [[VNObservation]]
    public var confidenceThreshold: VNConfidence
    
    let model = MLModel()
    
    lazy public var request: VNCoreMLRequest = {
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
    
    public init(confidenceThreshold: VNConfidence = 0.5) {
        self.images = []
        self.observations = []
        self.confidenceThreshold = confidenceThreshold
    }
    
    public func processResults(for request: VNRequest, error: Error?) {
        let classifications = [VNClassificationObservation()]
        self.observations.append(classifications)
    }
    
    public func generateBusyScores() -> [BusyScore] {
        return [BusyScore()]
    }
    
    
}
