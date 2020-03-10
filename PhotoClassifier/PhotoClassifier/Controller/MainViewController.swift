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
    
    override func viewWillAppear(_ animated: Bool) {
        verifyAccessAndSetupSession()
        (self.view as! VideoPreviewView).previewLayer.session = session
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        sessionQueue.async {
            self.session.stopRunning()
        }
    }
    
    private func verifyAccessAndSetupSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined: //user has not been asked yet so ask now
            requestAccessAndSetupSession()
        default:
            sessionSetupResult = .notAuthorized
        }
    }
    
    private func requestAccessAndSetupSession() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                self.setupCaptureSession()
            } else {
                self.sessionSetupResult = .notAuthorized
            }
        }
    }

    private func setupCaptureSession() {
        if sessionSetupResult != .success {
            return
        }
        
        let setSessionResult = {(result: Bool) in
            self.sessionSetupResult = result ? .success : .failed
        }
        
        sessionQueue.async {
            self.session.beginConfiguration()
            var result = self.addInput()
            setSessionResult(result)
            result = self.addOutput()
            setSessionResult(result)
            self.session.commitConfiguration()
            self.session.startRunning()
        }
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
