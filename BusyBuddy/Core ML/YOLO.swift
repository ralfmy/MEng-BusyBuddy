//
//  YOLO.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 03/11/2020.
//

import Foundation
import CoreML

class YOLO: CoreMLModel {
    var model: MLModel
    
    var image: Any
    
    init(image: Any) {
        self.image = image
    }
    
    func preprocess(image: Any) -> MLFeatureProvider {
        <#code#>
    }
    
    func predict(input: MLFeatureProvider) -> MLFeatureProvider {
        <#code#>
    }
    
    func postprocess(output: MLFeatureProvider) -> [Double] {
        <#code#>
    }
    
    
}
