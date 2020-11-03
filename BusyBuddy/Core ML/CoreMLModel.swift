//
//  MLModel.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 02/11/2020.
//

import Foundation
import CoreML

protocol CoreMLModel {
    var model: MLModel { get set }
    var image: Any { get set }
    
    // Preprocess image into model input
    func preprocess(image: Any) -> MLFeatureProvider
    
    // Predict on input and generate model output
    func predict(input: MLFeatureProvider) -> MLFeatureProvider
    
    // Process model output
    func postprocess(output: MLFeatureProvider) -> [Double]
}
