import Foundation
import Parse

class Story : PFObject, PFSubclassing  {
    
    @NSManaged var user: User
    @NSManaged var videos: PFRelation
    @NSManaged var title: String
    @NSManaged var videoAddedAt: NSDate
    @NSManaged var day: Int
    @NSManaged var views: Int
    @NSManaged var likes: Int
    @NSManaged var active: Bool
    @NSManaged var videoCount: Int
    @NSManaged var tags: [String]
    @NSManaged var featured: Bool
    @NSManaged var thumbnail: PFFile?
    
    static var thumbnailCache:[String:UIImage] = [String:UIImage]()
    static var storyCache:[String:Story] = [String:Story]()
    
    override init() {
        super.init()
    }
    
    init(day:Int, user:User) {
        super.init()
        self.user = user
        self.title = NSDate.getReadableTimeFull()
        self.day = day
        self.views = 0
        self.likes = 0
        self.videoCount = 0
        self.active = true
        self.featured = false
        self.tags = getTagsFromString(NSDate.getReadableTimeFull())
        self.videoAddedAt = NSDate()
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
    
    static func parseClassName() -> String {
        return "Story"
    }
    
    /* Cache
    -------------------------------------------*/
    
    func getCached() -> Story {
        var toReturn = self
        if let ID = objectId {
            // Get cached version
            if let story = Story.storyCache[ID] {
                toReturn = story
            }
            // Update the cache with the current story
            cache()
        }
        return toReturn
    }
    
    func cache() {
        if let ID = objectId {
            // Don't cache it unless we have data available for the user too.
            if self.user.dataAvailable && self.dataAvailable {
                Story.storyCache[ID] = self
            }
        }
    }
    
    func getTagsFromString(string:String) -> [String] {
        var tags = string.componentsSeparatedByString(" ")
        for (index,tag) in tags.enumerate() {
            tags[index] = tag.lowercaseString
        }
        return tags
    }
    
    func removeVideo(video:Video?) {
        if video == nil { return }
        // Delete video
        video!.deleteInBackgroundWithBlock({
            (success:Bool, error:NSError?) in
            if success {
                self.videoCount -= 1
                if self.videoCount == 0 {
                    // Don't delete current story... ever!!
                    if let ID = self.objectId, currentStoryID = User.currentUser()!.currentStory?.objectId where ID == currentStoryID {
                        // Theoretically it should be 0 but incase things got out of sync...
                        self.views = 0
                        self.likes = 0
                    } else {
                        self.deleteEventually()
                    }
                } else {
                    self.views -= video!.views
                    self.likes -= video!.likes
                    self.views = max(0,self.views)
                    self.likes = max(0,self.likes)
                }
                self.saveEventually()
            }
        })
    }
    
    func addVideo(video:Video, callback:(Bool->Void)) {
        videos.addObject(video)
        videoCount += 1
        videoAddedAt = NSDate()
        
        self.thumbnail = video.generateThumbnail()
        self.thumbnail?.saveInBackgroundWithBlock {
            (success:Bool, error:NSError?) -> Void in
            self.saveEventually({
                (success:Bool, error:NSError?) in
                callback(success)
            })
        }
    }
    
    func getVideos(callback:([Video]->Void)) {
        let query = videos.query()
        query.orderByAscending("createdAt")
        query.findObjectsInBackgroundWithBlock({
            (objects:[PFObject]?, error:NSError?) in
            if let videos = objects as? [Video] {
                callback(videos + self.user.temporaryVideos)
            } else {
                callback(self.user.temporaryVideos)
            }
        })
    }
    
    /* Thumbnail
    -------------------------------------*/
    
    func getThumbnail(callback:(UIImage?->Void)) {
        if let id = self.objectId {
            if let cachedImage = Story.thumbnailCache[id] {
                callback(cachedImage)
            } else {
                thumbnail?.getDataInBackgroundWithBlock({
                    (imageData:NSData?, error:NSError?) in
                    if let data = imageData {
                        let image = UIImage(data:data)
                        Story.thumbnailCache[id] = image
                        callback(image)
                    }
                })
            }
        }
        callback(nil)
    }
}