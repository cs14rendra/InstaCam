//
//  CameraController.swift
//  InstaPic
//
//  Created by surendra kumar on 6/11/17.
//  Copyright © 2017 weza. All rights reserved.
//

import Foundation
import AVFoundation
import UIKit
import Photos

extension CameraController : AVCapturePhotoCaptureDelegate {
    
    func captureImage(){
        guard let mysession = self.session , mysession.isRunning else {
            print("NOT ADDED")
            return
        }
        self.photoOutput?.capturePhoto(with: AVCapturePhotoSettings(), delegate: self)
        }
    
    func toggle(){
        guard let mysessoin = self.session else {return}
        guard let _ = frontCamera , let _ = rearCamera else { return }
        
        mysessoin.beginConfiguration()
        
        for input in mysessoin.inputs{
            mysessoin.removeInput(input as! AVCaptureDeviceInput)
        }
        
        do {
            
            if currentCameraPosition == .front{
                currentDevice = try  AVCaptureDeviceInput(device: rearCamera)
                self.currentCameraPosition = .back
                print("front")
            }else if currentCameraPosition == .back {
                currentDevice = try  AVCaptureDeviceInput(device: frontCamera)
                self.currentCameraPosition = .front
                print("back")
            }
            
            if mysessoin.canAddInput(currentDevice){
                mysessoin.addInput(currentDevice)
                print("INPUT")
            }
        }catch{
            print("Oooo")
        }
        
        
        mysessoin.commitConfiguration()
    }
    
    public func capture(_ captureOutput: AVCapturePhotoOutput, didFinishProcessingPhotoSampleBuffer photoSampleBuffer: CMSampleBuffer?, previewPhotoSampleBuffer: CMSampleBuffer?, resolvedSettings: AVCaptureResolvedPhotoSettings, bracketSettings: AVCaptureBracketedStillImageSettings?, error: Error?){
        guard error == nil else {
            return
        }
        let data = AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer!, previewPhotoSampleBuffer: previewPhotoSampleBuffer)
        let image = UIImage(data: data!)
        UIImageWriteToSavedPhotosAlbum(image!, nil, nil, nil)
        
        
    }
}

public enum CameraPosition {
    case front
    case back
}

class CameraController : NSObject {
    
    var session : AVCaptureSession?
    var frontCamera : AVCaptureDevice?
    var rearCamera : AVCaptureDevice?
    
    var currentCameraPosition : CameraPosition?
    
    
    var currentDevice : AVCaptureDeviceInput?
    
    var photoOutput : AVCapturePhotoOutput?
    
    var previewLayer : AVCaptureVideoPreviewLayer?
    
    func prepare(completionHandler : @escaping (Error?) -> ()){
        func createSession(){
            
            session = AVCaptureSession()
        }
        //2
        func configureDevice() throws {
          let session = AVCaptureDeviceDiscoverySession(deviceTypes: [.builtInWideAngleCamera], mediaType: AVMediaTypeVideo, position: .unspecified)
            let cameras = session?.devices
            
            for camera in cameras!{
                if camera.position == .front{
                    self.frontCamera = camera
                }
                
                if camera.position == .back{
                    self.rearCamera = camera
                    try camera.lockForConfiguration()
                    camera.focusMode = .continuousAutoFocus
                    
                    camera.unlockForConfiguration()
                }
            }
        }
        
        //3
        func configureDeviceInput() throws {
        
            guard let session = self.session else {
                return
            }
            
             if let frontCamera = self.frontCamera {
                self.currentDevice = try AVCaptureDeviceInput(device: frontCamera)
                self.currentCameraPosition = .front
            }else if let rearCamera = self.rearCamera{
                self.currentDevice = try AVCaptureDeviceInput(device: rearCamera)
                self.currentCameraPosition = .back
                
            }
            
            
            if session.canAddInput(currentDevice){
                    session.addInput(currentDevice)
            }
            
        }
        
        //3
        func ConfigureDeviceOutput() throws {
        
        
            guard let session = self.session else {
                return
            }
            
           photoOutput = AVCapturePhotoOutput()
            
            // add some setting 
            photoOutput?.setPreparedPhotoSettingsArray([AVCapturePhotoSettings(format: [AVVideoCodecKey : AVVideoCodecJPEG])], completionHandler: nil)
            photoOutput?.photoSettingsForSceneMonitoring?.flashMode = .on
            
            if session.canAddOutput(photoOutput){
                session.addOutput(photoOutput)
                print("OUTPUT")
            }
            session.startRunning()
        }
        //4
        
        DispatchQueue(label: "prepare").async {
            
            do {
                createSession()
                try configureDevice()
                try configureDeviceInput()
                try ConfigureDeviceOutput()
                
                }catch{
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
    
    func displayPreview(on view : UIView)  {
        print("DISPLAY")
        guard let mysession = self.session  else {
              print("NOT ADDED")
            return
          }
        
        guard mysession.isRunning else {
            return
        }
        print("SESSION \(mysession.isRunning)")
        self.previewLayer = AVCaptureVideoPreviewLayer(session: mysession)
        
        guard let _ = self.previewLayer else {
            return
        }
        self.previewLayer!.videoGravity = AVLayerVideoGravityResizeAspectFill
        //self.previewLayer!.connection.videoOrientation = .portrait
        view.layer.insertSublayer(previewLayer!, at: 0)
        previewLayer?.frame = view.frame
        print("ADDED")
        
        
    }
    
    
    
}
