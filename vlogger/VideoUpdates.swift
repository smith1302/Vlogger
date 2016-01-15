import Foundation
import Parse

class VideoUpdates : PFObject, PFSubclassing  {
    
    @NSManaged var user: User
    @NSManaged var video: Video
    
    override init() {
        super.init()
    }
    
    init(user:User, video:Video) {
        super.init()
        self.user = user
        self.video = video
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
        return "VideoUpdates"
    }
    
}