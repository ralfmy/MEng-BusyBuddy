//
//  MLModel.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//
//  With help from: https://developer.apple.com/documentation/vision/classifying_images_with_vision_and_core_ml  (results in unbounded memory growth)

import Foundation
import CoreML
import Vision
import UIKit

protocol BusyModel: AnyObject {
    
    var model: MLModel { get set }
    var images: [UIImage] { get set }
    var observations: [[VNObservation]] { get set }
    var confidenceThreshold: VNConfidence { get set }
    var context: CIContext { get set }
    
    init(mlModel: MLModel, confidenceThreshold: VNConfidence)
        
    func applyPreprocessing(to image: CIImage) -> CGImage?
    func processResults(for request: VNRequest, error: Error?)
    func generateBusyScores() -> [BusyScore]
    func run(on images: [UIImage]) -> [BusyScore]

}

extension BusyModel {

    public func run(on images: [UIImage]) -> [BusyScore] {
        if !images.isEmpty {
            print("INFO: Running model on \(images.count) images")
            
            self.images = images
            self.observations = []

            // https://stackoverflow.com/questions/51560767/memory-leak-in-do-catch-block-ios-swift/51561341
            images.forEach { image in
                guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
                let before = UIImage(ciImage: ciImage)
                if let preprocessedImage = applyPreprocessing(to: ciImage) {
                    let after = UIImage(cgImage: preprocessedImage)
                    let handler = VNImageRequestHandler(cgImage: preprocessedImage)
                    do {
                        try handler.perform([
                            VNCoreMLRequest(model: VNCoreMLModel(for: self.model), completionHandler: { [weak self] request, error in
                                self?.processResults(for: request, error: error)
                            })
                        ])
                    } catch {
                       print("ERROR: Failed to run model - \(error.localizedDescription)")
                    }
                }
            }
            
            self.context.clearCaches()
            
            let busyScores = self.generateBusyScores()
            
            print("INFO: Model finished.")
            return busyScores
        } else {
            return []
        }
    }
}
