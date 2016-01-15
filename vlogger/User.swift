import Parse

class User : PFUser {
    
    @NSManaged var usernameLowercase:String
    @NSManaged var videos: PFRelation
    @NSManaged var likes: PFRelation
    @NSManaged var picture: PFFile
    @NSManaged var plays: Int
    var temporaryVideos:[Video] = [Video]() // Stores them until they are uploaded
    // Caches
    var followingUserStatus:[String:Bool] = [String:Bool]()
    var likedVideoStatus:[String:Bool] = [String:Bool]()
    var flaggedVideoStatus:[String:Bool] = [String:Bool]()
    
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
    
    // Add video when first made so the user can see it
    func addTemporaryVideo(video:Video) {
        temporaryVideos.append(video)
    }
    
    // When video is uploaded add to our relations list
    func videoUploadSuccess(video:Video) {
        videos.addObject(video)
        removeTemporaryVideo(video)
        saveEventually()
    }
    
    func removeTemporaryVideo(video:Video) {
        for (index, tempVideo) in temporaryVideos.enumerate() {
            if tempVideo == video {
                temporaryVideos.removeAtIndex(index)
                break
            }
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
    // If no videos in the past 24 hours show the last 5 available videos
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
    
    func getTotalSubscribers(callback:(Int->Void)) {
        let query = Follow.query()
        query!.whereKey("toUser", equalTo: self)
        query!.countObjectsInBackgroundWithBlock({
            (count:Int32?, error:NSError?) in
            if count == nil {
                callback(0)
                return
            }
            callback(Int(count!))
            return
        })
    }
    
    /*  Follow user
    -----------------------------------------------------*/
    func followUser() {
//        if self == User.currentUser() {
//            return
//        }
        User.currentUser()!.setFollowingUserStatus(toUser: self, isFollowing: true)
        let object = Follow()
        object.toUser = self
        object.fromUser = User.currentUser()!
        object.saveEventually({
            (success:Bool, error:NSError?) in
            if error != nil {
                ErrorHandler.showAlert("Already following this user")
                User.currentUser()!.setFollowingUserStatus(toUser: self, isFollowing: false)
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
            object?.deleteEventually()
        })
    }
    
    func setFollowingUserStatus(toUser user:User, isFollowing:Bool) {
        if let id = user.objectId {
            if isFollowing {
                followingUserStatus[id] = isFollowing
            } else if followingUserStatus[id] != nil {
                followingUserStatus.removeValueForKey(id)
            }
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
                callback(false)
            } else {
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
}