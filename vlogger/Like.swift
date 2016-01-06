import Foundation
import Parse

class Like : PFObject, PFSubclassing  {
    
    @NSManaged var file: PFFile
    @NSManaged var userID: String
    @NSManaged var views: Int
    @NSManaged var likes: PFRelation
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    static func parseClassName() -> String {
        return "Likes"
    }
    
}