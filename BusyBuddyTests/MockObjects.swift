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
        completion(.success(try! JSONEncoder().encode([ExampleJamCams.oxfordCircus, ExampleJamCams.gowerSt])))
    }
}

public final class BusyModelMock: BusyModel {
    
    public var model: MLModel
    public var images: [UIImage]
    public var observations: [[VNObservation]]
    public var confidenceThreshold: VNConfidence
    public var context: CIContext
        
    public init(mlModel: MLModel = MLModel(), confidenceThreshold: VNConfidence = 0.5) {
        self.model = mlModel
        self.images = []
        self.observations = []
        self.confidenceThreshold = confidenceThreshold
        self.context = CIContext(options: nil)
    }
    
    public func applyPreprocessing(to image: CIImage) -> CGImage? {
        let cgImg = self.context.createCGImage(image, from: image.extent)
        return cgImg
    }
    
    public func processResults(for request: VNRequest, error: Error?) {
        let classifications = [VNClassificationObservation()]
        self.observations.append(classifications)
    }
    
    public func generateBusyScores() -> [BusyScore] {
        return [BusyScore(score: .busy)]
    }
    
    public func run(on images: [UIImage]) -> [BusyScore] {
        return generateBusyScores()
    }
    
}
