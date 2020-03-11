//
//  CIImage+Extra.swift
//  PhotoClassifier
//
//  Created by Apple on 11/03/2020.
//  Copyright © 2020 RR Inc. All rights reserved.
//

import Foundation
import UIKit

extension CIImage {
    func toUIImage() -> UIImage {
        return UIImage(ciImage: self)
    }
}
