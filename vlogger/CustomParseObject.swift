import Foundation
import Parse

class CustomParseObject : PFObject, PFSubclassing  {
    
    override init() {
        super.init()
        setPermissions()
    }
    
    override class func initialize() {
        struct Static {
            static var onceToken : dispatch_once_t = 0;
        }
        dispatch_once(&Static.onceToken) {
            self.registerSubclass()
        }
    }
    
    class func parseClassName() -> String {
        assertionFailure("Must subclass this")
        return ""
    }
    
    func setPermissions() {
        assertionFailure("Must subclass this")
    }
    
}