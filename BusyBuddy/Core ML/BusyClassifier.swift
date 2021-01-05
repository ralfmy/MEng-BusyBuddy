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

public final class BusyClassifier: CoreMLModel {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "BusyClassifier")

    private let model = BusyClassifier5()
    
    var images: [UIImage]
    var processedInputs: [MLFeatureProvider]?
    var predictionOutput: [MLFeatureProvider]?
    var results: [CoreMLModelResult]
    var observations: [[VNObservation]]
    var confidenceThreshold: Double  // Confidence in classification of busy or not_busy
    
    lazy var modelRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: BusyClassifier5().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processResults(for: request, error: error)
            })
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }

    } ()
    
    init(confidenceThreshold: Double = 50) {
        self.images = []
        self.results = []
        self.observations = []
        self.confidenceThreshold = confidenceThreshold
    }
    
    public func inputImages(images: [UIImage]) -> Self {
        self.images = images
        return self
    }
    
    public func preprocess() -> Self {
        let scaled: [UIImage] = self.images.map { $0.scaleTo(targetSize: CGSize(width: 299, height: 299)) }
        let cvPixelBuffer: [CVPixelBuffer] = scaled.map { $0.toCVPixelBuffer()! }
        self.processedInputs = cvPixelBuffer.map { BusyClassifier5Input(image: $0) }
        return self
    }
    
    public func predict() -> Self {
        if let output = try? model.predictions(inputs: self.processedInputs as! [BusyClassifier5Input]) {
            self.predictionOutput = output
        } else {
            self.predictionOutput = nil
        }
        return self
    }
    
    public func postprocess() -> Self {
        self.results = []
        self.predictionOutput!.forEach { output in
            let result = CoreMLModelResult()
            let classLabelProbs = output.featureValue(for: "classLabelProbs")?.dictionaryValue
            classLabelProbs!.forEach { classification, confidence in
                result.add(item: CoreMLModelResult.ClassificationConfidence(classification: classification.description, confidence: Double(confidence) * 100))
            }
            self.results.append(result)
        }
        return self
    }
    
    public func classify(images: [UIImage]) {
        images.forEach { image in
            guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
            
            DispatchQueue.global(qos: .userInteractive).async {
                let handler = VNImageRequestHandler(ciImage: ciImage)
                do {
                    try handler.perform([self.modelRequest])
                } catch {
                    self.logger.error("ERROR: Failed to run model - \(error.localizedDescription)")
                }
            }
        }
    }
    
    public func processResults(for request: VNRequest, error: Error?) {
        self.observations = []
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.logger.error("ERROR: Unable to run model on image - \(error!.localizedDescription)")
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.logger.info("INFO: No results.")
            } else {
                classifications.forEach { classification in
                    print("\(classification.identifier): \(classification.confidence)")
                }
                self.observations.append(classifications)
            }
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
    
    public func generateBusyScore(from output: (UIImage, CoreMLModelResult)) -> BusyScore {
        let image = output.0
        let result = output.1
        if let cc = result.getClassificationConfidences() {
            if let likelyLabelProbs = cc.first { $0.confidence >= self.confidenceThreshold } {
                self.logger.info("INFO: \(likelyLabelProbs.classification) with \(likelyLabelProbs.confidence) confidence")
                if likelyLabelProbs.classification == "busy" {
                    return BusyScore(count: 100, image: image)
                }
                return BusyScore(count: 0, image: image)
            } else {
                self.logger.info("INFO: Label probabilities do not meet confidence threshold - \(cc[0].classification) \(cc[0].confidence); \(cc[1].classification) \(cc[1].confidence)")
                return BusyScore(count: -2, image: image)
            }
        } else {
            return BusyScore(count: -2, image: image)
        }
    }
}
