//
//  ImageClassifier.swift
//  PhotoClassifier
//
//  Created by Apple on 11/03/2020.
//  Copyright © 2020 RR Inc. All rights reserved.
//

import Foundation
import Vision
import CoreML
import ImageIO
import UIKit

class ImageClassifier {
    /** Delegate to send results back to the caller */
    var delegate: ((String) -> Void)? = nil
    
    private lazy var model: VNCoreMLModel = {
        do {
            return try VNCoreMLModel(for: MobileNetV2().model)
        } catch {
            fatalError("Failed to ML Model:\n\(error.localizedDescription)")
        }
    }()
    
    private lazy var classificationRequest: VNCoreMLRequest = {
        return VNCoreMLRequest(model: model) { [weak self] (request, error) in
            self?.processClassifications(request, error)
        }
    }()
    
    private func callDelegate(_ result: String) {
        DispatchQueue.main.async {
            self.delegate?(result)
        }
    }
    
    private func processClassifications(_ request: VNRequest, _ error: Error?) {
        guard let results = request.results else {
            callDelegate("Unable to classify image: \(error!.localizedDescription)")
            return
        }
        
        // The `results` will always be `VNClassificationObservation`s, as specified by the Core ML model in this project.
        let classifications = results as! [VNClassificationObservation]
        if classifications.isEmpty {
            callDelegate("Nothing Recognized")
        } else {
            // Display top classifications ranked by confidence in the UI.
            let topClassifications = classifications.prefix(2)
            // Formats the classification for display; e.g. "(0.37) cliff, drop, drop-off".
            let descriptions = topClassifications.map { classification in
                String(format: "(%.2f), %@", classification.confidence, classification.identifier)
            }
            let resultantText = descriptions.joined(separator: "\n")
            callDelegate(resultantText)
        }
    }
    
    func classifyImage(_ image: CIImage, orientation: UIImage.Orientation) {
        // classification process is synchronous (e.g. VNImageRequestHandler) so we call it on a background thread
        DispatchQueue.global(qos: .userInteractive).async {
            let imageHandler = VNImageRequestHandler(ciImage: image, orientation: CGImagePropertyOrientation(orientation))
            do {
                try imageHandler.perform([self.classificationRequest])
            } catch {
                print("Failed to classify image:\n\(error.localizedDescription)")
            }
        }
    }
}
