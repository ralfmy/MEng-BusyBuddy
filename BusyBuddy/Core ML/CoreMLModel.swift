//
//  MLModel.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import Foundation
import CoreML
import UIKit

protocol CoreMLModel: ObservableObject {
    var images: [UIImage]? { get set }
    var processedInputs: [MLFeatureProvider]? { get set }
    var predictionOutput: [MLFeatureProvider]? { get set }
    var results: [CoreMLModelResult] { get set }
    var threshold: Double { get set }
    
    func inputImages(images: [UIImage]) -> Self
    
    // Preprocess image into model input
    func preprocess() -> Self
    
    // Predict on input and generate model output
    func predict() -> Self
    
    // Process model output
    func postprocess() -> Self
}

extension CoreMLModel {
    
    public func run(on places: [Place]) {
        if !places.isEmpty {
            print("INFO: Running model on \(places.count) images")
            // CHECK SCORE CACHE
            var images = [UIImage]()
            places.forEach { place in
                if let data = try? Data(contentsOf: URL(string: place.getImageUrl())!) {
                    if let uiImage = UIImage(data: data) {
                        images.append(uiImage)
                    }
                }
            }
            let results = self.inputImages(images: images).preprocess().predict().postprocess().results
            self.updateBusyScores(places: places, results: results)
        }
    }

    private func updateBusyScores(places: [Place], results: [CoreMLModelResult]) {
        for i in 0..<results.count {
            if results[i].getObjectConfidences() != nil {
                let peopleCount = (results[i].objects.filter { $0.objClass == "person" && $0.confidence >= self.threshold }).count
                places[i].busyScore = BusyScore(count: peopleCount)
            } else {
                places[i].busyScore = BusyScore()
            }
        }
        print("INFO: Model finished.")
    }
}

class CoreMLModelResult {
    
    struct ObjectClassConfidence {
        public var objClass: String
        public var confidence: Double
        
        init(objClass: String, confidence: Double) {
            self.objClass = objClass
            self.confidence = confidence
        }
    }
    
    public var objects = [ObjectClassConfidence]()
    
    public func add(item: ObjectClassConfidence) {
        self.objects.append(item)
    }
    
    public func getObjectConfidences() -> [ObjectClassConfidence]? {
        if self.objects.isEmpty {
            return nil
        } else {
            return self.objects
        }
    }
}

// Singleton
struct ML {

    static let model = YOLO()
    private init () {}
    
}
