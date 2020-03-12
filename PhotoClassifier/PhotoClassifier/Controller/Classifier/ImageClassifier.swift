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
import Combine

class ImageClassifier {
    /** Delegate to send results back to the caller */
    var delegate: ((String) -> Void)? = nil
    
    /** Publisher to manage frames and to handle backpressure*/
    private let imagePublisher = PassthroughSubject<CIImage, Never>()
    private var subscriber: AnyCancellable? = nil
    
    private lazy var model: VNCoreMLModel = {
        do {
            return try VNCoreMLModel(for: MobileNet().model)
        } catch {
            fatalError("Failed to ML Model:\n\(error.localizedDescription)")
        }
    }()
    
    private lazy var classificationRequest: VNCoreMLRequest = {
        let request = VNCoreMLRequest(model: model) { [weak self] (request, error) in
            self?.processClassifications(request, error)
        }
        request.imageCropAndScaleOption = .centerCrop
        return request
    }()
    
    func classifyImage(_ ciImage: CIImage) {
        if subscriber == nil {
            subscriber = imagePublisher
                .map {($0, $0.toUIImage().imageOrientation.toCGImagePropertyOrientation())}
                .throttle(for: .milliseconds(500), scheduler: RunLoop.main, latest: true)
                .sink { (imageData: (CIImage, CGImagePropertyOrientation)) in
                    self.classifyImage(imageData.0, orientation: imageData.1)
            }
        }
        imagePublisher.send(ciImage)
    }
    
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
    
    private func classifyImage(_ image: CIImage, orientation: CGImagePropertyOrientation) {
        // classification process is synchronous (e.g. VNImageRequestHandler) so we call it on a background thread
        DispatchQueue.global(qos: .userInteractive).async {
            let imageHandler = VNImageRequestHandler(ciImage: image, orientation: orientation)
            do {
                try imageHandler.perform([self.classificationRequest])
            } catch {
                print("Failed to classify image:\n\(error.localizedDescription)")
            }
        }
    }
    
    
}
