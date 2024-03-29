//
//  YOLO.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 03/11/2020.
//

import Foundation
import UIKit
import CoreML
import Vision
import os.log

public final class YOLO: BusyModel {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "YOLO")
    
    internal var model: MLModel
    internal var images: [UIImage]
    var observations: [[VNObservation]]
    var confidenceThreshold: VNConfidence
    internal var context: CIContext
    
    init(mlModel: MLModel = YOLOv3().model, confidenceThreshold: VNConfidence = 0.5) {
        self.model = mlModel
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
        
        let objects = results as! [VNRecognizedObjectObservation]
        
        if objects.isEmpty {
            self.logger.info("INFO: No results.")
            self.observations.append([])
        } else {
//            objects.forEach { object in
//                print("\(object.labels.first!.identifier): \(object.labels.first!.confidence)")
//            }
            self.observations.append(objects)
        }
    }
    
    public func generateBusyScores() -> [BusyScore] {
        var busyScores = [BusyScore]()
        for i in 0..<self.observations.count {
            let image = self.images[i]
            let observation = self.observations[i]
            let objects = observation as! [VNRecognizedObjectObservation]
            let people = objects.filter { $0.labels.first!.identifier == "person" && $0.labels.first!.confidence >= self.confidenceThreshold }
            
            switch people.count {
            case 0..<5:
                busyScores.append(BusyScore(score: .notbusy, image: image))
            case 5...:
                busyScores.append(BusyScore(score: .busy, image: image))
            default:
                busyScores.append(BusyScore(score: .unsure, image: image))
            }
        }
        return busyScores
    }
    
    private func getDimension(i: Int, from matrix: MLMultiArray) -> [Double] {
        var dim = [Double]()
        
        for j in 0...matrix.shape[1].intValue - 1 {
            dim.append(matrix[[i, j] as [NSNumber]].doubleValue)
        }
        
        return dim
    }
    
    private func getIndicesOfMaxValues(from array: [Double]) -> [Int] {
        let maxVal = array.max()
        let indices = array.indices.filter { array[$0] == maxVal }
        return indices
    }
    
    // https://developer.apple.com/documentation/vision/recognizing_text_in_images
    private func recogniseDate(image: CVPixelBuffer) {
        
        let requestHandler = VNImageRequestHandler(cvPixelBuffer: image)

        // Create a new request to recognize text.
        let request = VNRecognizeTextRequest(completionHandler: {(request: VNRequest, error: Error?) -> Void in
            guard let observations =
                    request.results as? [VNRecognizedTextObservation] else {
                return
            }
            let recognizedStrings = observations.compactMap { observation in
                // Return the string of the top VNRecognizedText instance.
                return observation.topCandidates(1).first?.string
            }
            
            // Process the recognized strings.
//            print(recognizedStrings[0])
        })

        do {
            // Perform the text-recognition request.
            try requestHandler.perform([request])
        } catch {
            print("Unable to perform the requests: \(error).")
        }
        
    }
    
}
