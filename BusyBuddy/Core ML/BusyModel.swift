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
        
    func applyPreprocessing(to image: CIImage) -> CIImage?
    
    func processResults(for request: VNRequest, error: Error?)
    
    func generateBusyScores() -> [BusyScore]
}

extension BusyModel {
    
    private func classify(images: [UIImage]) {
        self.images = images
        self.observations = []

        images.forEach { image in
            guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
            
            if let preprocessedImage = applyPreprocessing(to: ciImage) {
                let uiimage = UIImage(ciImage: preprocessedImage)
                let handler = VNImageRequestHandler(ciImage: preprocessedImage)
                do {
                    try handler.perform([self.request])
                } catch {
                   print("ERROR: Failed to run model - \(error.localizedDescription)")
                }
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

struct ML {
    
    private static let tcv1 = TuriCreateModelv1(confidenceThreshold: 0.6)
    private static let tcv2 = TuriCreateModelv2(confidenceThreshold: 0.6)
    private static let tcv3 = TuriCreateModelv3(confidenceThreshold: 0.6)
    private static let cmlv6 = CreateMLModelv6(confidenceThreshold: 0.6)
    private static let yolo = YOLO()
    private static let yolotiny = YOLOTiny()
    
    static func currentModel(_ defaults: UserDefaults = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!) -> BusyModel {
        if let rawValue = defaults.integer(forKey: "model") as? Int {
            let modelType = ModelType(rawValue: rawValue)
            switch modelType {
            case .tcv1:
                return self.tcv1
            case .tcv2:
                return self.tcv2
            case .tcv3:
                return self.tcv3
            case .cmlv6:
                return self.cmlv6
            case .yolo:
                return self.yolo
            case .yolotiny:
                return self.yolotiny
            default:
                return self.tcv3
            }
        }
        defaults.set(ModelType.tcv1.rawValue, forKey: "model")
        return self.tcv3
    }
}

enum ModelType: Int {
    case tcv1
    case tcv2
    case tcv3
    case cmlv6
    case yolo
    case yolotiny
}
