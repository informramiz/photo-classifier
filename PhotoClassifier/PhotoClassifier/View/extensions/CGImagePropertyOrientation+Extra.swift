//
//  CGImagePropertyOrientation+Extra.swift
//  PhotoClassifier
//
//  Created by Ramiz Raja on 11/03/2020.
//  Copyright © 2020 RR Inc. All rights reserved.
//

import UIKit
import ImageIO

extension CGImagePropertyOrientation {
    /**
    Converts a `UIImageOrientation` to a corresponding
    `CGImagePropertyOrientation`. The cases for each
    orientation are represented by different raw values.
    
    - Tag: ConvertOrientation
    */
    
    init(_ orientation: UIImage.Orientation) {
        switch orientation {
        case .up:
            self = .up
        case .down:
            self = .down
        case .left:
            self = .left
        case .right:
            self = .right
        case .upMirrored:
            self = .upMirrored
        case .downMirrored:
            self = .downMirrored
        case .leftMirrored:
            self = .leftMirrored
        case .rightMirrored:
            self = .rightMirrored
        @unknown default:
            self = .up
        }
    }
}
