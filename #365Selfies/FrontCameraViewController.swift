//
//  FrontCameraViewController.swift
//  #365Selfies
//
//  Created by Ankita Prasad on 11/16/15.
//  Copyright © 2015 Ankita Prasad. All rights reserved.
//

import UIKit
import AVFoundation

class FrontCameraViewController: UIViewController {

    var session = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    var previewLayer : AVCaptureVideoPreviewLayer!
    var offLabel : UILabel!
    var threeSLabel : UILabel!
    var navBar : UINavigationBar!
    var delayClick : Int! = 0
    var counter : Int! = 0
    var myTimer : NSTimer!
    var captureDevice:AVCaptureDevice! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navBar = (self.navigationController?.navigationBar)!
        navBar.barTintColor = UIColor.blackColor()
        session.sessionPreset = AVCaptureSessionPresetPhoto
        counterLabel.hidden = true
        counter = 0
        
        // adding labels to navBar
        let firstFrame = CGRect(x: timer.frame.origin.x  + 62 , y: timer.frame.origin.y - 6, width: 30, height: 40)
        let secondFrame = CGRect(x: timer.frame.origin.x  + 112, y: timer.frame.origin.y - 6  , width: 30, height: 40)
        offLabel = UILabel(frame: firstFrame)
        offLabel.text = "Off"
        offLabel.textColor = UIColor.whiteColor()
        offLabel.hidden = true
        
        // Adding gesture recognizer
        offLabel.userInteractionEnabled = true
        let tapOffLabel = UITapGestureRecognizer(target: self, action: Selector("timerLabelPressed:"))
        offLabel.addGestureRecognizer(tapOffLabel)
        
        
        threeSLabel = UILabel(frame: secondFrame)
        threeSLabel.textColor = UIColor.whiteColor()
        threeSLabel.text = "3s"
        threeSLabel.hidden = true
        
        // Adding gesture recognizer
        threeSLabel.userInteractionEnabled = true
        let tapThreeSLabel = UITapGestureRecognizer(target: self, action: Selector("timerLabelPressed:"))
        threeSLabel.addGestureRecognizer(tapThreeSLabel)
        
        offLabel.font = offLabel.font.fontWithSize(15)
        threeSLabel.font = threeSLabel.font.fontWithSize(15)

        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        navBar.addSubview(offLabel)
        navBar.addSubview(threeSLabel)
        session.sessionPreset = AVCaptureSessionPresetPhoto
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        
        
        for device in videoDevices{
            let device = device as! AVCaptureDevice
            if device.position == AVCaptureDevicePosition.Front {
                captureDevice = device
                break
            }
        }
        do
        {
            let deviceInput = try AVCaptureDeviceInput(device: captureDevice)
            if session.canAddInput(deviceInput) {
                session.addInput(deviceInput)
            }
            let rootLayer = self.view.layer
            rootLayer.masksToBounds = true
            previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            rootLayer.insertSublayer(previewLayer, atIndex: 0)
            stillImageOutput = AVCaptureStillImageOutput()
            if session.canAddOutput(stillImageOutput) {
                let outputSettings: Dictionary = [AVVideoCodecJPEG :AVVideoCodecKey]
                stillImageOutput.outputSettings = outputSettings
                session.addOutput(stillImageOutput)
            }
            session.startRunning()
        } catch let error as NSError
        {
            print(error)
        }
    }
    
    override func viewDidLayoutSubviews() {
        let frame = frameForCapture.frame
        previewLayer.frame = CGRectMake(frame.minX, frame.minY, frame.width, frame.height)
        
        
    }
    
     @IBOutlet var ImageView: UIImageView!

    @IBOutlet var frameForCapture: UIView!
    
    @IBAction func takePhotoFromButton(sender: CameraPushButton) {
        // Delay click if the user has set delay
        if delayClick == 3 {
           counterLabel.hidden = false
           myTimer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: Selector("updateTimer:"), userInfo: nil, repeats: true)
        }
        else {
            clickImage()
        }
    }
    
    func updateTimer(timer : NSTimer) {
        counter = counter + 1
        if counter <= 3 {
           counterLabel.text = String(counter)
        }
        else {
            myTimer.invalidate()
            myTimer = nil
            counterLabel.text = ""
            counterLabel.hidden = true
            counter = 0
            // Click image once the counter has reached its end
            clickImage()

        }
    }
   
        @IBOutlet var counterLabel: UILabel!
    @IBOutlet var timer: UIButton!
    
    @IBAction func showOptionsAndSetTimer(sender: UIButton) {
      
        offLabel.hidden = !offLabel.hidden
        threeSLabel.hidden = !threeSLabel.hidden
        
    }
    
    override func viewWillDisappear(animated: Bool) {
        offLabel.removeFromSuperview()
        threeSLabel.removeFromSuperview()
    }
    
    override func viewDidDisappear(animated: Bool) {
        deallocSession()

        
    }
    
    func clickImage() {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(imageSampleBuffer, error) in
                if (imageSampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                    self.ImageView.image = UIImage(data: imageData)
                    self.performSegueWithIdentifier("Edit", sender: self)
                }
            } )
        }
    }
    
    func deallocSession(){
        for input in session.inputs {
            session.removeInput(input as! AVCaptureInput)
        }
        for output in session.outputs {
            session.removeOutput(output as! AVCaptureOutput)
        }
        session.stopRunning()
        previewLayer = nil
    }
 
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "Edit" {
            let dstViewController = segue.destinationViewController as! AddDetailsViewController
            dstViewController.displayImage = ImageView.image
        }

    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        let touchPoint = touches.first! as UITouch
        let screenSize = previewLayer.bounds.size
        var location = touchPoint.locationInView(self.view)
        // Doing this as we are always in the front camera mode
        location.x = screenSize.width - location.x;
       
        
        let focusPoint = CGPointMake(location.y / screenSize.height, location.x / screenSize.width)
        if captureDevice.exposurePointOfInterestSupported {
            do {
                try captureDevice.lockForConfiguration()
                captureDevice.exposurePointOfInterest = focusPoint
                captureDevice.exposureMode = AVCaptureExposureMode.AutoExpose
                
            } catch let error as NSError {
                print(error.code)
            }
   
        }
        
    }
    
    func timerLabelPressed(sender: UITapGestureRecognizer) {
        let label = sender.view as? UILabel
        if label?.text == "Off" {
           threeSLabel.textColor = UIColor.whiteColor()
            delayClick = 0
        }
        else {
           threeSLabel.textColor = UIColor.yellowColor()
            delayClick = 3
        }
    }
}
