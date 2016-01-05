import Parse

class User : PFUser {
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
}