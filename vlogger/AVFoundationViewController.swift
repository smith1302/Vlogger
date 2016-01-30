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
import MediaPlayer

protocol CameraSessionControllerDelegate {
    func cameraSessionDidOutputSampleBuffer(sampleBuffer: CMSampleBuffer!)
}

class AVFoundationViewController: UIViewController, AVCaptureFileOutputRecordingDelegate, AVCaptureMetadataOutputObjectsDelegate {
    
    // AVFoundation
    var session: AVCaptureSession!
    var sessionQueue: dispatch_queue_t!
    var videoDeviceInput: AVCaptureDeviceInput!
    var videoDeviceOutput: AVCaptureMovieFileOutput!
    var audioDeviceInput: AVCaptureDeviceInput!
    var stillImageOutput: AVCaptureStillImageOutput!
    var captureMetadataOutput: AVCaptureMetadataOutput!
    var videoDevice: AVCaptureDevice!
    var audioDevice: AVCaptureDevice!
    var runtimeErrorHandlingObserver: AnyObject?
    var previewLayer:AVCaptureVideoPreviewLayer!
    var videoPlayerController:VideoPlayerViewController?
    var delegate : AVCaptureFileOutputRecordingDelegate?
    // Other
    var sessionDelegate: CameraSessionControllerDelegate?
    var faceDetector:FaceDetectionView?
    var currentVideo:Video?
    // IBOutlets
    @IBOutlet weak var previewView: UIView!
    
    /* Class Methods
    ------------------------------------------*/
    
    class func deviceWithMediaType(mediaType: NSString, position: AVCaptureDevicePosition) -> AVCaptureDevice? {
        let devices: NSArray = AVCaptureDevice.devicesWithMediaType(mediaType as String)
        var captureDevice: AVCaptureDevice? = devices.firstObject as? AVCaptureDevice
        
        for object:AnyObject in devices {
            let device = object as? AVCaptureDevice
            if device != nil && (device!.position == position) {
                captureDevice = device!
                break
            }
        }
        
        return captureDevice
    }
    
    deinit {
        cleanupCurrentVideo()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        delegate = self
        
        session = AVCaptureSession()
        session.sessionPreset = AVCaptureSessionPreset1280x720
        authorizeCamera();
        sessionQueue = dispatch_queue_create("CameraSessionController Session", DISPATCH_QUEUE_SERIAL)
        
        self.session.beginConfiguration()
        self.addVideoInput(.Back)
        self.addVideoOutput()
        self.addAudioInput()
        self.addStillImageOutput()
        self.addFaceDetection()
        self.session.commitConfiguration()
        self.beginCameraSession()

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            videoDeviceInput = try AVCaptureDeviceInput(device: videoDevice)
            if session.canAddInput(videoDeviceInput) {
                session.addInput(videoDeviceInput)
                success = true
            } else {
                print("Could not add video input")
            }
        } catch {
            print(error)
        }
        
        return success
    }
    
    func addVideoOutput() {
        videoDeviceOutput = AVCaptureMovieFileOutput()
        videoDeviceOutput.maxRecordedDuration = CMTimeMakeWithSeconds(10, 60)
        
        if session.canAddOutput(videoDeviceOutput) {
            session.addOutput(videoDeviceOutput)
        } else {
            print("Could not add video output")
        }
    }
    
    func addAudioInput() {
        audioDevice = AVCaptureDevice.defaultDeviceWithMediaType(AVMediaTypeAudio)
        do {
            audioDeviceInput = try AVCaptureDeviceInput(device: audioDevice)
            if session.canAddInput(audioDeviceInput) {
                session.addInput(audioDeviceInput)
            } else {
                print("Could not add audio input")
            }
        } catch {
            print(error)
        }
    }
    
    func addStillImageOutput() {
        stillImageOutput = AVCaptureStillImageOutput()
        stillImageOutput.outputSettings = [AVVideoCodecKey: AVVideoCodecJPEG]
        
        if session.canAddOutput(stillImageOutput) {
            session.addOutput(stillImageOutput)
        }
    }
    
    func addFaceDetection() {
        captureMetadataOutput = AVCaptureMetadataOutput()
        
        if session.canAddOutput(captureMetadataOutput) {
            session.addOutput(captureMetadataOutput)
            // Set delegate and use the default dispatch queue to execute the call back
            captureMetadataOutput.setMetadataObjectsDelegate(self, queue: dispatch_get_main_queue())
            for type in captureMetadataOutput.availableMetadataObjectTypes {
                if let assertedType = type as? String where assertedType == AVMetadataObjectTypeFace {
                    captureMetadataOutput.metadataObjectTypes = [AVMetadataObjectTypeFace]
                }
            }
        }
        
        // Initialize FRAME to highlight face
        faceDetector = FaceDetectionView()
        view.addSubview(faceDetector!)
        view.bringSubviewToFront(faceDetector!)
    }
    
    /* Face Detection
    ------------------------------------------*/
    
    func captureOutput(captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [AnyObject]!, fromConnection connection: AVCaptureConnection!) {
        
        // Check if the metadataObjects array is not nil and it contains at least one object.
        if metadataObjects == nil || metadataObjects.count == 0 {
            faceDetector?.hide()
            return
        }
        
        for metadataObject in metadataObjects as! [AVMetadataObject] {
            if metadataObject.type == AVMetadataObjectTypeFace {
                let transformedMetadataObject = previewLayer.transformedMetadataObjectForMetadataObject(metadataObject)
                faceDetector?.showAtFrame(transformedMetadataObject.bounds)
            }
        }
    }
    
    /* MovieFileOutput Delegate
    ------------------------------------------*/
    
    func captureOutput(captureOutput: AVCaptureFileOutput!, didFinishRecordingToOutputFileAtURL outputFileURL: NSURL!, fromConnections connections: [AnyObject]!, error: NSError?) {
        let videoFile = outputFileURL as NSURL!
        let pathString = videoFile.relativePath
        let videoURL = NSURL.fileURLWithPath(pathString!)
        if error != nil {
            AVFoundationViewController.cleanupTempFile(videoFile.path)
            return
        }

        currentVideo = Video(fileURL: videoURL)
        currentVideo?.printFileSize()
        
        videoPlayerController = VideoPlayerViewController(videos: [currentVideo!])
        videoPlayerController?.view.frame = view.frame
        videoPlayerController?.hidesProgressBar(true)
        self.addChildViewController(videoPlayerController!)
        self.view.addSubview(videoPlayerController!.view)
    }
    
    /* Actions
    ------------------------------------------*/
    
    override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
        if let touchPoint = touches.first {
            let screenSize = previewView.bounds.size
            let focusPoint = CGPoint(x: touchPoint.locationInView(previewView).y / screenSize.height, y: touchPoint.locationInView(previewView).x / screenSize.width)
            focusTo(focusPoint)
        }
    }
    
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
        AVFoundationViewController.cleanupTempFile(path)
        return url
    }
    
    func removeVideoPlayerPreview() {
        videoPlayerController?.view.removeFromSuperview()
        videoPlayerController?.removeFromParentViewController()
        videoPlayerController = nil
    }
    
    func cleanupCurrentVideo() {
        removeVideoPlayerPreview()
        currentVideo?.cleanUpFile()
        currentVideo = nil
    }
    
    class func cleanupTempFile(path:String?) {
        if path == nil {
            return
        }
        if NSFileManager.defaultManager().fileExistsAtPath(path!) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(path!)
            } catch {
                print("[cleanupTempFile]:\(error)")
            }
        }
    }
    
    func excludeFromBackup(url:NSURL) {
        do {
            try url.setResourceValue(true, forKey: NSURLIsExcludedFromBackupKey)
        } catch {
            print("[Exclude From Backup]:\(error)")
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
    
    func focusTo(focusPoint:CGPoint) {
        if let device = videoDevice {
            do {
                try device.lockForConfiguration()
                if device.focusPointOfInterestSupported {
                    device.focusPointOfInterest = focusPoint
                    device.focusMode = .AutoFocus
                }
                if device.isExposureModeSupported(AVCaptureExposureMode.AutoExpose) {
                    device.exposurePointOfInterest = focusPoint
                    device.exposureMode = .AutoExpose
                }
                device.unlockForConfiguration()
            } catch {
                print(error)
            }
        }
    }
}

