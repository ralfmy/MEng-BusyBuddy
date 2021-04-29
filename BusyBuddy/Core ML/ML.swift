//
//  ML.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 22/04/2021.
//

import Foundation

struct ML {
    
    private static let resnet = TuriCreateImageClassifier(mlModel: ResNet_50().model, confidenceThreshold: 0.6)
    private static let squeezenet = TuriCreateImageClassifier(mlModel: SqueezeNet_v1_1().model, confidenceThreshold: 0.6)
    private static let vfps = TuriCreateImageClassifier(mlModel: VisionFeaturePrint_Scene().model, confidenceThreshold: 0.6)
    private static let cmlv6 = CreateMLModelv6(confidenceThreshold: 0.6)
    private static let yolo = YOLO()
    
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
            default:
                return self.vfps
            }
        }
        defaults.set(ModelType.vfps.rawValue, forKey: "model")
        return self.vfps
    }
}

enum ModelType: Int {
    case resnet
    case squeezenet
    case vfps
    case cmlv6
    case yolo
    case yolotiny
}
