//
//  MLModel.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//
//  With help from: https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml

import Foundation
import CoreML
import Vision
import UIKit

protocol BusyModel: ObservableObject {
    var images: [UIImage] { get set }
    var request: VNCoreMLRequest { get set }
    var observations: [[VNObservation]] { get set }
    var confidenceThreshold: VNConfidence { get set }
    
    func classify(images: [UIImage]) -> Self
    
    func processResults(for request: VNRequest, error: Error?)
    
    func generateBusyScores() -> [BusyScore]
}

extension BusyModel {

    public func run(on places: [Place]) -> [BusyScore] {
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
            
            let busyScores = self.classify(images: images).generateBusyScores()
            print("INFO: Model finished.")
            return busyScores
        }
        return []
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
    static let model = YOLO()
    private init () {}
    
}
