
//
//  CameraController.swift
//  Swift-Camera-Overlay
//
//  Created by Ricky Lee on 2022/6/1.
//

import AVFoundation
import UIKit

class CameraController: NSObject {
    var captureSession: AVCaptureSession?
    var frontCamera: AVCaptureDevice?
    var rearCamera: AVCaptureDevice?
    
    var currentCameraPosition: CameraPosition?
    var frontCameraInput: AVCaptureDeviceInput?
    var rearCameraInput: AVCaptureDeviceInput?
    
    var photoOutput: AVCapturePhotoOutput?
    var previewLayer: AVCaptureVideoPreviewLayer?
    
    var flashMode = AVCaptureDevice.FlashMode.off
    
    var photoCaptureCompletionBlock: ((UIImage?, Error?, Data?) -> Void)?
    
    // Setup device, input, and output
    func prepare(completionHandler: @escaping (Error?) -> Void) {
        func createCaptureSession(){
            self.captureSession = AVCaptureSession()
        }
        
        func configureCaptureDevices() throws {
            // some device uses .builtInWideAngleCamera, some uses builtInDualCamera, iPhone SE uses the former
            let session = AVCaptureDevice.DiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaType.video, position: .unspecified)
            let cameras = session.devices.compactMap { $0 }

            guard !cameras.isEmpty else { throw CameraControllerError.noCameraAvailable }
           
            for camera in cameras {
                if camera.position == .front {
                    self.frontCamera = camera
                }
                
                if camera.position == .back {
                    self.rearCamera = camera
                    
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    camera.unlockForConfiguration()
                }
            }
        }
        
        func configureDeviceInputs() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            if let rearCamera = self.rearCamera {
                self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
                if captureSession.canAddInput(self.rearCameraInput!) { captureSession.addInput(self.rearCameraInput!) }
                self.currentCameraPosition = .rear
            }
            
            else if let frontCamera = self.frontCamera {
                self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
                
                if captureSession.canAddInput(self.frontCameraInput!) { captureSession.addInput(self.frontCameraInput!) }
                else { throw CameraControllerError.inputsAreInvalid }
                self.currentCameraPosition = .front
            }
            
            else { throw CameraControllerError.noCameraAvailable }
        }
        
        func configurePhotoInput() throws {
            guard let captureSession = self.captureSession else { throw CameraControllerError.captureSessionIsMissing }
            
            self.photoOutput = AVCapturePhotoOutput()
            self.photoOutput!.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecType.jpeg])], completionHandler: nil)
            
            if captureSession.canAddOutput(self.photoOutput!) { captureSession.addOutput(self.photoOutput!) }
            captureSession.startRunning()
        }
        
        DispatchQueue(label: "prepare").async {
            do {
                createCaptureSession()
                try configureCaptureDevices()
                try configureDeviceInputs()
                try configurePhotoInput()
            }
            
            catch {
                DispatchQueue.main.async {
                    completionHandler(error)
                }
                
                return
            }
            
            DispatchQueue.main.async {
                completionHandler(nil)
            }
        }
    }
    
    // Return capture data to view
    func displayPreview(on view: UIView, withFrame frame: CGRect) throws {
        guard let captureSession = self.captureSession, captureSession.isRunning else { throw CameraControllerError.captureSessionIsMissing }
        
        self.previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        self.previewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
        self.previewLayer?.connection?.videoOrientation = .portrait
        
        view.layer.insertSublayer(self.previewLayer!, at: 0)
        self.previewLayer?.frame = frame
    }
    
    // Switch Camera
    func switchCameras() throws {
        guard let currentCameraPosition = currentCameraPosition, let captureSession = self.captureSession, captureSession.isRunning else {
            throw CameraControllerError.captureSessionIsMissing
        }
        
        captureSession.beginConfiguration()

        func switchToFrontCamera() throws {
            guard let rearCameraInput = self.rearCameraInput, captureSession.inputs.contains(rearCameraInput),
                  let frontCamera = self.frontCamera else { throw CameraControllerError.invalidOperation }
            
            self.frontCameraInput = try AVCaptureDeviceInput(device: frontCamera)
            captureSession.removeInput(rearCameraInput)
            
            if captureSession.canAddInput(self.frontCameraInput!){
                captureSession.addInput(self.frontCameraInput!)
                self.currentCameraPosition = .front
            }
            
            
            else {
                throw CameraControllerError.invalidOperation
            }
        }
        
        func switchToRearCamera() throws {
            guard let frontCameraInput = self.frontCameraInput, captureSession.inputs.contains(frontCameraInput),
                  let rearCamera = self.rearCamera else { throw CameraControllerError.invalidOperation }
            
            self.rearCameraInput = try AVCaptureDeviceInput(device: rearCamera)
            captureSession.removeInput(frontCameraInput)
            
            if captureSession.canAddInput(self.rearCameraInput!){
                captureSession.addInput(self.rearCameraInput!)
                self.currentCameraPosition = .rear
            }
            
            else { throw CameraControllerError.invalidOperation }
        }
        
        switch currentCameraPosition {
        case .front:
            try switchToRearCamera()
        case .rear:
            try switchToFrontCamera()
        }
        
        captureSession.commitConfiguration()
    }
    
    // Capture Image
    func captureImage(completion: @escaping (UIImage?, Error?, Data?) -> Void) {
        guard let captureSession = captureSession, captureSession.isRunning else { completion(nil, CameraControllerError.captureSessionIsMissing, nil ); return }
        
        let settings = AVCapturePhotoSettings()
        settings.flashMode = self.flashMode
        
        self.photoOutput?.capturePhoto(with: settings, delegate: self)
        self.photoCaptureCompletionBlock = completion
    }
}

extension CameraController {
    enum CameraControllerError: Swift.Error {
        case captureSessionAlreadyRunning
        case captureSessionIsMissing
        case inputsAreInvalid
        case invalidOperation
        case noCameraAvailable
        case unknown
    }
    
    public enum CameraPosition {
        case front
        case rear
    }
}

extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?, previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?) {
        if let error = error { self.photoCaptureCompletionBlock?(nil, error,nil) }
        
        else if let buffer = photoSampleBuffer, let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: buffer, previewPhotoSampleBuffer: nil){
            let image = UIImage(data: data)
            self.photoCaptureCompletionBlock?(image, nil, data)
        }
        
        else {
            self.photoCaptureCompletionBlock?(nil, CameraControllerError.unknown, nil)
        }
    }
}
