import Foundation
import Parse
import AVFoundation

class Video : PFObject, PFSubclassing  {
    
    @NSManaged var file: PFFile
    @NSManaged var userID: String
    @NSManaged var views: Int
    @NSManaged var likes: PFRelation
    
    var uploadInProgressFlag:Bool
    var uploadFailedFlag:Bool
    var fileURL:NSURL?
    
    init(file:PFFile, fileURL:NSURL?) {
        self.uploadInProgressFlag = true
        self.uploadFailedFlag = false
        self.fileURL = fileURL
        super.init()
        self.file = file
        self.userID = User.currentUser()!.objectId!
        self.views = 0
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
    
    class func compressVideo(inputURL: NSURL, outputURL: NSURL, handler:(session: AVAssetExportSession)-> Void) {
        let urlAsset = AVURLAsset(URL: inputURL, options: nil)
        if let exportSession = AVAssetExportSession(asset: urlAsset, presetName: AVAssetExportPresetMediumQuality) {
            exportSession.outputURL = outputURL
            exportSession.outputFileType = AVFileTypeQuickTimeMovie
            
            exportSession.shouldOptimizeForNetworkUse = true
            
            exportSession.exportAsynchronouslyWithCompletionHandler { () -> Void in
                
                handler(session: exportSession)
            }
        }
        
    }
    
    static var fileUploadBackgroundTaskID:UIBackgroundTaskIdentifier?
    static var photoPostBackgroundTaskID:UIBackgroundTaskIdentifier?
    class func uploadVideo(fileURL:NSURL?, failureCallback:(Void->Void), successCallback:(Void->Void)) {
        if fileURL == nil {
            failureCallback()
            return
        }
        
        compressVideo(fileURL!, outputURL: fileURL!, handler: {
            (session) in
        
            let filePath = fileURL?.path
            if filePath == nil {
                failureCallback()
                return
            }
            
            let videoData = NSData(contentsOfFile: filePath!)
            print(videoData?.imageFileSize())
            if videoData == nil {
                failureCallback()
                return
            }
            
            let file = PFFile(data: videoData!, contentType: "video/mp4")
            // Attach the photo to a PFObject
            let video = Video(file: file, fileURL: fileURL)
            User.currentUser()!.addTemporaryVideo(video)
            // Create a background thread to continue the operation if the user backgrounds the app
            fileUploadBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskID!)
            })
            // Save the video
            file.saveInBackgroundWithBlock {
                (success:Bool, error:NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskID!)
                if error != nil {
                    failureCallback()
                    video.uploadFailed()
                    ErrorHandler.showAlert(error?.description)
                }
            }
            // Make another background thread for uploading the PFObject
            photoPostBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
                UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskID!)
            })
            
            // Upload the PFObject
            video.saveInBackgroundWithBlock({
                (success:Bool, error:NSError?) -> Void in
                UIApplication.sharedApplication().endBackgroundTask(self.photoPostBackgroundTaskID!)
                if error != nil {
                    ErrorHandler.showAlert(error?.description)
                    failureCallback()
                    video.uploadFailed()
                } else if success {
                    MessageHandler.showMessage(kPhotoUploadSuccess)
                    successCallback()
                    video.uploadSucceeded()
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
        // Now that it's uploaded we can clear any paths to it
        AVFoundationViewController.cleanupTempFile(self.fileURL?.path)
        uploadFailedFlag = false
        uploadInProgressFlag = false
    }
    
    func getFileURL() -> NSURL? {
        if uploadInProgressFlag {
            return self.fileURL
        } else if let urlString = file.url, url = NSURL(string: urlString) {
            return url
        }
        return nil
    }
}