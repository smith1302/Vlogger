import Foundation
import Parse
import AVFoundation

class Video : PFObject, PFSubclassing  {
    
    @NSManaged var file: PFFile
    @NSManaged var userID: String
    @NSManaged var views: Int
    @NSManaged var likes: PFRelation
    
    var uploadInProgressFlag:Bool = true
    var uploadFailedFlag:Bool = false
    var fileURL:NSURL?
    
    init(fileURL:NSURL?) {
        self.fileURL = fileURL
        super.init()
        self.userID = User.currentUser()!.objectId!
        self.views = 0
//        let asset = AVURLAsset(URL: fileURL!, options: nil)
//        let assetDuration = asset.duration
//        self.duration = CMTimeGetSeconds(assetDuration)
    }
    
    override init() {
        super.init()
    }
    
    override init(className newClassName: String) {
        super.init(className: newClassName)
    }
    
    deinit {
        cleanUpFile()
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Videos"
    }
    
    /* Other
    ------------------------------------------*/
    
    func compressVideo(handler:(AVAssetExportSession?)-> Void) {
        if fileURL == nil {
            handler(nil)
            return
        }
        let urlAsset = AVURLAsset(URL: fileURL!, options: nil)
        if let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) {
            exportSession.outputURL = fileURL!
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            exportSession.shouldOptimizeForNetworkUse = true
            exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
                handler(exportSession)
            }
        } else {
            handler(nil)
        }
        
    }
    
    var fileUploadBackgroundTaskID:UIBackgroundTaskIdentifier?
    var photoPostBackgroundTaskID:UIBackgroundTaskIdentifier?
    func uploadVideo(failureCallback:(Void->Void), successCallback:(Void->Void)) {
        if fileURL == nil {
            failureCallback()
            return
        }
        
        compressVideo({
            (exportSession) in
            
            let filePath = self.fileURL?.path
            if filePath == nil || exportSession == nil || exportSession?.status == .Failed {
                print(exportSession?.error)
                failureCallback()
                return
            }
            self.printFileSize()
            // 1) Convert compressed local video to data
            let videoData = NSData(contentsOfFile: filePath!)
            if videoData == nil {
                failureCallback()
                return
            }
            
            // 2) Attach data to PFFile
            self.file = PFFile(data: videoData!, contentType: "video/mp4")
            User.currentUser()!.addTemporaryVideo(self)
            // Create a background thread to continue the operation if the user backgrounds the app
            self.fileUploadBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskID!)
            })
            // Save the video
            self.file.saveInBackgroundWithBlock {
                (success:Bool, error:NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskID!)
                if error != nil {
                    failureCallback()
                    self.uploadFailed()
                    ErrorHandler.showAlert(error?.description)
                }
            }
            // Make another background thread for uploading the PFObject
            self.photoPostBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskID!)
            })
            
            // Upload the PFObject
            self.saveInBackgroundWithBlock({
                (success:Bool, error:NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskID!)
                if error != nil {
                    ErrorHandler.showAlert(error?.description)
                    failureCallback()
                    self.uploadFailed()
                } else if success {
                    MessageHandler.showMessage(kPhotoUploadSuccess)
                    successCallback()
                    self.uploadSucceeded()
                }
            })
        })
    }
    
    func uploadFailed() {
        uploadFailedFlag = true
        uploadInProgressFlag = false
        MessageHandler.showMessage("Video failed to upload")
    }
    
    func uploadSucceeded() {
        // Removes from temporary relation store and adds to permanent in parse
        User.currentUser()!.videoUploadSuccess(self)
        uploadFailedFlag = false
        uploadInProgressFlag = false
    }
    
    func printFileSize() {
        if let path = self.fileURL?.path {
            let videoData = NSData(contentsOfFile: path)
            print(videoData?.imageFileSize())
        }
    }
    
    func getFileURL() -> NSURL? {
        // If we have the local file URL use it so we don't have to stream it
        if let url = self.fileURL where NSFileManager.defaultManager().fileExistsAtPath(url.path!) {
            return url
        } else if let urlString = file.url, url = NSURL(string: urlString) {
            return url
        }
        return nil
    }
    
    func cleanUpFile() {
        if fileURL?.path == nil {
            return
        }
        if NSFileManager.defaultManager().fileExistsAtPath(fileURL!.path!) {
            do {
                try NSFileManager.defaultManager().removeItemAtPath(fileURL!.path!)
            } catch {
                //print("[cleanupTempFile]:\(error)")
            }
        }
    }
    
}