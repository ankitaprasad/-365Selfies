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

    let session = AVCaptureSession()
    var stillImageOutput = AVCaptureStillImageOutput()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        session.sessionPreset = AVCaptureSessionPresetPhoto
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(animated: Bool) {
        session.sessionPreset = AVCaptureSessionPresetPhoto
        let videoDevices = AVCaptureDevice.devicesWithMediaType(AVMediaTypeVideo)
        var captureDevice:AVCaptureDevice! = nil
        
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
            session.addInput(deviceInput)
            let previewLayer = AVCaptureVideoPreviewLayer(session: session)
            previewLayer.videoGravity = AVLayerVideoGravityResizeAspectFill
            
            let rootLayer = self.view.layer
            rootLayer.masksToBounds = true
            let frame = frameForCapture.frame
            
            previewLayer.frame = frame
            rootLayer.insertSublayer(previewLayer, atIndex: 0)
            stillImageOutput = AVCaptureStillImageOutput()
            let outputSettings: Dictionary = [AVVideoCodecJPEG :AVVideoCodecKey]
            stillImageOutput.outputSettings = outputSettings
            session.addOutput(stillImageOutput)
            session.startRunning()
        } catch let error as NSError
        {
            print(error)
        }
    }
     @IBOutlet var ImageView: UIImageView!

    @IBOutlet var frameForCapture: UIView!
    
    @IBAction func takePhoto(sender: UIBarButtonItem) {
        if let videoConnection = stillImageOutput.connectionWithMediaType(AVMediaTypeVideo) {
            stillImageOutput.captureStillImageAsynchronouslyFromConnection(videoConnection, completionHandler: {(imageSampleBuffer, error) in
                if (imageSampleBuffer != nil) {
                    let imageData = AVCaptureStillImageOutput.jpegStillImageNSDataRepresentation(imageSampleBuffer)
                    self.ImageView.image = UIImage(data: imageData)
                }
        } )
      }
    }
    
   
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
