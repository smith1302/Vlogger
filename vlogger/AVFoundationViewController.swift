//
//  AVFoundationViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/4/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit
import CoreMedia
import CoreImage

protocol CameraSessionControllerDelegate {
    func cameraSessionDidOutputSampleBuffer(sampleBuffer: CMSampleBuffer!)
}

class AVFoundationViewController: UIViewController, AVCaptureFileOutputRecordingDelegate {
    
    // AVFoundation
    var session: AVCaptureSession!
    var sessionQueue: dispatch_queue_t!
    var videoDeviceInput: AVCaptureDeviceInput!
    var videoDeviceOutput: AVCaptureMovieFileOutput!
    var stillImageOutput: AVCaptureStillImageOutput!
    var videoDevice: AVCaptureDevice!
    var runtimeErrorHandlingObserver: AnyObject?
    var previewLayer:AVCaptureVideoPreviewLayer!
    var videoPlayer:LoopingPlayer?
    var videoPlayerController:AVPlayerViewController?
    var delegate : AVCaptureFileOutputRecordingDelegate?
    var currentVideoFileURL:NSURL?
    // Other
    let activityIndicator:ActivityIndicatorView = ActivityIndicatorView()
    var sessionDelegate: CameraSessionControllerDelegate?
    // IBOutlets
    @IBOutlet weak var previewView: UIView!
    
    /* Class Methods
    ------------------------------------------*/
    
    class func deviceWithMediaType(mediaType: NSString, position: AVCaptureDevicePosition) -> AVCaptureDevice {
        let devices: NSArray = AVCaptureDevice.devicesWithMediaType(mediaType as String)
        var captureDevice: AVCaptureDevice = devices.firstObject as! AVCaptureDevice
        
        for object:AnyObject in devices {
            let device = object as? AVCaptureDevice
            if device != nil && (device!.position == position) {
                captureDevice = device!
                break
            }
        }
        
        return captureDevice
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        delegate = self
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPresetHigh;
        authorizeCamera();
        sessionQueue = dispatch_queue_create("CameraSessionController Session", DISPATCH_QUEUE_SERIAL)
        
        self.session.beginConfiguration()
        self.addVideoInput(.Back)
        self.addVideoOutput()
        self.addStillImageOutput()
        self.session.commitConfiguration()
        self.beginCameraSession()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prefersStatusBarHidden() -> Bool {
        return true
    }
    
    /* AVFoundation Setup
    ------------------------------------------*/
    
    func beginCameraSession() {
        if !session.running {
            session.startRunning()
        }
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer.videoGravity = AVLayerVideoGravityResizeAspect
        previewLayer.connection?.videoOrientation = AVCaptureVideoOrientation.Portrait
        previewView.layer.addSublayer(previewLayer)
        previewLayer.frame = self.view.frame
    }
    
    func authorizeCamera() {
        AVCaptureDevice.requestAccessForMediaType(AVMediaTypeVideo, completionHandler: {
            (granted: Bool) -> Void in
            // If permission hasn't been granted, notify the user.
            if !granted {
                dispatch_async(dispatch_get_main_queue(), {
                    UIAlertView(
                        title: "Could not use camera!",
                        message: "This application does not have permission to use camera. Please update your privacy settings.",
                        delegate: self,
                        cancelButtonTitle: "OK").show()
                })
            }
        });
    }
    
    func addVideoInput(position:AVCaptureDevicePosition) -> Bool {
        // Then add the new input
        var success: Bool = false
        videoDevice = AVFoundationViewController.deviceWithMediaType(AVMediaTypeVideo, position: position)
        do {
            try session.addInput(AVCaptureDeviceInput(device: videoDevice))
            success = true
        } catch {
            print(error)
        }
        
        return success
    }
    
    func addVideoOutput() {
        
        videoDeviceOutput = AVCaptureMovieFileOutput()
        videoDeviceOutput.maxRecordedDuration = CMTimeMake(660, 60)
        
        if session.canAddOutput(videoDeviceOutput) {
            session.addOutput(videoDeviceOutput)
        }
    }
    
    func addStillImageOutput() {
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
    
    /* MovieFileOutput Delegate
    ------------------------------------------*/
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError!) {
        let videoFile = outputFileURL as NSURL!
        let pathString = videoFile.relativePath
        
        currentVideoFileURL = NSURL.fileURLWithPath(pathString!)
        videoPlayer = LoopingPlayer(URL: currentVideoFileURL!)
        videoPlayerController = AVPlayerViewController()
        videoPlayerController!.player = videoPlayer!
        videoPlayerController!.showsPlaybackControls = false
        videoPlayerController!.view.frame = view.frame
        videoPlayerController!.view.hidden = false
        videoPlayerController!.videoGravity = AVLayerVideoGravityResizeAspectFill
        self.addChildViewController(videoPlayerController!)
        self.view.addSubview(videoPlayerController!.view)
        videoPlayer!.play()
    }
    
    /* Actions
    ------------------------------------------*/
    
    func recordingStart() {
        let url:NSURL = tempFileUrl()
        videoDeviceOutput?.startRecordingToOutputFileURL(url, recordingDelegate:delegate)
    }
    
    func recordingStop() {
        videoDeviceOutput?.stopRecording()
    }
    
    /* Other Helpers
    ------------------------------------------*/
    
    func tempFileUrl() -> NSURL{
        let movieTempString = String.randomStringWithLength(15) + ".mov"
        let url = NSURL(fileURLWithPath: NSTemporaryDirectory()).URLByAppendingPathComponent(movieTempString)
        excludeFromBackup(url)
        let path = url.path!
        cleanupTempFile(path)
        return url
    }
    
    func cleanupCurrentVideo() {
        videoPlayerController?.view.removeFromSuperview()
        videoPlayerController?.removeFromParentViewController()
        videoPlayer = nil
        videoPlayerController = nil
        if currentVideoFileURL == nil {
            return
        }
        cleanupTempFile(currentVideoFileURL!.path!)
    }
    
    func cleanupTempFile(path:String) {
        if NSFileManager.defaultManager().fileExistsAtPath(path) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path)
            } catch {
                //print("[cleanupTempFile]:\(error)")
            }
        }
    }
    
    func excludeFromBackup(url:NSURL) {
        do {
            try url.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
        } catch {
            //print("[Exclude From Backup]:\(error)")
        }
    }
    
    func flipCameraPosition() {
        // First, remove any inputs if needed
        let currentCameraInput: AVCaptureInput = session.inputs[0] as! AVCaptureInput
        session.removeInput(currentCameraInput)
        
        let currentPosition:AVCaptureDevicePosition = videoDevice.position
        let newPosition = currentPosition == .Back ? AVCaptureDevicePosition.Front : AVCaptureDevicePosition.Back
        addVideoInput(newPosition)
    }

}

