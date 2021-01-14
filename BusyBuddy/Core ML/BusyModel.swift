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

protocol BusyModel: AnyObject {
    var images: [UIImage] { get set }
    var request: VNCoreMLRequest { get set }
    var observations: [[VNObservation]] { get set }
    var confidenceThreshold: VNConfidence { get set }
    
    init(confidenceThreshold: VNConfidence)
        
    func processResults(for request: VNRequest, error: Error?)
    
    func generateBusyScores() -> [BusyScore]
}

extension BusyModel {
    
    private func classify(images: [UIImage]) {
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
    }

    public func run(on images: [UIImage]) -> [BusyScore] {
        if !images.isEmpty {
            print("INFO: Running model on \(images.count) images")
            // CHECK SCORE CACHE
            self.classify(images: images)
            let busyScores = self.generateBusyScores()
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
