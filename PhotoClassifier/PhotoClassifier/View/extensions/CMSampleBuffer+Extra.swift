//
//  CMSampleBuffer+Extra.swift
//  PhotoClassifier
//
//  Created by Apple on 11/03/2020.
//  Copyright © 2020 RR Inc. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit

extension CMSampleBuffer {
    func toCIImage() -> CIImage? {
        let imagePixelBuffer = CMSampleBufferGetImageBuffer(self)
        guard imagePixelBuffer != nil else { return nil }
        return CIImage(cvPixelBuffer: imagePixelBuffer!)
    }
    
    func toUIImage() -> UIImage? {
        return toCIImage()?.toUIImage() ?? nil
    }
}
