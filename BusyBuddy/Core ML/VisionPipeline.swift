//
//  VisionPipeline.swift
//  BusyBuddy
//
//  Created by Ralf Michael Yap on 04/01/2021.
//

import Vision
import CoreML
import UIKit
import os.log

public final class VisionPipeline {
    private let logger = Logger(subsystem: "com.zcabrmy.BusyBuddy", category: "VisionPipeline")
    
    lazy var modelRequest: VNCoreMLRequest = {
        do {
            let model = try VNCoreMLModel(for: BusyClassifier5().model)
            let request = VNCoreMLRequest(model: model, completionHandler: { [weak self] request, error in
                self?.processResults(for: request, error: error)
            })
            request.imageCropAndScaleOption = .scaleFill
            return request
        } catch {
            fatalError("Failed to load Vision ML model: \(error)")
        }

    } ()
    
    public func predict(on image: UIImage) {
        guard let ciImage = CIImage(image: image) else { fatalError("Unable to create \(CIImage.self) from \(image).") }
        
        DispatchQueue.global(qos: .userInteractive).async {
            let handler = VNImageRequestHandler(ciImage: ciImage)
            do {
                try handler.perform([self.modelRequest])
            } catch {
                self.logger.error("ERROR: Failed to run model - \(error.localizedDescription)")
            }
        }
    }
    
    public func processResults(for request: VNRequest, error: Error?) {
        DispatchQueue.main.async {
            guard let results = request.results else {
                self.logger.error("ERROR: Unable to run model on image - \(error!.localizedDescription)")
                return
            }
            
            let classifications = results as! [VNClassificationObservation]
            
            if classifications.isEmpty {
                self.logger.info("INFO: No results.")
            } else {
                classifications.forEach { classification in
                    print("\(classification.identifier): \(classification.confidence)")
                }
            }
        }
    }
    
}
