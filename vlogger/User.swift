import Parse

class User : PFUser {
    
    @NSManaged var usernameLowercase:String
    @NSManaged var currentStory: Story?
    @NSManaged var likes: PFRelation
    @NSManaged var picture: PFFile
    @NSManaged var subscriberCount: Int
    @NSManaged var plays: Int
    @NSManaged var notifications: Bool
    var temporaryVideos:[Video] = [Video]() // Stores them until they are uploaded
    // Caches
    var followingUserStatus:[String:Bool] = [String:Bool]()
    var likedVideoStatus:[String:Bool] = [String:Bool]()
    var flaggedVideoStatus:[String:Bool] = [String:Bool]()
    
    override init() {
        super.init()
    }
    
    init(username:String, password:String, usernameLowercase:String) {
        super.init()
        self.notifications = true
        self.username = username
        self.password = password
        self.usernameLowercase = usernameLowercase
        self.currentStory = Story(day: NSDate.getCurrentDay(), user: self)
        self.currentStory?.saveEventually()
    }
    
    override init(className newClassName: String) {
        super.init(className: newClassName)
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    override static func currentUser() -> User? {
        return PFUser.currentUser() as? User
    }
    
    var fileUploadBackgroundTaskID:UIBackgroundTaskIdentifier?
    func changeProfilePicture(file:PFFile) {
        // Create a background thread to continue the operation if the user backgrounds the app
        self.fileUploadBackgroundTaskID = UIApplication.sharedApplication().beginBackgroundTaskWithExpirationHandler({
            UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskID!)
        })
        // Save the video
        picture = file
        picture.saveInBackgroundWithBlock {
            (success:Bool, error:NSError?) -> Void in
            UIApplication.sharedApplication().endBackgroundTask(self.fileUploadBackgroundTaskID!)
            if error != nil {
                ErrorHandler.showAlert(error?.description)
            } else {
                self.saveEventually()
            }
        }
    }
    
    // Add video when first made so the user can see it
    func addTemporaryVideo(video:Video) {
        temporaryVideos.append(video)
        print("Temp added")
    }
    
    // When video is uploaded add to our relations list
    func videoUploadSuccess(video:Video) {
        //videos.addObject(video)
        removeTemporaryVideo(video)
        //saveEventually()
    }
    
    func removeTemporaryVideo(video:Video) {
        if let index = temporaryVideos.indexOf(video) {
            temporaryVideos.removeAtIndex(index)
        }
    }
    
    // Only gets our videos in the last 24 hours
    /*func getVideos(callback:([Video]->Void)) {
        let query = videos.query()
        query.whereKey("createdAt", greaterThan: NSDate(timeIntervalSinceNow: -60*60*24*1))
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock({
            (objects:[PFObject]?, error:NSError?) in
            if let videos = objects as? [Video] {
                callback(videos + self.temporaryVideos)
            } else {
                callback(self.temporaryVideos)
            }
        })
    }*/
    
    // Get videos we should show in our feed which consists of:
    // All video in the past 24 hours 
    // If no videos in the past 24 hours show the last 2 available videos
    func getFeedVideos(callback:([Video]->Void)) {
        let oneDayAgo = NSDate(timeIntervalSinceNow: -60*60*24*1)
        PFCloud.callFunctionInBackground("getFeedVideos", withParameters: ["userID":self.objectId!,"oneDayAgo":oneDayAgo], block: {
            (response:AnyObject?, error:NSError?) in
            if let videos = response as? [Video] {
                callback(videos + self.temporaryVideos)
            } else {
                callback(self.temporaryVideos)
            }
        })
    }
    
    func getTotalViews(callback:(Int->Void)) {
        PFCloud.callFunctionInBackground("totalViews", withParameters: ["userID":self.objectId!], block: {
            (object:AnyObject?, error:NSError?) in
            if let count = object as? Int {
                callback(count)
                return
            }
            callback(0)
        })
    }
    
//    func getTotalSubscribers(callback:(Int->Void)) {
//        let query = Follow.query()
//        query!.whereKey("toUser", equalTo: self)
//        query!.countObjectsInBackgroundWithBlock({
//            (count:Int32?, error:NSError?) in
//            if count == nil {
//                callback(0)
//                return
//            }
//            callback(Int(count!))
//            return
//        })
//    }
    
    /*  Follow user
    -----------------------------------------------------*/
    func followUser() {
        if self == User.currentUser() {
            return
        }
        User.currentUser()!.setFollowingUserStatus(toUser: self, isFollowing: true)
        let object = Follow()
        object.toUser = self
        object.fromUser = User.currentUser()!
        object.saveEventually({
            (success:Bool, error:NSError?) in
            if error != nil {
                ErrorHandler.showAlert("Already following this user")
                User.currentUser()!.setFollowingUserStatus(toUser: self, isFollowing: false)
            } else {
                PushController.sendPushToSubscriberReceiver(self)
            }
        })
    }
    
    func unfollowUser() {
        //        if self == User.currentUser() {
        //            return
        //        }
        User.currentUser()!.setFollowingUserStatus(toUser: self, isFollowing: false)
        let object = Follow.query()
        object?.whereKey("toUser", equalTo: self)
        object?.whereKey("fromUser", equalTo: User.currentUser()!)
        object?.getFirstObjectInBackgroundWithBlock({
            (object:PFObject?, error:NSError?) in
            if let follow = object as? Follow {
                follow.deleteEventually()
            }
        })
    }
    
    func setFollowingUserStatus(toUser user:User, isFollowing:Bool) {
        if let id = user.objectId {
            followingUserStatus[id] = isFollowing
        }
    }
    
    func isFollowingUser(user:User, callback:(Bool->Void)) {
        if let id = user.objectId, isFollowing = followingUserStatus[id] {
            callback(isFollowing)
            return
        }
        let query = Follow.query()
        query!.whereKey("fromUser", equalTo: User.currentUser()!)
        query!.whereKey("toUser", equalTo: user)
        query!.cachePolicy = .CacheThenNetwork
        query!.countObjectsInBackgroundWithBlock({
            (count:Int32, error:NSError?) in
            if error != nil {
                callback(false)
            } else {
                callback(count > 0)
            }
        })
    }
    
    /*  Likes
    -----------------------------------------------------*/
    
    func setLikedVideoStatus(video:Video, hasLiked:Bool) {
        if let id = video.objectId {
            likedVideoStatus[id] = hasLiked
        }
    }
    
    func hasLikedVideo(video:Video, callback:(Bool->Void)) {
        if let id = video.objectId, hasLiked = likedVideoStatus[id] {
            callback(hasLiked)
            return
        }
        let query = Like.query()
        query!.whereKey("user", equalTo: self)
        query!.whereKey("video", equalTo: video)
        query!.cachePolicy = .CacheThenNetwork
        query!.countObjectsInBackgroundWithBlock({
            (count:Int32, error:NSError?) in
            if error != nil {
                self.setLikedVideoStatus(video, hasLiked: false)
                callback(false)
            } else {
                self.setLikedVideoStatus(video, hasLiked: count > 0)
                callback(count > 0)
            }
        })
    }
    
    /*  Flags
    -----------------------------------------------------*/
    
    func setFlaggedVideoStatus(video:Video, hasFlagged:Bool) {
        if let id = video.objectId {
            flaggedVideoStatus[id] = hasFlagged
        }
    }
    
    func hasFlaggedVideo(video:Video) -> Bool {
        if let id = video.objectId, hasFlagged = flaggedVideoStatus[id] {
            return hasFlagged
        }
        return false
    }
    
    /*  Story
    -----------------------------------------------------*/
    
    func uploadVideoToStory(story:Story, video:Video?, failureCallback:(Void->Void), successCallback:(Void->Void)) {
        if video == nil {
            failureCallback()
            return
        }
        
        video!.story = story
        video!.uploadVideo({
            failureCallback()
            }, successCallback: {
                story.addVideo(video!, callback: {
                    (success:Bool) in
                    story.saveEventually({
                        (success:Bool, error:NSError?) in
                        if success {
                            successCallback()
                        } else {
                            failureCallback()
                        }
                    })
                })
        })
    }
    
    func uploadVideoToCurrentStory(video:Video?, failureCallback:(Void->Void), successCallback:(Void->Void)) {
        if let story = currentStory {
            story.fetchIfNeededInBackgroundWithBlock({
                (object:PFObject?, error:NSError?) in
                if let story = object as? Story {
                    story.cache()
                    self.currentStory = story
                    self.currentStory!.user = User.currentUser()!
                    self.uploadVideoToStory(story, video: video, failureCallback: failureCallback, successCallback: successCallback)
                } else {
                    failureCallback()
                }
            })
        } else {
            self.uploadVideoToNewStory(video, title: nil, failureCallback: failureCallback, successCallback: successCallback)
        }
    }
    
    func uploadVideoToNewStory(video:Video?, title:String?, failureCallback:(Void->Void), successCallback:(Void->Void)) {
        // Make a new story
        let story = Story(day: NSDate.getCurrentDay(), user:self)
        if let title = title {
            let tags = story.getTagsFromString(title)
            story.tags = tags
            story.title = title
        }
        uploadVideoToStory(story, video: video, failureCallback: failureCallback, successCallback: {
            self.currentStory = story
            self.saveEventually({
                (success:Bool, error:NSError?) in
                print(error)
                if success {
                    successCallback()
                } else {
                    failureCallback()
                }
            })
        })
    }
    
    func getStoryCount(callback:(Int->Void)) {
        let query = Story.query()
        query?.whereKey("user", equalTo: self)
        query?.whereKey("videoCount", greaterThanOrEqualTo: 1)
        query?.countObjectsInBackgroundWithBlock({
            (count:Int32, error:NSError?) in
            if error == nil {
                callback(Int(count))
            }
        })
    }
    
    /*  Helpers
    -----------------------------------------------------*/
    
    func isUs() -> Bool {
        return self.objectId == User.currentUser()!.objectId
    }
}