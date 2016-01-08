import Foundation
import Parse
import AVFoundation

class Video : PFObject, PFSubclassing  {
    
    @NSManaged var file: PFFile
    @NSManaged var userID: String
    @NSManaged var views: Int
    @NSManaged var likes: PFRelation
    
    var fileURLIsCompressed:Bool = false
    var uploadInProgressFlag:Bool = false
    var uploadFailedFlag:Bool = false
    var fileURL:NSURL?
    var avAsset:AVAsset?
    
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
    
    private func compressVideo(handler:(AVAssetExportSession?)-> Void) {
        let fileURL = getFileURL()
        if fileURL == nil || fileURLIsCompressed {
            handler(nil)
            return
        }
        let urlAsset = AVURLAsset(URL: fileURL!)
        urlAsset.loadValuesAsynchronouslyForKeys(["tracks"], completionHandler: {
            if let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) {
                self.cleanUpFile()
                exportSession.outputURL = self.fileURL!
                exportSession.outputFileType = AVFileTypeQuickTimeMovie
                exportSession.shouldOptimizeForNetworkUse = true
                exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
                    handler(exportSession)
                }
            } else {
                handler(nil)
            }
        })
        
    }
    
    var fileUploadBackgroundTaskID:UIBackgroundTaskIdentifier?
    var photoPostBackgroundTaskID:UIBackgroundTaskIdentifier?
    func uploadVideo(failureCallback:(Void->Void), successCallback:(Void->Void)) {
        self.uploadInProgressFlag = true
        if fileURL == nil {
            failureCallback()
            self.uploadFailed()
            return
        }
        
        compressVideo({
            (exportSession) in
            
            let filePath = self.fileURL?.path
            if filePath == nil || exportSession == nil || exportSession?.status == .Failed {
                failureCallback()
                self.uploadFailed()
                return
            }
            self.fileURLIsCompressed = true
            self.printFileSize()
            // 1) Convert compressed local video to data
            let videoData = NSData(contentsOfFile: filePath!)
            if videoData == nil {
                failureCallback()
                self.uploadFailed()
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
    
    private func uploadFailed() {
        uploadFailedFlag = true
        uploadInProgressFlag = false
        MessageHandler.showMessage("Video failed to upload")
    }
    
    private func uploadSucceeded() {
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
    
    func getAVPlayerItem() -> AVPlayerItem? {
        if avAsset != nil { // check cache
            return AVPlayerItem(asset: avAsset!)
        }
        if let url = self.getFileURL() {
            let item = AVPlayerItem(asset: AVAsset(URL: url))
            //self.avAsset = item.asset // cache it
            return item
        }
        return nil
    }
    
}