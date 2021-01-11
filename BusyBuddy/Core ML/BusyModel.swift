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
        
    func processResults(for request: VNRequest, error: Error?)
    
    func generateBusyScores() -> [BusyScore]
}

extension BusyModel {
    
    private func classify(images: [UIImage]) -> Self {
        self.images = images
        self.observations = []

        images.forEach { image in
            guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
            
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.request])
            } catch {
               print("ERROR: Failed to run model - \(error.localizedDescription)")
            }
        }
        
        return self
    }

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

// Singleton
struct ML {

//    static let model = YOLO()
    static let model = BusyClassifier()
    private init () {}
    
}
