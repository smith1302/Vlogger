import Foundation
import Parse

class Video : CustomParseObject  {
    
    @NSManaged var file: PFFile
    @NSManaged var userID: String
    @NSManaged var views: Int
    @NSManaged var likes: PFRelation
    
    init(file:PFFile) {
        super.init()
        self.file = file
        self.userID = User.currentUser()!.objectId!
        self.views = 0
    }
    
    override static func parseClassName() -> String {
        return "Videos"
    }
    
    override func setPermissions() {
        
    }
    
}