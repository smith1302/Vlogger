import Foundation
import Parse

class Story : PFObject, PFSubclassing  {
    
    @NSManaged var user: User
    @NSManaged var videos: PFRelation
    @NSManaged var title: String
    @NSManaged var day: Int
    @NSManaged var views: Int
    @NSManaged var likes: Int
    
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
}