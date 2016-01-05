import Foundation
import Parse

class Like : CustomParseObject  {
    
    @NSManaged var file: PFFile
    @NSManaged var userID: String
    @NSManaged var views: Int
    @NSManaged var likes: PFRelation
    
    override static func parseClassName() -> String {
        return "Videos"
    }
    
    override func setPermissions() {
        
    }
    
}