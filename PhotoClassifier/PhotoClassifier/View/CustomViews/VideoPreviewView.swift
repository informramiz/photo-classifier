//
//  VideoPreviewView.swift
//  PhotoClassifier
//
//  Created by Apple on 10/03/2020.
//  Copyright © 2020 RR Inc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

class VideoPreviewView: UIView {
    override class var layerClass: AnyClass {
        return AVCaptureVideoPreviewLayer.self
    }
    
    var previewLayer: AVCaptureVideoPreviewLayer {
        return layer as! AVCaptureVideoPreviewLayer
    }
}
