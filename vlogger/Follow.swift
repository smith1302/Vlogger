import Foundation
import Parse

class Follow : PFObject, PFSubclassing  {
    
    @NSManaged var fromUser: User
    @NSManaged var toUser: User
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Follows"
    }
    
}