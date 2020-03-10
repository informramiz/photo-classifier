//
//  ViewController.swift
//  PhotoClassifier
//
//  Created by Ramiz Raja on 09/03/2020.
//  Copyright © 2020 RR Inc. All rights reserved.
//

import UIKit
import AVFoundation

class MainViewController: UIViewController {
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let processingQueue = DispatchQueue(label: "outputQueue")
    private var sessionSetupResult: SessionSetupResult = .success

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }

    // Call this on sessionQueue
    private func setupCaptureSession() {
        if sessionSetupResult != .success {
            return
        }
        
        let setSessionResult = {(result: Bool) in
            self.sessionSetupResult = result ? .success : .failed
        }
        
        session.beginConfiguration()
        var result = addInput()
        setSessionResult(result)
        result = addOutput()
        setSessionResult(result)
        session.commitConfiguration()
    }
    
    private func addInput() -> Bool {
        return addInputDevice { () -> AVCaptureDevice? in
            var inputDevice: AVCaptureDevice?
            if let dualCameraDevice = AVCaptureDevice.default(.builtInDualCamera, for: .video, position: .back) {
                inputDevice = dualCameraDevice
            } else if let wideAngleCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .back) {
                inputDevice = wideAngleCameraDevice
            } else if let frontCameraDevice = AVCaptureDevice.default(.builtInWideAngleCamera, for: .video, position: .front) {
                inputDevice = frontCameraDevice
            }
            return inputDevice
        }
    }

    // Call this method from sessionQueue
    private func addInputDevice(block: () -> AVCaptureDevice?) -> Bool {
        let inputDevice = block()
        guard let videoInputDevice = inputDevice else {
            print("Unable to find input device")
            return false
        }
        do {
            let sessionInput = try AVCaptureDeviceInput(device: videoInputDevice)
            guard session.canAddInput(sessionInput) else {
                print("Unable to add input to session")
                return false
            }
            session.addInput(sessionInput)
            return true
        } catch {
            print(error.localizedDescription)
            return false
        }
    }
    
    // Call this method from sessionQueue
    private func addOutput() -> Bool {
        let sessionOutput = AVCaptureVideoDataOutput()
        guard session.canAddOutput(sessionOutput) else {
            print("Unable to add output to session")
            return false
        }
        sessionOutput.setSampleBufferDelegate(self, queue: processingQueue)
        session.addOutput(sessionOutput)
        return true
    }
}

extension MainViewController: AVCaptureVideoDataOutputSampleBufferDelegate {
    func captureOutput(_ output: AVCaptureOutput, didDrop sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        //TODO
    }
}
