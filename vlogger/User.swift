import Parse

class User : PFUser {
    
    @NSManaged var videos: PFRelation
    @NSManaged var likes: PFRelation
    @NSManaged var picture: PFFile
    @NSManaged var plays: Int
    var temporaryVideos:[Video] = [Video]() // Stores them until they are uploaded
    var followingUserStatus:[String:Bool] = [String:Bool]()
    
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
        for (index, tempVideo) in temporaryVideos.enumerate() {
            if tempVideo == video {
                temporaryVideos.removeAtIndex(index)
                break
            }
        }
        saveEventually()
    }
    
    func getVideos(callback:([Video]->Void)) {
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
    }
    
    /*  Follow user
    -----------------------------------------------------*/
    func followUser() {
        if self == User.currentUser() {
            return
        }
        let object = Follow()
        object.toUser = self
        object.fromUser = User.currentUser()!
        object.saveEventually()
        User.currentUser()!.setFollowingUserStatus(toUser: self, isFollowing: true)
    }
    
    func setFollowingUserStatus(toUser user:User, isFollowing:Bool) {
        if let id = user.objectId {
            followingUserStatus[id] = isFollowing
        }
    }
    
    func isFollowingUser(user:User) -> Bool {
        if let id = user.objectId, isFollowing = followingUserStatus[id] {
            return isFollowing
        }
        return false
    }
}