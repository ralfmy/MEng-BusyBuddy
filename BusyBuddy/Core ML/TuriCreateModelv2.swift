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

public final class TuriCreateModelv2: BusyModel {
    // With preprocessing, no augmentation
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "TuriCreateModelv2")
    
    let classifier = TuriCreateClassifierv2()

    lazy var request: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: self.classifier.model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processResults(for: request, error: error)
            })
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }

    }()
    
    internal var images: [UIImage]
    var observations: [[VNObservation]]
    var confidenceThreshold: VNConfidence  // Confidence in classification of busy or not_busy
    
    init(confidenceThreshold: VNConfidence = 0.5) {
        self.images = []
        self.observations = []
        self.confidenceThreshold = confidenceThreshold
        
    }
    
    private func applyGaussianBlur(_ input: CIImage, radius: Double) -> CIImage? {
        let gaussianBlurFilter = CIFilter(name: "CIGaussianBlur")
        gaussianBlurFilter?.setValue(input, forKey: "inputImage")
        gaussianBlurFilter?.setValue(radius, forKey: "inputRadius")
        return gaussianBlurFilter?.outputImage
    }
    
    private func applyGreyscale(_ input: CIImage) -> CIImage? {
        //https://stackoverflow.com/questions/33028684/how-to-implement-a-grayscale-filter-using-coreimage-filters
        
        let colourControlsFilter = CIFilter(name: "CIColorControls")
        colourControlsFilter?.setValue(input, forKey: "inputImage")
        colourControlsFilter?.setValue(0.0, forKey: "inputBrightness")
        colourControlsFilter?.setValue(0.0, forKey: "inputSaturation")
        colourControlsFilter?.setValue(1.1, forKey: "inputContrast")
        
        let temp = colourControlsFilter?.outputImage
        
        let exposureAdjustFilter = CIFilter(name: "CIExposureAdjust")
        exposureAdjustFilter?.setValue(temp, forKey: "inputImage")
        exposureAdjustFilter?.setValue(0.7, forKey: "inputEV")
        
        return exposureAdjustFilter?.outputImage
    }
    
    func applyPreprocessing(to image: CIImage) -> CIImage? {
//        if let blurredImage = applyGaussianBlur(image, radius: 0.8) {
//            if let greyscaleImage = applyGreyscale(blurredImage) {
//                let outputImage = greyscaleImage
//                return outputImage
//            }
//        }
//        return nil
        return image
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
