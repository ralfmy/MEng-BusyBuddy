//
//  BusyClassifier.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 30/12/2020.
//

import Foundation
import UIKit
import CoreML
import Vision
import os.log

public final class TuriCreateModelv1: BusyModel {
    // No preprocessing, no augmentation
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "TuriCreateClassifierv1")
    
    var model = TuriCreateClassifierv1().model
    
    internal var images: [UIImage]
    var observations: [[VNObservation]]
    var confidenceThreshold: VNConfidence  // Confidence in classification of busy or not_busy
    internal var context: CIContext
    
    init(confidenceThreshold: VNConfidence = 0.5) {
        self.images = []
        self.observations = []
        self.confidenceThreshold = confidenceThreshold
        self.context = CIContext(options: nil)
    }
    
    func applyPreprocessing(to image: CIImage) -> CGImage? {
        let cgImg = self.context.createCGImage(image, from: image.extent)
        return cgImg
    }
        
    func processResults(for request: VNRequest, error: Error?) {
        guard let results = request.results else {
            self.logger.error("ERROR: Unable to run model on image - \(error!.localizedDescription)")
            return
        }
        
        let classifications = results as! [VNClassificationObservation]
        
        if classifications.isEmpty {
            self.logger.info("INFO: No results.")
        } else {
//            classifications.forEach { classification in
//                print("\(classification.identifier): \(classification.confidence)")
//            }
            self.observations.append(classifications)
        }
    }
    
    public func generateBusyScores() -> [BusyScore] {
        var busyScores = [BusyScore]()
        for i in 0..<self.observations.count {
            let image = self.images[i]
            let observation = self.observations[i]
            let classifications = observation as! [VNClassificationObservation]
            if (classifications.first!.confidence >= VNConfidence(self.confidenceThreshold)) {
                self.logger.info("INFO: \(classifications.first!.identifier) with confidence \(classifications.first!.confidence)")
                if classifications.first!.identifier == "busy" {
                    busyScores.append(BusyScore(count: 100, image: image))
                }
                busyScores.append(BusyScore(count: 0, image: image))
            } else {
                self.logger.info("INFO: Label probabilities do not meet confidence threshold - \(classifications.first!.identifier) \(classifications.first!.confidence); \(classifications.last!.identifier) \(classifications.last!.confidence)")
                busyScores.append(BusyScore(count: -2, image: image))
            }
        }
        
        return busyScores
    }
}
