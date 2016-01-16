import Foundation
import Parse

class Story : PFObject, PFSubclassing  {
    
    @NSManaged var user: User
    @NSManaged var videos: PFRelation
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
}