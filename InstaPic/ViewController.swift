//
//  ViewController.swift
//  InstaPic
//
//  Created by surendra kumar on 6/11/17.
//  Copyright © 2017 weza. All rights reserved.
//

import UIKit
import  Photos
import AlertOnboarding

extension ViewController {
    func queryLastPhoto(resizeTo size: CGSize?, queryCallback: @escaping ((UIImage?) -> Void)) {
        let fetchOptions = PHFetchOptions()
        fetchOptions.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        
        let requestOptions = PHImageRequestOptions()
        requestOptions.isSynchronous = true
        
        let fetchResult = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: fetchOptions)
        if let asset = fetchResult.firstObject {
            let manager = PHImageManager.default()
            
            let targetSize = size == nil ? CGSize(width: asset.pixelWidth, height: asset.pixelHeight) : size!
            
            manager.requestImage(for: asset,
                                 targetSize: targetSize,
                                 contentMode: .aspectFit,
                                 options: requestOptions,
                                 resultHandler: { image, info in
                                    queryCallback(image)
            })
        }
        
    }
    
    
}

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
  
    
    @IBOutlet var pickerView: UIView!
    @IBOutlet var pickerimage: UIImageView!
    @IBOutlet var flipCamera: UIButton!
    @IBOutlet var Gimage: UIButton!
    @IBOutlet var CaptureButton: UIButton!
    @IBOutlet var photoCount: UILabel!
    @IBOutlet var timerView: UIView!
    @IBOutlet var timerViewcount: UILabel!
    @IBOutlet var prog: UIView!
    var pickedImage : UIImage!
    
    @IBOutlet var settingButton: UIButton!
    
    @IBOutlet var timerButton: UIButton!
    var time = 3
    var timer : Timer?
    var iscameraRunning : Bool = true
    
    let cameraController = CameraController()
    var count : Int = 0 {
        didSet{
            
            if count >= 10{
                guard !UserDefaults.standard.bool(forKey: "isupgraded") else {return}
                self.timer?.invalidate()
                self.timer = nil
                UIView.animate(withDuration: 0.3, animations: {
                    self.CaptureButton.transform = .identity
                })
                setActive(value: true)
                self.prog.transform = CGAffineTransform(scaleX: 0.0 , y: 1.0)
                self.performSegue(withIdentifier:"rateV", sender: self)
            }
        }
    }
    
    // Alert
    
    var alertView: AlertOnboarding!
    var arrayOfImage = ["item1", "item2", "item3"]
    var arrayOfTitle = ["TAKE AUTO SELFIE", "SET TIMER", "PROGRESS OF TIMER"]
    var arrayOfDescription = ["Just Press Capture button and take photo Automatically ",
                              "Easily set timer for taking selfie. each photo will be taken after passing timer time ","See progress of timer on the bottom of cameraView"]
    
    override var prefersStatusBarHidden: Bool{return true }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.timerView.alpha = 0.0
        self.styleCaptureButton()
        self.configureCameraController()
        
       self.prog.transform = CGAffineTransform(scaleX: 0.0, y: 1.0)
        DispatchQueue.main.async {
            self.queryLastPhoto(resizeTo: nil){
                image in
                self.Gimage.setBackgroundImage(image, for: .normal)
            }
        }
        alertView = AlertOnboarding(arrayOfImage: arrayOfImage, arrayOfTitle: arrayOfTitle, arrayOfDescription: arrayOfDescription)
        UserDefaults.standard.register(defaults: ["isupgraded":false])
        self.scaleLarge()
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !isAppAlreadyLaunchedOnce(){
        self.cutomizeAlertView()
        self.alertView.show()
        
        }
    }

    func configureCameraController (){
        
      cameraController.prepare { (error) in
        if error != nil{
            print("ERROR")
            return
        }
         self.cameraController.displayPreview(on: self.view)
        }
    }

// CAPTUREBUTTON
    @IBAction func caprt(_ sender: Any) {
        
        if let _ = self.timer{
            timer?.invalidate()
            self.timer = nil
            UIView.animate(withDuration: 0.3, animations: {
                self.CaptureButton.transform = .identity
            })
            setActive(value: true)
            self.prog.transform = CGAffineTransform(scaleX: 0.0 , y: 1.0)
        }else{
            UIView.animate(withDuration: 0.3, animations: {
                self.CaptureButton.transform = CGAffineTransform(scaleX: 0.7, y: 0.7)
                
            })
            setActive(value: false)
            setTimer()
           UIView.animate(withDuration: TimeInterval(self.time), delay: 0.0, options: [.repeat], animations: { 
            self.prog.transform = .identity
           }, completion: nil)
        }
        
        
    }
    //OPEN GALLEY
    @IBAction func op(_ sender: UIButton) {
        
        guard iscameraRunning == true else {return}
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = .savedPhotosAlbum
            imagePicker.allowsEditing = false
            imagePicker.modalPresentationStyle = .fullScreen
            self.present(imagePicker, animated: true, completion: nil)
        }
    }
    
    
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        if let pickedImage = info[UIImagePickerControllerOriginalImage] as? UIImage{
            
            print("picked")
            self.pickedImage = pickedImage
            
        }
    }
    
    
    //FLIP
    @IBAction func tr(_ sender: Any) {
        cameraController.toggle()
    }
    
    
    
    @IBAction func settings(_ sender: UIButton) {
    }
    
    
    
    func styleCaptureButton() {
        CaptureButton.layer.borderColor = UIColor.red.cgColor
        CaptureButton.layer.borderWidth = 2
        
        CaptureButton.layer.cornerRadius = min(CaptureButton.frame.width, CaptureButton.frame.height) / 2
    }
    
    
    func setTimer(){
        count = 0
        self.photoCount.text = String(count)
       
        self.timer = Timer.scheduledTimer(withTimeInterval: TimeInterval(time), repeats: true) { (t) in
            self.cameraController.captureImage()
            self.count += 1
            self.photoCount.text = String(self.count)
          
            DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: { 
                self.queryLastPhoto(resizeTo: nil){
                    image in
                    self.Gimage.setBackgroundImage(image, for: .normal)
                }
            })
        }
    }
    
    
    @IBAction func timerButton(_ sender: Any) {
        UIView.animate(withDuration: 0.2) { 
            self.timerView.alpha = 0.6
        }
    }
    
    @IBAction func plusCount(_ sender: Any) {
        time += 1
        self.timerViewcount.text = String(time)
    }
    
    @IBAction func minusCount(_ sender: Any) {
        if (time >= 2){
            time -= 1
            self.timerViewcount.text = String(time)
        }
    }
    
    @IBAction func okbuttonPressed(_ sender: Any) {
        UIView.animate(withDuration: 0.2) {
            self.timerView.alpha = 0.0
        }
    }
    
    
    func setActive(value : Bool){
     
        self.settingButton .isEnabled = value
        self.timerButton.isEnabled = value
        self.iscameraRunning = value
       }
    
    
    @IBAction func close(segue : UIStoryboardSegue){}
    
    func scaleLarge(){
        self.settingButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.settingButton.tintColor = UIColor.black
        self.timerButton .transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.timerButton.tintColor = UIColor.black
        self.flipCamera.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        self.flipCamera.tintColor = UIColor.black
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
    }
}


extension ViewController{
    
    func cutomizeAlertView(){
        self.alertView.colorForAlertViewBackground = UIColor.white
        self.alertView.percentageRatioWidth = 0.95
        self.alertView.percentageRatioHeight = 0.93
        self.alertView.colorButtonText = RED
        self.alertView.colorCurrentPageIndicator = RED
        self.alertView.colorPageIndicator = RED.withAlphaComponent(0.30)
        self.alertView.colorTitleLabel = RED.withAlphaComponent(0.70)
        self.alertView.colorButtonBottomBackground = RED.withAlphaComponent(0.27)
        
        
    }
    
    func isAppAlreadyLaunchedOnce()->Bool{
        let defaults = UserDefaults.standard
        
        if let _ = defaults.string(forKey: "isAppAlreadyLaunchedOnce") {
            print("App already launched")
            return true
        }else{
            defaults.set(true, forKey: "isAppAlreadyLaunchedOnce")
            print("App launched first time")
            return false
        }
    }

}


