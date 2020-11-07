//
//  MLModel.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import Foundation
import CoreML
import UIKit

protocol CoreMLModel {    
    // Preprocess image into model input
    func preprocess(image: UIImage) -> MLFeatureProvider
    
    // Predict on input and generate model output
    func predict(input: MLFeatureProvider) -> MLFeatureProvider?
    
    // Process model output
    func postprocess(output: MLFeatureProvider) -> [(Any, Any)]
}

// Singleton
struct ML {
    static let model = YOLO()
    private init () {}
}
