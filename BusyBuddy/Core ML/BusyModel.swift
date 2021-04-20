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
}

extension BusyModel {
    
    private func classify(images: [UIImage]) {
//        https://stackoverflow.com/questions/51560767/memory-leak-in-do-catch-block-ios-swift/51561341
        
        self.images = images
        self.observations = []

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
    
//    private static let tcv1 = TuriCreateModelv1(confidenceThreshold: 0.6)
//    private static let tcv2 = TuriCreateModelv2(confidenceThreshold: 0.6)
//    private static let tcv3 = TuriCreateModelv3(confidenceThreshold: 0.6)
    private static let resnet = TuriCreateImageClassifier(mlModel: ResNet_50().model, confidenceThreshold: 0.6)
    private static let squeezenet = TuriCreateImageClassifier(mlModel: SqueezeNet_v1_1().model, confidenceThreshold: 0.6)
    private static let vfps = TuriCreateImageClassifier(mlModel: VisionFeaturePrint_Scene().model, confidenceThreshold: 0.6)
    private static let cmlv6 = CreateMLModelv6(confidenceThreshold: 0.6)
    private static let yolo = YOLO()
    private static let yolotiny = YOLO(mlModel: YOLOv3Tiny().model)
    
    static func currentModel(_ defaults: UserDefaults = UserDefaults(suiteName: "group.com.zcabrmy.BusyBuddy")!) -> BusyModel {
        if let rawValue = defaults.integer(forKey: "model") as? Int {
            let modelType = ModelType(rawValue: rawValue)
            switch modelType {
            case .resnet:
                return self.resnet
            case .squeezenet:
                return self.squeezenet
            case .vfps:
                return self.vfps
            case .cmlv6:
                return self.cmlv6
            case .yolo:
                return self.yolo
            case .yolotiny:
                return self.yolotiny
            default:
                return self.vfps
            }
        }
        defaults.set(ModelType.tcv1.rawValue, forKey: "model")
        return self.vfps
    }
}

enum ModelType: Int {
    case tcv1
    case tcv2
    case tcv3
    case resnet
    case squeezenet
    case vfps
    case cmlv6
    case yolo
    case yolotiny
}
