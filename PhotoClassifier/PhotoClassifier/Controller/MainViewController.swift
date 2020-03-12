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
    @IBOutlet weak var classificationLabel: UILabel!
    private let session = AVCaptureSession()
    private let sessionQueue = DispatchQueue(label: "sessionQueue")
    private let processingQueue = DispatchQueue(label: "outputQueue")
    private var sessionSetupResult: SessionSetupResult = .success
    private let imageClassifier = ImageClassifier()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        //make visual effects view round
        self.classificationLabel.superview?.superview?.layer.cornerRadius = 10
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if isAnyCameraAvailable() {
            startClassification()
        } else {
            showAlert(title: "Camera Required", message: "This application requires a camera to work.") {
                fatalError("Camera permission is not granted")
            }
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        sessionQueue.async {
            if self.session.isRunning {
                self.session.stopRunning()
            }
        }
    }
    
    private func startClassification() {
        verifyAccessAndSetupSession()
        (self.view as! VideoPreviewView).previewLayer.session = session
        imageClassifier.delegate = { (result: String) in
            self.classificationLabel.text = result
        }
    }
    
    private func isAnyCameraAvailable() -> Bool {
        return UIImagePickerController.isSourceTypeAvailable(.camera)
    }
    
    private func verifyAccessAndSetupSession() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
        case .authorized:
            setupCaptureSession()
        case .notDetermined: //user has not been asked yet so ask now
            requestAccessAndSetupSession()
        default:
            sessionSetupResult = .notAuthorized
            self.showCameraPermissionRequiredAlert()
        }
    }
    
    private func requestAccessAndSetupSession() {
        AVCaptureDevice.requestAccess(for: .video) { (granted) in
            if granted {
                self.setupCaptureSession()
            } else {
                self.sessionSetupResult = .notAuthorized
                self.showCameraPermissionRequiredAlert()
            }
        }
    }
    
    private func showCameraPermissionRequiredAlert() {
        DispatchQueue.main.async {
            self.showAlert(title: "Camera Permission Required",
                           message: "This application needs camera permission to work. Please go to settings and grant camera permission.") {
                            fatalError("Camera permission is not granted")
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
        return addInputDevice {
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
    func captureOutput(_ output: AVCaptureOutput, didOutput sampleBuffer: CMSampleBuffer, from connection: AVCaptureConnection) {
        guard let ciImage = sampleBuffer.toCIImage() else { return }
        imageClassifier.classifyImage(ciImage)
    }
}
