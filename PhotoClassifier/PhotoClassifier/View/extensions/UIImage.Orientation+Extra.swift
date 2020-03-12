//
//  UIImage.Orientation+Extra.swift
//  PhotoClassifier
//
//  Created by Apple on 12/03/2020.
//  Copyright © 2020 RR Inc. All rights reserved.
//

import Foundation
import UIKit
import ImageIO

extension UIImage.Orientation {
    func toCGImagePropertyOrientation() -> CGImagePropertyOrientation {
        return CGImagePropertyOrientation(self)
    }
}
