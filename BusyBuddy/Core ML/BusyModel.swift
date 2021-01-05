//
//  MLModel.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import Foundation
import CoreML
import Vision
import UIKit

protocol BusyModel: ObservableObject {
    var observations: [[VNObservation]] { get set }
    var confidenceThreshold: VNConfidence { get set }
    
    lazy var request: VNCoreMLRequest { get set }
}

extension BusyModel {
    
    public func run(on places: [Place]) -> [(UIImage, CoreMLModelResult)] {
        if !places.isEmpty {
            print("INFO: Running model on \(places.count) images")
            // CHECK SCORE CACHE
            var images = [UIImage]()
            places.forEach { place in
                if let data = try? Data(contentsOf: URL(string: place.getImageUrl())!) {
                    if let image = UIImage(data: data) {
                        images.append(image)
                    }
                }
            }
            
            let results = self.inputImages(images: images).preprocess().predict().postprocess().results
            print("INFO: Model finished.")
            return Array(zip(images, results))
            
        }
        return Array(zip([], []))
    }
}

public final class CoreMLModelResult {
    
    public struct ClassificationConfidence {
        public var classification: String
        public var confidence: Double
        
        init(classification: String, confidence: Double) {
            self.classification = classification
            self.confidence = confidence
        }
    }
    
    public var objects = [ClassificationConfidence]()
    
    public func add(item: ClassificationConfidence) {
        self.objects.append(item)
    }
    
    public func getClassificationConfidences() -> [ClassificationConfidence]? {
        if self.objects.isEmpty {
            return nil
        } else {
            return self.objects
        }
    }
}

// Singleton
struct ML {

//    static let model = YOLO()
    static let model = BusyClassifier(confidenceThreshold: 0.6)
    private init () {}
    
}
