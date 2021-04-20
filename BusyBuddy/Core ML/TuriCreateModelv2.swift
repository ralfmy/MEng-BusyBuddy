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
    
    internal var model: MLModel
    internal var images: [UIImage]
    var observations: [[VNObservation]]
    var confidenceThreshold: VNConfidence  // Confidence in classification of busy or not_busy
    internal var context: CIContext
    
    init(mlModel: MLModel = TuriCreateClassifierv2().model, confidenceThreshold: VNConfidence = 0.5) {
        self.model = mlModel
        self.images = []
        self.observations = []
        self.confidenceThreshold = confidenceThreshold
        self.context = CIContext(options: nil)
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
    
    private func brightenLowlight(_ input: CIImage) -> CIImage? {
        let hour = Calendar.current.component(.hour, from: Date())
        if (hour >= 0 && hour < 7) || (hour > 19) {
            let exposureAdjustFilter = CIFilter(name: "CIExposureAdjust")
            exposureAdjustFilter?.setValue(input, forKey: "inputImage")
            exposureAdjustFilter?.setValue(1.1, forKey: "inputEV")
            return exposureAdjustFilter?.outputImage
        } else {
            return input
        }
    }
    
    func applyPreprocessing(to image: CIImage) -> CGImage? {
//        https://www.raywenderlich.com/2305-core-image-tutorial-getting-started#toc-anchor-010
        if let brightenedImage = brightenLowlight(image) {
            if let blurredImage = applyGaussianBlur(brightenedImage, radius: 0.8) {
                if let greyscaleImage = applyGreyscale(blurredImage) {
                    let outputImage = greyscaleImage
                    let cgImg = self.context.createCGImage(outputImage, from: outputImage.extent)
                    return cgImg
                }
            }
        }
        return nil
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
                    busyScores.append(BusyScore(score: .busy, image: image))
                }
                busyScores.append(BusyScore(score: .notbusy, image: image))
            } else {
                self.logger.info("INFO: Label probabilities do not meet confidence threshold - \(classifications.first!.identifier) \(classifications.first!.confidence); \(classifications.last!.identifier) \(classifications.last!.confidence)")
                busyScores.append(BusyScore(score: .unsure, image: image))
            }
        }
        
        return busyScores
    }
}
