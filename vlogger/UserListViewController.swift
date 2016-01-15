import UIKit
import ParseUI

class UserListViewController: PFQueryTableViewController {
    
    var outstandingQueries:[NSIndexPath:Bool] = [NSIndexPath:Bool]()
    var user:User?
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.parseClassName = "_User"
        self.textKey = "username"
        self.pullToRefreshEnabled = true
        self.paginationEnabled = false
        self.objectsPerPage = 20
    }
    
    func configure(user:User) {
        self.user = user
        self.loadObjects()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "User List"
    }
    
    override func viewWillAppear(animated: Bool) {
        navigationController?.navigationBarHidden = false
        UIApplication.sharedApplication().statusBarHidden = false
        tableView.reloadData()
        super.viewWillAppear(animated)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
