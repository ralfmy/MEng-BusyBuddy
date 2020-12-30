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

public final class YOLO: CoreMLModel {
    
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "YOLO")
    
    private let model = YOLOv3()

    var images: [UIImage]?
    var processedInputs: [MLFeatureProvider]?
    var predictionOutput: [MLFeatureProvider]?
    var results: [CoreMLModelResult]
    var confidenceThreshold: Double  // confidence in classification of a person object
    
    private let objClasses = [
        "person", "bicycle", "car", "motorbike", "aeroplane", "bus", "train", "truck", "boat", "traffic light",
        "fire hydrant", "stop sign", "parking meter", "bench", "bird", "cat", "dog", "horse", "sheep", "cow",
        "elephant", "bear", "zebra", "giraffe", "backpack", "umbrella", "handbag", "tie", "suitcase", "frisbee",
        "skis", "snowboard", "sports ball", "kite", "baseball bat", "baseball glove", "skateboard", "surfboard", "tennis racket", "bottle",
        "wine glass", "cup", "fork", "knife", "spoon", "bowl", "banana", "apple", "sandwich", "orange",
        "broccoli", "carrot", "hot dog", "pizza", "donut", "cake", "chair", "sofa", "pottedplant", "bed",
        "diningtable", "toilet", "tvmonitor", "laptop", "mouse", "remote", "keyboard", "cell phone", "microwave", "oven",
        "toaster", "sink", "refrigerator", "book", "clock", "vase", "scissors", "teddy bear", "hair drier", "toothbrush"
    ]
    
    init(confidenceThreshold: Double = 50) {
        self.results = []
        self.confidenceThreshold = confidenceThreshold
    }
    
    public func inputImages(images: [UIImage]) -> Self {
        self.images = images
        return self
    }
    
    public func preprocess() -> Self {
        let scaled: [UIImage] = self.images!.map { $0.scaleTo(targetSize: CGSize(width: 416, height: 416)) }
        let cvPixelBuffer: [CVPixelBuffer] = scaled.map { $0.toCVPixelBuffer()! }
        self.processedInputs = cvPixelBuffer.map { YOLOv3Input(image: $0) }
        return self
    }
    
    public func predict() -> Self {
        if let output = try? model.predictions(inputs: self.processedInputs as! [YOLOv3Input]) {
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
            let confidences = output.featureValue(for: "confidence")?.multiArrayValue
            if confidences!.shape[0].intValue > 0 {
                for i in 0...confidences!.shape[0].intValue - 1 {  // MUST CHECK FOR OFFLINE CAMERAS
                    let dimension = getDimension(i: i, from: confidences!)
                    let maxIndices = getIndicesOfMaxValues(from: dimension)
                    maxIndices.forEach({ index in
                        result.add(item: CoreMLModelResult.ClassificationConfidence(classification: objClasses[index], confidence: (dimension[index] * 100)))
                    })
                }
                self.results.append(result)
            } else {
                self.results.append(CoreMLModelResult())
            }
        }
        return self
    }
    
    public func generateBusyScore(from output: (UIImage, CoreMLModelResult)) -> BusyScore {
        let image = output.0
        let result = output.1
        if let cc = result.getClassificationConfidences() {
            let people = (cc.filter { $0.classification == "person" && $0.confidence >= self.confidenceThreshold })
            self.logger.info("INFO: confidences \(people.map { $0.confidence })")
            return BusyScore(count: people.count, image: image)
        } else {
            return BusyScore(count: -2, image: image)
        }
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
