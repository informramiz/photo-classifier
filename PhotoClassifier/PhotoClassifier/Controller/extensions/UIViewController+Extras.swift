//
//  UIViewController+Extras.swift
//  PhotoClassifier
//
//  Created by Apple on 13/03/2020.
//  Copyright © 2020 RR Inc. All rights reserved.
//

import Foundation
import UIKit

extension UIViewController {
    func showAlert(title: String, message: String, completion: (() -> Void)? = nil) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) in
            self.dismiss(animated: true, completion: completion)
        }))
        present(alert, animated: true, completion: nil)
    }
}
